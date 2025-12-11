class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:8000";
}

String api(String path) => "${ApiConfig.baseUrl}$path";
