import 'package:charging_app/core/models/station_models.dart';
import 'package:charging_app/services/network.dart';

abstract class StationService {
  Future<List<StationDto>> list();
  Future<StationDto> get(String id);
  Future<BindUrlResponse> bindUrl();
  Future<StationDto> rename(String id, String displayName);
  Future<void> delete(String id);
}

abstract class StationServiceManager {
  static final StationService instance = _StationServiceImpl();
}

class _StationServiceImpl implements StationService {
  @override
  Future<List<StationDto>> list() async {
    final response = await NetworkService.getListAsync('api/stations');
    NetworkService.ensureSuccess(response);
    return (response.result ?? [])
        .map((e) => StationDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<StationDto> get(String id) async {
    final response = await NetworkService.getAsync('api/stations/$id');
    NetworkService.ensureSuccess(response);
    return StationDto.fromJson(response.result!);
  }

  @override
  Future<BindUrlResponse> bindUrl() async {
    final response = await NetworkService.getAsync('api/stations/bind-url');
    NetworkService.ensureSuccess(response);
    return BindUrlResponse.fromJson(response.result!);
  }

  @override
  Future<StationDto> rename(String id, String displayName) async {
    final response = await NetworkService.patchAsync(
      'api/stations/$id',
      {'displayName': displayName},
    );
    NetworkService.ensureSuccess(response);
    return StationDto.fromJson(response.result!);
  }

  @override
  Future<void> delete(String id) async {
    final response = await NetworkService.deleteAsync('api/stations/$id');
    NetworkService.ensureSuccess(response);
  }
}
