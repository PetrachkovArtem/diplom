import 'dart:async';

import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/core/models/session_models.dart';
import 'package:charging_app/features/session_current/model.dart';
import 'package:charging_app/services/session.dart';
import 'package:charging_app/services/session_hub.dart';

class SessionCurrentViewModel extends BaseViewModel<SessionCurrentModel> {
  SessionCurrentViewModel({
    SessionService? sessionService,
    SessionHubService? hub,
  })  : _sessionService = sessionService ?? SessionServiceManager.instance,
        _hub = hub ?? SessionHubServiceManager.instance,
        super(SessionCurrentModel()) {
    _sub = _hub.sessionUpdated.listen(_onSession);
    load();
  }

  final SessionService _sessionService;
  final SessionHubService _hub;
  StreamSubscription<SessionDto>? _sub;

  void _onSession(SessionDto session) {
    if (!session.isCurrent && session.endedAt != null) {
      state = state.copyWith(session: session);
      return;
    }
    state = state.copyWith(session: session, errorMessage: '');
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final session = await _sessionService.current();
      state = state.copyWith(isLoading: false, session: session, clearSession: session == null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось загрузить сессию',
      );
    }
  }

  Future<bool> stop() async {
    state = state.copyWith(isStopping: true, errorMessage: '');
    try {
      final session = await _sessionService.stop();
      state = state.copyWith(isStopping: false, session: session);
      return true;
    } catch (e) {
      state = state.copyWith(
        isStopping: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось остановить сессию',
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
