import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/history/view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryViewModel(),
      child: const _HistoryBody(),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('История'),
        backgroundColor: AppPalette.background,
        foregroundColor: AppPalette.text,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppPalette.border),
        ),
      ),
      body: RefreshIndicator(
        color: AppPalette.accent,
        onRefresh: () => context.read<HistoryViewModel>().load(page: 1),
        child: vm.state.isLoading && vm.state.items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 160),
                  Center(child: CircularProgressIndicator(color: AppPalette.accent)),
                ],
              )
            : Column(
                children: [
                  if (vm.state.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(vm.state.errorMessage, style: const TextStyle(color: AppPalette.danger)),
                    ),
                  Expanded(
                    child: vm.state.items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 160),
                              Center(
                                child: Text('История пуста', style: TextStyle(color: AppPalette.textMuted)),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: vm.state.items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final s = vm.state.items[index];
                              final energy = s.energyKwh != null
                                  ? '${s.energyKwh!.toStringAsFixed(3)} кВт·ч'
                                  : 'энергия н/д';
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppPalette.border),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.stationName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text('${_fmt(s.startedAt)} — ${_fmt(s.endedAt)}'),
                                    Text(energy, style: const TextStyle(color: AppPalette.accent)),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  if (vm.state.totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 6,
                        children: List.generate(vm.state.totalPages, (i) {
                          final page = i + 1;
                          final active = page == vm.state.page;
                          return InkWell(
                            onTap: () => context.read<HistoryViewModel>().load(page: page),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: active ? AppPalette.accent : AppPalette.background,
                                border: Border.all(color: active ? AppPalette.accent : AppPalette.border),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$page',
                                style: TextStyle(
                                  color: active ? Colors.white : AppPalette.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
