import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  static String get openMeteoBaseUrl {
    return dotenv.env['BASE_URL_OPEN_METEO'] ?? 'https://default.com/'; 
  }
}