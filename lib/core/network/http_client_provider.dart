import 'package:http/http.dart' as http;

class HttpClientProvider { 
  static final HttpClientProvider _instance = HttpClientProvider._internal();
  late final http.Client client;

  factory HttpClientProvider() {
    return _instance;
  }

  HttpClientProvider._internal() {
    client = http.Client();
  }

  void dispose() {
    client.close();
  }
}