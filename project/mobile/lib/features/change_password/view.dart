import 'package:charging_app/core/controls/app_button.dart';
import 'package:charging_app/core/controls/app_text_field.dart';
import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/change_password/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: const _ChangePasswordBody(),
    );
  }
}

class _ChangePasswordBody extends StatelessWidget {
  const _ChangePasswordBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChangePasswordViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Смена пароля'),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppTextField(controller: vm.currentController, hint: 'Текущий пароль', obscure: true),
            const SizedBox(height: 12),
            AppTextField(controller: vm.newController, hint: 'Новый пароль', obscure: true),
            const SizedBox(height: 12),
            AppTextField(controller: vm.repeatController, hint: 'Подтверждение нового пароля', obscure: true),
            if (vm.state.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
            ],
            if (vm.state.successMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(vm.state.successMessage, style: const TextStyle(color: AppPalette.accent)),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: 'Сохранить',
              loading: vm.state.isSending,
              onPressed: () async {
                final ok = await context.read<ChangePasswordViewModel>().save();
                if (ok && context.mounted) {
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
