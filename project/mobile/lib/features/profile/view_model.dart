import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/features/profile/model.dart';
import 'package:charging_app/services/auth.dart';

class ProfileViewModel extends BaseViewModel<ProfileModel> {
  ProfileViewModel({AuthService? authService})
      : _authService = authService ?? AuthServiceManager.instance,
        super(ProfileModel()) {
    load();
  }

  final AuthService _authService;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final me = await _authService.me();
      state = state.copyWith(isLoading: false, email: me.email);
    } catch (e) {
      final email = await _authService.currentEmail() ?? '';
      state = state.copyWith(
        isLoading: false,
        email: email,
        errorMessage: e is ServerException ? e.message : '',
      );
    }
  }

  Future<void> logout() => _authService.logout();
}
