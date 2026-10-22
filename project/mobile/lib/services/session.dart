import 'package:charging_app/core/models/session_models.dart';
import 'package:charging_app/services/network.dart';

abstract class SessionService {
  Future<SessionDto> start(String stationId, String connectorId);
  Future<SessionDto> stop(String stationId);
  Future<SessionDto?> current(String stationId);
  Future<PagedSessions> history({int page = 1, int pageSize = 20});
  Future<SessionDto> byId(String id);
}

abstract class SessionServiceManager {
  static final SessionService instance = _SessionServiceImpl();
}

class _SessionServiceImpl implements SessionService {
  @override
  Future<SessionDto> start(String stationId, String connectorId) async {
    final response = await NetworkService.postAsync('api/sessions/start', {
      'stationId': stationId,
      'connectorId': connectorId,
    });
    NetworkService.ensureSuccess(response);
    return SessionDto.fromJson(response.result!);
  }

  @override
  Future<SessionDto> stop(String stationId) async {
    final response = await NetworkService.postAsync('api/sessions/stop', {
      'stationId': stationId,
    });
    NetworkService.ensureSuccess(response);
    return SessionDto.fromJson(response.result!);
  }

  @override
  Future<SessionDto?> current(String stationId) async {
    final response = await NetworkService.getAsync(
      'api/sessions/current',
      query: {'stationId': stationId},
    );
    NetworkService.ensureSuccess(response);
    if (response.result == null || response.result!.isEmpty) {
      return null;
    }
    return SessionDto.fromJson(response.result!);
  }

  @override
  Future<PagedSessions> history({int page = 1, int pageSize = 20}) async {
    final response = await NetworkService.getAsync(
      'api/sessions/history',
      query: {'page': page, 'pageSize': pageSize},
    );
    NetworkService.ensureSuccess(response);
    return PagedSessions.fromJson(response.result!);
  }

  @override
  Future<SessionDto> byId(String id) async {
    final response = await NetworkService.getAsync('api/sessions/$id');
    NetworkService.ensureSuccess(response);
    return SessionDto.fromJson(response.result!);
  }
}
