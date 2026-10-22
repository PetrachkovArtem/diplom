import 'package:charging_app/core/controls/app_button.dart';
import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/session_current/view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SessionCurrentView extends StatelessWidget {
  const SessionCurrentView({super.key, required this.stationId});

  final String stationId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionCurrentViewModel(stationId),
      child: const _SessionCurrentBody(),
    );
  }
}

class _SessionCurrentBody extends StatelessWidget {
  const _SessionCurrentBody();

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionCurrentViewModel>();
    final s = vm.state.session;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Сессия'),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
      ),
      body: vm.state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppPalette.accent))
          : s == null
          ? const Center(
              child: Text('Нет текущей сессии', style: TextStyle(color: AppPalette.textMuted)),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.stationName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Коннектор №${s.connectorNumber}'),
                  const SizedBox(height: 16),
                  _row('Начало', _fmt(s.startedAt)),
                  _row('Энергия, кВт·ч', s.energyKwh?.toStringAsFixed(2) ?? '0.00'),
                  if (s.endedAt != null) _row('Окончание', _fmt(s.endedAt)),
                  if (vm.state.errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
                  ],
                  const Spacer(),
                  if (s.isCurrent)
                    AppButton(
                      label: 'Стоп',
                      loading: vm.state.isStopping,
                      onPressed: () async {
                        await context.read<SessionCurrentViewModel>().stop();
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppPalette.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
