import '../../data/models/weather_model.dart';

abstract class WeatherService {
  Future<WeatherModel> fetchCurrentWeather(double latitude, double longitude);
}