class ApiConstants {
  // Change to your machine IP for physical device testing
  // Android emulator: 10.0.2.2
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );
}
