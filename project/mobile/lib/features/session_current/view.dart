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

  String _soc(double? value) => value == null ? '—' : '${value.toStringAsFixed(2)}%';

  String _cost(double? value) => value == null ? '—' : '${value.toStringAsFixed(2)}р';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionCurrentViewModel>();
    final s = vm.state.session;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text(s?.stationName ?? 'Сессия'),
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
                  if (vm.state.errorMessage.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppPalette.danger.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Коннектор №${s.connectorNumber}'),
                  const SizedBox(height: 16),
                  _row('Начало', _fmt(s.startedAt)),
                  if (s.endedAt != null) _row('Окончание', _fmt(s.endedAt)),
                  _row('Энергия, кВт·ч', s.energyKwh?.toStringAsFixed(2) ?? '0.00'),
                  _row('Уровень заряда', _soc(s.batterySoc)),
                  _row('Стоимость', _cost(s.cost)),
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
