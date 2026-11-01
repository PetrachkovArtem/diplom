import 'dart:async';

import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/features/station_add/model.dart';
import 'package:charging_app/services/session_hub.dart';
import 'package:charging_app/services/station.dart';

class StationAddViewModel extends BaseViewModel<StationAddModel> {
  StationAddViewModel({
    StationService? stationService,
    SessionHubService? hub,
  })  : _stationService = stationService ?? StationServiceManager.instance,
        _hub = hub ?? SessionHubServiceManager.instance,
        super(StationAddModel()) {
    _sub = _hub.stationsChanged.listen((_) => _onStationsChanged());
    load();
  }

  final StationService _stationService;
  final SessionHubService _hub;
  StreamSubscription<void>? _sub;
  final Set<String> _knownStationIds = {};

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final bind = await _stationService.bindUrl();
      final stations = await _stationService.list();
      _knownStationIds
        ..clear()
        ..addAll(stations.map((s) => s.id));
      state = state.copyWith(
        isLoading: false,
        urlTemplate: bind.urlTemplate,
        bindToken: bind.bindToken,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось получить адрес сервера',
      );
    }
  }

  Future<void> _onStationsChanged() async {
    try {
      final stations = await _stationService.list();
      final added = stations.where((s) => !_knownStationIds.contains(s.id)).toList();
      _knownStationIds
        ..clear()
        ..addAll(stations.map((s) => s.id));

      if (added.isEmpty) return;

      final names = added.map((s) => s.displayName).join(', ');
      final message = added.length == 1
          ? 'Станция $names добавлена в ваш список'
          : 'Станции $names добавлены в ваш список';
      state = state.copyWith(successMessage: message, errorMessage: '');
    } catch (_) {
      // Keep current UI if refresh fails.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
