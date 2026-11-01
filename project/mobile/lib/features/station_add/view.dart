import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/station_add/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StationAddView extends StatelessWidget {
  const StationAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StationAddViewModel(),
      child: const _StationAddBody(),
    );
  }
}

class _StationAddBody extends StatelessWidget {
  const _StationAddBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StationAddViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Добавление станции'),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
      ),
      body: vm.state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppPalette.accent))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Введите адрес сервера на зарядной станции:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    vm.state.urlTemplate.isEmpty ? '—' : vm.state.urlTemplate,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'После BootNotification станция появится в списке.',
                    style: TextStyle(color: AppPalette.textMuted),
                  ),
                  if (vm.state.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
                  ],
                  if (vm.state.successMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppPalette.accentMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppPalette.accent.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        vm.state.successMessage,
                        style: const TextStyle(
                          color: AppPalette.accentHover,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
