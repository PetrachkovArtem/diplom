import 'package:charging_app/core/palette.dart';
import 'package:charging_app/core/strings.dart';
import 'package:charging_app/features/login/view.dart';
import 'package:charging_app/features/main/view.dart';
import 'package:charging_app/services/user.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasToken = await UserServiceManager.instance.hasToken();
  runApp(ChargingApp(isAuthenticated: hasToken));
}

class ChargingApp extends StatelessWidget {
  const ChargingApp({super.key, required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppPalette.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.accent,
          primary: AppPalette.accent,
          surface: AppPalette.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppPalette.background,
          foregroundColor: AppPalette.text,
          elevation: 0,
        ),
      ),
      home: isAuthenticated ? const MainView() : const LoginView(),
    );
  }
}
