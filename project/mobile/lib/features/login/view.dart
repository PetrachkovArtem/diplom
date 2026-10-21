import 'package:charging_app/core/controls/app_button.dart';
import 'package:charging_app/core/controls/app_text_field.dart';
import 'package:charging_app/core/palette.dart';
import 'package:charging_app/core/strings.dart';
import 'package:charging_app/features/login/view_model.dart';
import 'package:charging_app/features/main/view.dart';
import 'package:charging_app/features/register/view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppPalette.border),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const Text(
                    'Вход',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppPalette.text),
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    controller: vm.emailController,
                    hint: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: vm.passwordController,
                    hint: 'Пароль',
                    obscure: true,
                  ),
                  if (vm.state.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Войти',
                    loading: vm.state.isSending,
                    onPressed: () async {
                      final ok = await context.read<LoginViewModel>().login();
                      if (ok && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainView()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterView()),
                      );
                    },
                    child: const Text(
                      'Перейти к регистрации',
                      style: TextStyle(color: AppPalette.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
