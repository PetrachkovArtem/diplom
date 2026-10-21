import 'package:charging_app/core/palette.dart';
import 'package:charging_app/features/history/view.dart';
import 'package:charging_app/features/main/view_model.dart';
import 'package:charging_app/features/profile/view.dart';
import 'package:charging_app/features/station_list/view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: const _MainBody(),
    );
  }
}

class _MainBody extends StatelessWidget {
  const _MainBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
    final pages = const [
      StationListView(),
      HistoryView(),
      ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: IndexedStack(index: vm.state.tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: vm.state.tabIndex,
        onDestinationSelected: context.read<MainViewModel>().setTab,
        backgroundColor: AppPalette.background,
        indicatorColor: AppPalette.accentMuted,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.ev_station_outlined),
            selectedIcon: Icon(Icons.ev_station, color: AppPalette.accent),
            label: 'Станции',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppPalette.accent),
            label: 'История',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppPalette.accent),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
