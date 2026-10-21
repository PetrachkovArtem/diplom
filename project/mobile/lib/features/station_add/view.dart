import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/station_add/view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final example = vm.state.urlTemplate.isEmpty ? '' : '${vm.state.urlTemplate}/CP001';

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
                ],
              ),
            ),
    );
  }
}
