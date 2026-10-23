import 'package:charging_app/core/controls/app_button.dart';
import 'package:charging_app/core/controls/app_text_field.dart';
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

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    if (_priceController.text != vm.state.pricePerKwh && !vm.state.isSaving) {
      _priceController.value = TextEditingValue(
        text: vm.state.pricePerKwh,
        selection: TextSelection.collapsed(offset: vm.state.pricePerKwh.length),
      );
    }

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
            const Text('Адрес электронной почты', style: TextStyle(color: AppPalette.textMuted)),
            const SizedBox(height: 4),
            Text(
              vm.state.isLoading ? '…' : (vm.state.email.isEmpty ? '—' : vm.state.email),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const Text('Стоимость 1 кВт·ч, р', style: TextStyle(color: AppPalette.textMuted)),
            const SizedBox(height: 4),
            AppTextField(
              controller: _priceController,
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: context.read<ProfileViewModel>().setPricePerKwh,
            ),
            if (vm.state.errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
            ],
            if (vm.state.successMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(vm.state.successMessage, style: const TextStyle(color: AppPalette.accent)),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: 'Сохранить',
              primary: false,
              loading: vm.state.isSaving,
              onPressed: () => context.read<ProfileViewModel>().save(),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Изменить пароль',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordView()),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Выйти',
              primary: false,
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
