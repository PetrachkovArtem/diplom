import 'package:charging_app/core/controls/app_button.dart';
import 'package:charging_app/core/controls/app_text_field.dart';
import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/main/view.dart';
import 'package:charging_app/features/privacy_policy/view.dart';
import 'package:charging_app/features/register/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: const _RegisterBody(),
    );
  }
}

class _RegisterBody extends StatelessWidget {
  const _RegisterBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Регистрация'),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
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
              const SizedBox(height: 12),
              AppTextField(
                controller: vm.passwordRepeatController,
                hint: 'Повтор пароля',
                obscure: true,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: vm.state.consent,
                onChanged: (v) => context.read<RegisterViewModel>().setConsent(v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppPalette.accent,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Согласие на обработку персональных данных',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyView()),
                    );
                  },
                  child: const Text(
                    'Открыть политику обработки данных',
                    style: TextStyle(color: AppPalette.accent),
                  ),
                ),
              ),
              if (vm.state.errorMessage.isNotEmpty)
                Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
              const SizedBox(height: 12),
              AppButton(
                label: 'Зарегистрироваться',
                loading: vm.state.isSending,
                onPressed: () async {
                  final ok = await context.read<RegisterViewModel>().register();
                  if (ok && context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainView()),
                      (_) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
