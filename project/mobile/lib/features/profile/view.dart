import 'package:charging_app/core/controls/app_button.dart';
import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/change_password/view.dart';
import 'package:charging_app/features/login/view.dart';
import 'package:charging_app/features/profile/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppPalette.border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email', style: TextStyle(color: AppPalette.textMuted)),
            const SizedBox(height: 4),
            Text(
              vm.state.isLoading ? '…' : (vm.state.email.isEmpty ? '—' : vm.state.email),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (vm.state.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Изменить пароль',
              primary: false,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordView()),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Выйти',
              onPressed: () async {
                await context.read<ProfileViewModel>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
