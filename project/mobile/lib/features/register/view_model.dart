import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/features/register/model.dart';
import 'package:charging_app/services/user.dart';
import 'package:flutter/material.dart';

class RegisterViewModel extends BaseViewModel<RegisterModel> {
  RegisterViewModel({UserService? userService})
      : _userService = userService ?? UserServiceManager.instance,
        super(RegisterModel());

  final UserService _userService;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordRepeatController = TextEditingController();

  void setConsent(bool value) {
    state = state.copyWith(consent: value, errorMessage: '');
  }

  Future<bool> register() async {
    if (!state.consent) {
      state = state.copyWith(errorMessage: 'Необходимо согласие на обработку персональных данных');
      return false;
    }
    if (passwordController.text != passwordRepeatController.text) {
      state = state.copyWith(errorMessage: 'Пароль и подтверждение не совпадают');
      return false;
    }
    if (passwordController.text.length < 6) {
      state = state.copyWith(errorMessage: 'Пароль должен содержать не менее 6 символов');
      return false;
    }

    state = state.copyWith(isSending: true, errorMessage: '');
    try {
      await _userService.register(
        emailController.text.trim(),
        passwordController.text,
        state.consent,
      );
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось зарегистрироваться',
      );
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordRepeatController.dispose();
    super.dispose();
  }
}
