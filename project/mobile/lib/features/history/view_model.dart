import 'dart:async';

import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/core/models/session_models.dart';
import 'package:charging_app/features/history/model.dart';
import 'package:charging_app/services/session.dart';
import 'package:charging_app/services/session_hub.dart';

class HistoryViewModel extends BaseViewModel<HistoryModel> {
  HistoryViewModel({
    SessionService? sessionService,
    SessionHubService? hub,
  })  : _sessionService = sessionService ?? SessionServiceManager.instance,
        _hub = hub ?? SessionHubServiceManager.instance,
        super(HistoryModel()) {
    _sub = _hub.sessionUpdated.listen(_onSessionUpdated);
    load();
  }

  final SessionService _sessionService;
  final SessionHubService _hub;
  StreamSubscription<SessionDto>? _sub;

  void _onSessionUpdated(SessionDto session) {
    if (session.endedAt != null || !session.isCurrent) {
      load(silent: true);
    }
  }

  Future<void> load({int? page, bool silent = false}) async {
    final nextPage = page ?? state.page;
    if (!silent || state.items.isEmpty) {
      state = state.copyWith(isLoading: true, errorMessage: '', page: nextPage);
    } else {
      state = state.copyWith(page: nextPage);
    }
    try {
      final result = await _sessionService.history(page: nextPage);
      state = state.copyWith(
        isLoading: false,
        items: result.items,
        page: result.page,
        total: result.total,
        pageSize: result.pageSize,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось загрузить историю',
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
