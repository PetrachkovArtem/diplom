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
    state = state.copyWith(isLoading: true, errorMessage: '', successMessage: '');
    try {
      final me = await _authService.me();
      state = state.copyWith(
        isLoading: false,
        email: me.email,
        pricePerKwh: me.pricePerKwh.toStringAsFixed(2),
      );
    } catch (e) {
      final email = await _authService.currentEmail() ?? '';
      state = state.copyWith(
        isLoading: false,
        email: email,
        errorMessage: e is ServerException ? e.message : '',
      );
    }
  }

  void setPricePerKwh(String value) {
    state = state.copyWith(pricePerKwh: value, errorMessage: '', successMessage: '');
  }

  Future<bool> save() async {
    final normalized = state.pricePerKwh.trim().replaceAll(',', '.');
    final price = double.tryParse(normalized);
    if (price == null || price < 0) {
      state = state.copyWith(errorMessage: 'Введите корректную стоимость 1 кВт·ч');
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: '', successMessage: '');
    try {
      final me = await _authService.updateProfile(pricePerKwh: price);
      state = state.copyWith(
        isSaving: false,
        pricePerKwh: me.pricePerKwh.toStringAsFixed(2),
        successMessage: 'Сохранено',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось сохранить',
      );
      return false;
    }
  }

  Future<void> logout() => _authService.logout();
}
