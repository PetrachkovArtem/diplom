import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/features/station_add/model.dart';
import 'package:charging_app/services/station.dart';

class StationAddViewModel extends BaseViewModel<StationAddModel> {
  StationAddViewModel({StationService? stationService})
      : _stationService = stationService ?? StationServiceManager.instance,
        super(StationAddModel()) {
    load();
  }

  final StationService _stationService;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final bind = await _stationService.bindUrl();
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
}
