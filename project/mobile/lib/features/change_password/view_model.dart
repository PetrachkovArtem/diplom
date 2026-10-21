import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/core/models/common/exceptions/server_exception.dart';
import 'package:charging_app/features/change_password/model.dart';
import 'package:charging_app/services/auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordViewModel extends BaseViewModel<ChangePasswordModel> {
  ChangePasswordViewModel({AuthService? authService})
      : _authService = authService ?? AuthServiceManager.instance,
        super(ChangePasswordModel());

  final AuthService _authService;
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final repeatController = TextEditingController();

  Future<bool> save() async {
    if (newController.text.length < 6) {
      state = state.copyWith(errorMessage: 'Пароль должен содержать не менее 6 символов', successMessage: '');
      return false;
    }
    if (newController.text != repeatController.text) {
      state = state.copyWith(errorMessage: 'Новый пароль и подтверждение не совпадают', successMessage: '');
      return false;
    }

    state = state.copyWith(isSending: true, errorMessage: '', successMessage: '');
    try {
      await _authService.changePassword(
        currentController.text,
        newController.text,
        repeatController.text,
      );
      state = state.copyWith(isSending: false, successMessage: 'Пароль изменён');
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e is ServerException ? e.message : 'Не удалось сменить пароль',
      );
      return false;
    }
  }

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    repeatController.dispose();
    super.dispose();
  }
}
