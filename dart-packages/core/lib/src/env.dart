class AppEnv {
  final String apiBaseUrl;

  const AppEnv({required this.apiBaseUrl});

  String get apiV1 => '$apiBaseUrl/api/v1';
}
