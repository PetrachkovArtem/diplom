abstract final class AppStrings {
  static const String appName = 'Заряди сам';
  static const String serverUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://charging.servertut.ru',
  );
}
