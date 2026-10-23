import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/core/models/user_models.dart';
import 'package:charging_app/services/network.dart';
import 'package:charging_app/services/token_storage.dart';

abstract class UserService {
  Future<LoginResponse> login(String email, String password);
  Future<LoginResponse> register(String email, String password, bool consent);
  Future<MeResponse> me();
  Future<MeResponse> updateProfile({required double pricePerKwh});
  Future<void> changePassword(String current, String next, String repeat);
  Future<void> logout();
  Future<bool> hasToken();
  Future<String?> currentEmail();
}

abstract class UserServiceManager {
  static final UserService instance = _UserServiceImpl();
}

class _UserServiceImpl implements UserService {
  @override
  Future<LoginResponse> login(String email, String password) async {
    final response = await NetworkService.postAsync(
      'api/user/login',
      {'email': email, 'password': password},
      skipAuthToken: true,
    );
    NetworkService.ensureSuccess(response);
    final auth = LoginResponse.fromJson(response.result!);
    if (auth.role != 'User') {
      throw ServerException('Доступ только для пользователя', 403);
    }
    await TokenStorageManager.instance.writeToken(auth.accessToken);
    await TokenStorageManager.instance.writeEmail(auth.email);
    return auth;
  }

  @override
  Future<LoginResponse> register(String email, String password, bool consent) async {
    final response = await NetworkService.postAsync(
      'api/user/register',
      {'email': email, 'password': password, 'consent': consent},
      skipAuthToken: true,
    );
    NetworkService.ensureSuccess(response);
    final auth = LoginResponse.fromJson(response.result!);
    await TokenStorageManager.instance.writeToken(auth.accessToken);
    await TokenStorageManager.instance.writeEmail(auth.email);
    return auth;
  }

  @override
  Future<MeResponse> me() async {
    final response = await NetworkService.getAsync('api/user/me');
    NetworkService.ensureSuccess(response);
    return MeResponse.fromJson(response.result!);
  }

  @override
  Future<MeResponse> updateProfile({required double pricePerKwh}) async {
    final response = await NetworkService.patchAsync(
      'api/user/profile',
      {'pricePerKwh': pricePerKwh},
    );
    NetworkService.ensureSuccess(response);
    return MeResponse.fromJson(response.result!);
  }

  @override
  Future<void> changePassword(String current, String next, String repeat) async {
    final response = await NetworkService.postWithoutResultAsync(
      'api/user/password',
      {
        'currentPassword': current,
        'newPassword': next,
        'newPasswordRepeat': repeat,
      },
    );
    NetworkService.ensureSuccess(response);
  }

  @override
  Future<void> logout() => TokenStorageManager.instance.clear();

  @override
  Future<bool> hasToken() async {
    final token = await TokenStorageManager.instance.readToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> currentEmail() => TokenStorageManager.instance.readEmail();
}
