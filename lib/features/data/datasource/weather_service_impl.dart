
import '../../../core/config/app_secrets.dart';
import '../../../core/network/base_api_client.dart';
import '../models/weather_model.dart';
import 'service_get.dart';


class WeatherServiceImpl implements WeatherService {
  final BaseApiClient _apiClient;

  WeatherServiceImpl({required BaseApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<WeatherModel> fetchCurrentWeather(double latitude, double longitude) async {
    final String baseUrl = AppSecrets.openMeteoBaseUrl;
    const String path = 'forecast';

    final Map<String, dynamic> queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current_weather': 'true',
    };

    try {
      final jsonResponse = await _apiClient.get(
        url: '$baseUrl$path',
        params: queryParameters,
      );
      return WeatherModel.fromJson(jsonResponse);
    } catch (e) {
      rethrow;
    }
  }
}