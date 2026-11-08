import 'dart:async';

import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/core/models/station_models.dart';
import 'package:charging_app/features/session_start/model.dart';
import 'package:charging_app/services/session.dart';
import 'package:charging_app/services/session_hub.dart';
import 'package:charging_app/services/station.dart';

class SessionStartViewModel extends BaseViewModel<SessionStartModel> {
  SessionStartViewModel(
    StationDto station, {
    SessionService? sessionService,
    StationService? stationService,
    SessionHubService? hub,
  })  : _sessionService = sessionService ?? SessionServiceManager.instance,
        _stationService = stationService ?? StationServiceManager.instance,
        _hub = hub ?? SessionHubServiceManager.instance,
        super(SessionStartModel(station: station)) {
    _sub = _hub.stationsChanged.listen((_) => refresh());
  }

  final SessionService _sessionService;
  final StationService _stationService;
  final SessionHubService _hub;
  StreamSubscription<void>? _sub;

  StationDto get station => state.station;

  Future<void> refresh() async {
    try {
      final updated = await _stationService.get(state.station.id);
      state = state.copyWith(station: updated);
    } catch (_) {
      // Keep last known state if refresh fails.
    }
  }

  Future<bool> start() async {
    state = state.copyWith(isSending: true, errorMessage: '');
    try {
      await _sessionService.start(state.station.id);
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось начать сессию',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
