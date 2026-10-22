import 'package:charging_app/core/connector_status_ru.dart';
import 'package:charging_app/core/controls/app_button.dart';
import 'package:charging_app/core/models/station_models.dart';
import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/session_current/view.dart';
import 'package:charging_app/features/session_start/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionStartView extends StatelessWidget {
  const SessionStartView({super.key, required this.station});

  final StationDto station;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionStartViewModel(station),
      child: const _SessionStartBody(),
    );
  }
}

class _SessionStartBody extends StatelessWidget {
  const _SessionStartBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionStartViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text(vm.station.displayName),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Старт сессии', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              vm.station.isOnline ? 'Станция в сети' : 'Станция не в сети',
              style: TextStyle(color: vm.station.isOnline ? AppPalette.accent : AppPalette.danger),
            ),
            const SizedBox(height: 16),
            const Text('Коннектор', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...vm.station.connectors.map((c) {
              final selected = vm.state.selectedConnectorId == c.id;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? AppPalette.accent : AppPalette.textMuted,
                ),
                title: Text('№${c.connectorNumber} — ${connectorStatusRu(c.status)}'),
                selected: selected,
                onTap: () => context.read<SessionStartViewModel>().selectConnector(c.id),
              );
            }),
            if (vm.state.errorMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppPalette.danger.withValues(alpha: 0.3)),
                ),
                child: Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
              ),
              const SizedBox(height: 12),
            ],
            const Spacer(),
            AppButton(
              label: 'Старт',
              loading: vm.state.isSending,
              onPressed: () async {
                final ok = await context.read<SessionStartViewModel>().start();
                if (ok && context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => SessionCurrentView(stationId: vm.station.id),
                    ),
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
