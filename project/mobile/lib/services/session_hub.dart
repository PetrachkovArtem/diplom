import 'dart:async';

import 'package:charging_app/core/models/session_models.dart';
import 'package:charging_app/core/strings.dart';
import 'package:charging_app/services/token_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';

abstract class SessionHubService {
  Stream<SessionDto> get sessionUpdated;
  Stream<void> get stationsChanged;
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
  bool _connecting = false;

  @override
  Stream<SessionDto> get sessionUpdated => _sessionController.stream;

  @override
  Stream<void> get stationsChanged => _stationsController.stream;

  @override
  Future<void> connect() async {
    if (_connecting) return;
    _connecting = true;
    try {
      await disconnect();
      final token = await TokenStorageManager.instance.readToken();
      if (token == null || token.isEmpty) return;

      final url = '${AppStrings.serverUrl}/hubs/session';
      _connection = HubConnectionBuilder()
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

      _connection!.on('SessionUpdated', (args) {
        if (args == null || args.isEmpty) return;
        final raw = args.first;
        if (raw is Map) {
          _sessionController.add(SessionDto.fromJson(Map<String, dynamic>.from(raw)));
        }
      });

      _connection!.on('StationsChanged', (_) {
        _stationsController.add(null);
      });

      _connection!.onreconnected(({connectionId}) {
        _stationsController.add(null);
      });

      await _connection!.start();
    } catch (_) {
      // Keep app usable offline from hub; pull-to-refresh still works.
    } finally {
      _connecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.stop();
      } catch (_) {}
    }
  }
}
