import 'dart:async';

import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/features/station_list/model.dart';
import 'package:charging_app/services/session_hub.dart';
import 'package:charging_app/services/station.dart';

class StationListViewModel extends BaseViewModel<StationListModel> {
  StationListViewModel({
    StationService? stationService,
    SessionHubService? hub,
  })  : _stationService = stationService ?? StationServiceManager.instance,
        _hub = hub ?? SessionHubServiceManager.instance,
        super(StationListModel()) {
    _sub = _hub.stationsChanged.listen((_) => load(silent: true));
    load();
  }

  final StationService _stationService;
  final SessionHubService _hub;
  StreamSubscription<void>? _sub;

  Future<void> load({bool silent = false}) async {
    if (!silent || state.stations.isEmpty) {
      state = state.copyWith(isLoading: true, errorMessage: '');
    }
    try {
      final stations = await _stationService.list();
      state = state.copyWith(isLoading: false, stations: stations, errorMessage: '');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось загрузить станции',
      );
    }
  }

  Future<bool> rename(String id, String name) async {
    try {
      await _stationService.rename(id, name);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ServerException ? e.message : 'Не удалось переименовать',
      );
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _stationService.delete(id);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e is ServerException ? e.message : 'Не удалось удалить станцию',
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
