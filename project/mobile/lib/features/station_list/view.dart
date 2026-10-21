import 'package:charging_app/core/connector_status_ru.dart';
import 'package:charging_app/core/palette.dart';
import 'package:charging_app/core/strings.dart';
import 'package:charging_app/features/session_current/view.dart';
import 'package:charging_app/features/session_start/view.dart';
import 'package:charging_app/features/station_add/view.dart';
import 'package:charging_app/features/station_list/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StationListView extends StatelessWidget {
  const StationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StationListViewModel(),
      child: const _StationListBody(),
    );
  }
}

class _StationListBody extends StatelessWidget {
  const _StationListBody();

  Future<void> _rename(BuildContext context, String id, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Имя станции'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Сохранить', style: TextStyle(color: AppPalette.accent)),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      await context.read<StationListViewModel>().rename(id, name);
    }
  }

  Future<void> _delete(BuildContext context, String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удаление'),
        content: Text('Удалить станцию $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: AppPalette.danger)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<StationListViewModel>().delete(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StationListViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              final listVm = context.read<StationListViewModel>();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StationAddView()),
              );
              await listVm.load();
            },
            child: const Text('Добавить', style: TextStyle(color: AppPalette.accent)),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppPalette.border),
        ),
      ),
      body: RefreshIndicator(
        color: AppPalette.accent,
        onRefresh: () => context.read<StationListViewModel>().load(),
        child: vm.state.isLoading && vm.state.stations.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppPalette.accent))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Станции',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  if (vm.state.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
                  ],
                  const SizedBox(height: 12),
                  if (vm.state.stations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('Нет станций. Добавьте первую.', style: TextStyle(color: AppPalette.textMuted)),
                      ),
                    ),
                  ...vm.state.stations.map((s) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppPalette.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            s.isOnline ? 'В сети' : 'Не в сети',
                            style: TextStyle(
                              color: s.isOnline ? AppPalette.accent : AppPalette.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (s.connectors.isEmpty)
                            Text('Коннекторы: ${s.connectorCount}', style: const TextStyle(color: AppPalette.textMuted))
                          else
                            ...s.connectors.map(
                              (c) => Text(
                                'Коннектор №${c.connectorNumber}: ${connectorStatusRu(c.status)}',
                                style: const TextStyle(color: AppPalette.textMuted),
                              ),
                            ),
                          if (s.hasCurrentSession)
                            const Text('Есть текущая сессия', style: TextStyle(color: AppPalette.accent)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () => _rename(context, s.id, s.displayName),
                                child: const Text('Редактировать'),
                              ),
                              OutlinedButton(
                                onPressed: () => _delete(context, s.id, s.displayName),
                                child: const Text('Удалить'),
                              ),
                              if (s.hasCurrentSession)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppPalette.accent),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const SessionCurrentView()),
                                    );
                                  },
                                  child: const Text('К сессии', style: TextStyle(color: Colors.white)),
                                )
                              else if (s.isOnline)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppPalette.accent),
                                  onPressed: () async {
                                    final listVm = context.read<StationListViewModel>();
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => SessionStartView(station: s)),
                                    );
                                    await listVm.load();
                                  },
                                  child: const Text('Зарядка', style: TextStyle(color: Colors.white)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
