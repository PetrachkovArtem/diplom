import 'dart:convert';

import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/core/models/common/network_response.dart';
import 'package:charging_app/core/strings.dart';
import 'package:charging_app/services/token_storage.dart';
import 'package:dio/dio.dart';

abstract class NetworkService {
  static final Dio _client = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: true,
    ),
  );

  static Future<Map<String, String>> _headers({bool skipToken = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (!skipToken) {
      final token = await TokenStorageManager.instance.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static String _messageFromBody(dynamic data, int status) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (status == 401) return 'Неверный email или пароль';
    if (status == 400) return 'Некорректные данные';
    if (status == 403) return 'Недостаточно прав';
    return 'Ошибка сервера ($status)';
  }

  static Future<NetworkResponseWithResult> getAsync(
    String url, {
    bool skipAuthToken = false,
    Map<String, dynamic>? query,
  }) async {
    final response = await _client.get(
      '${AppStrings.serverUrl}/$url',
      queryParameters: query,
      options: Options(headers: await _headers(skipToken: skipAuthToken), validateStatus: (_) => true),
    );
    final status = response.statusCode ?? 400;
    final result = NetworkResponseWithResult(status);
    if (result.isSuccess()) {
      if (response.data is Map<String, dynamic>) {
        result.result = response.data as Map<String, dynamic>;
      } else if (response.data == null || (response.data is String && (response.data as String).isEmpty)) {
        result.result = null;
      } else if (response.data is Map) {
        result.result = Map<String, dynamic>.from(response.data as Map);
      }
    } else {
      result.errorMessage = _messageFromBody(response.data, status);
    }
    return result;
  }

  static Future<NetworkResponseWithListResult> getListAsync(
    String url, {
    bool skipAuthToken = false,
    Map<String, dynamic>? query,
  }) async {
    final response = await _client.get(
      '${AppStrings.serverUrl}/$url',
      queryParameters: query,
      options: Options(headers: await _headers(skipToken: skipAuthToken), validateStatus: (_) => true),
    );
    final status = response.statusCode ?? 400;
    final result = NetworkResponseWithListResult(status);
    if (result.isSuccess()) {
      result.result = response.data is List ? response.data as List : [];
    } else {
      result.errorMessage = _messageFromBody(response.data, status);
    }
    return result;
  }

  static Future<NetworkResponseWithResult> postAsync(
    String url,
    Map<String, dynamic>? data, {
    bool skipAuthToken = false,
  }) async {
    final response = await _client.post(
      '${AppStrings.serverUrl}/$url',
      data: data != null ? jsonEncode(data) : null,
      options: Options(headers: await _headers(skipToken: skipAuthToken), validateStatus: (_) => true),
    );
    final status = response.statusCode ?? 400;
    final result = NetworkResponseWithResult(status);
    if (result.isSuccess()) {
      if (response.data is Map<String, dynamic>) {
        result.result = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        result.result = Map<String, dynamic>.from(response.data as Map);
      }
    } else {
      result.errorMessage = _messageFromBody(response.data, status);
    }
    return result;
  }

  static Future<NetworkResponse> postWithoutResultAsync(
    String url,
    Map<String, dynamic>? data, {
    bool skipAuthToken = false,
  }) async {
    final response = await _client.post(
      '${AppStrings.serverUrl}/$url',
      data: data != null ? jsonEncode(data) : null,
      options: Options(headers: await _headers(skipToken: skipAuthToken), validateStatus: (_) => true),
    );
    final status = response.statusCode ?? 400;
    final result = NetworkResponse(status);
    if (!result.isSuccess()) {
      result.errorMessage = _messageFromBody(response.data, status);
    }
    return result;
  }

  static Future<NetworkResponseWithResult> patchAsync(
    String url,
    Map<String, dynamic>? data,
  ) async {
    final response = await _client.patch(
      '${AppStrings.serverUrl}/$url',
      data: data != null ? jsonEncode(data) : null,
      options: Options(headers: await _headers(), validateStatus: (_) => true),
    );
    final status = response.statusCode ?? 400;
    final result = NetworkResponseWithResult(status);
    if (result.isSuccess()) {
      if (response.data is Map<String, dynamic>) {
        result.result = response.data as Map<String, dynamic>;
      } else if (response.data is Map) {
        result.result = Map<String, dynamic>.from(response.data as Map);
      }
    } else {
      result.errorMessage = _messageFromBody(response.data, status);
    }
    return result;
  }

  static Future<NetworkResponse> deleteAsync(String url) async {
    final response = await _client.delete(
      '${AppStrings.serverUrl}/$url',
      options: Options(headers: await _headers(), validateStatus: (_) => true),
    );
    final status = response.statusCode ?? 400;
    final result = NetworkResponse(status);
    if (!result.isSuccess()) {
      result.errorMessage = _messageFromBody(response.data, status);
    }
    return result;
  }

  static void ensureSuccess(NetworkResponse response) {
    if (!response.isSuccess()) {
      throw ServerException(response.errorMessage ?? 'Ошибка сервера', response.status);
    }
  }
}
