import 'dart:async';

import 'package:charging_app/core/models/session_models.dart';
import 'package:charging_app/core/strings.dart';
import 'package:charging_app/services/token_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';

enum HubLink { idle, connected, lost }

abstract class SessionHubService {
  Stream<SessionDto> get sessionUpdated;
  Stream<void> get stationsChanged;
  Stream<HubLink> get link;
  HubLink get linkState;
  Stream<void> get resumed;
  Future<void> connect();
  Future<void> disconnect();
}

abstract class SessionHubServiceManager {
  static final SessionHubService instance = _SessionHubServiceImpl();
}

class _SessionHubServiceImpl implements SessionHubService {
  HubConnection? _connection;
  final _sessionController = StreamController<SessionDto>.broadcast();
  final _stationsController = StreamController<void>.broadcast();
  final _linkController = StreamController<HubLink>.broadcast();
  final _resumedController = StreamController<void>.broadcast();
  HubLink _link = HubLink.idle;
  bool _connecting = false;
  bool _intentionalStop = false;
  Timer? _retry;

  @override
  Stream<SessionDto> get sessionUpdated => _sessionController.stream;

  @override
  Stream<void> get stationsChanged => _stationsController.stream;

  @override
  Stream<HubLink> get link => _linkController.stream;

  @override
  HubLink get linkState => _link;

  @override
  Stream<void> get resumed => _resumedController.stream;

  @override
  Future<void> connect() async {
    if (_connecting) return;
    _connecting = true;
    _retry?.cancel();
    try {
      await _stopSocket();
      final token = await TokenStorageManager.instance.readToken();
      if (token == null || token.isEmpty) return;

      final url = '${AppStrings.serverUrl}/hubs/session';
      final connection = HubConnectionBuilder()
          .withUrl(
            url,
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                return await TokenStorageManager.instance.readToken() ?? token;
              },
            ),
          )
          .withAutomaticReconnect()
          .build();
      _connection = connection;

      connection.on('SessionUpdated', (args) {
        if (args == null || args.isEmpty) return;
        final raw = args.first;
        if (raw is Map) {
          _sessionController.add(SessionDto.fromJson(Map<String, dynamic>.from(raw)));
        }
      });

      connection.on('StationsChanged', (_) {
        _stationsController.add(null);
      });

      connection.onreconnecting(({error}) {
        _markLost();
      });

      connection.onreconnected(({connectionId}) {
        _markRestored();
      });

      connection.onclose(({error}) {
        if (_intentionalStop) return;
        if (!identical(_connection, connection)) return;
        _connection = null;
        _markLost();
        _scheduleRetry();
      });

      await connection.start();
      if (identical(_connection, connection)) {
        _markRestored();
      }
    } catch (_) {
      if (_link == HubLink.lost) {
        _scheduleRetry();
      }
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    _retry?.cancel();
    await _stopSocket();
    _setLink(HubLink.idle);
  }

  Future<void> _stopSocket() async {
    _intentionalStop = true;
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.stop();
      } catch (_) {}
    }
    _intentionalStop = false;
  }

  void _scheduleRetry() {
    _retry?.cancel();
    _retry = Timer(const Duration(seconds: 3), () {
      if (_intentionalStop || _link != HubLink.lost) return;
      connect();
    });
  }

  void _markLost() {
    if (_link != HubLink.connected) return;
    _setLink(HubLink.lost);
  }

  void _markRestored() {
    final wasLost = _link == HubLink.lost;
    _setLink(HubLink.connected);
    if (!wasLost) return;
    _stationsController.add(null);
    _resumedController.add(null);
  }

  void _setLink(HubLink value) {
    if (_link == value) return;
    _link = value;
    _linkController.add(value);
  }
}
