import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/features/login/model.dart';
import 'package:charging_app/services/auth.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel<LoginModel> {
  LoginViewModel({AuthService? authService})
      : _authService = authService ?? AuthServiceManager.instance,
        super(LoginModel());

  final AuthService _authService;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<bool> login() async {
    state = state.copyWith(isSending: true, errorMessage: '');
    try {
      await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось войти',
      );
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
