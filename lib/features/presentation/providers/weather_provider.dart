import 'package:flutter/material.dart';
import '../../domain/useCase/get_weather.dart'; 
import '../states/weather_states.dart'; 

class WeatherNotifier extends ChangeNotifier {
  final GetCurrentWeather _getWeatherUseCase; 

  WeatherState _state = WeatherState.initial();
  WeatherState get state => _state;

  WeatherNotifier({required GetCurrentWeather getWeatherUseCase})
      : _getWeatherUseCase = getWeatherUseCase;

  Future<void> fetchWeather(double lat, double lon) async {
    _state = _state.copyWith(
      isLoading: true,
      weather: null, 
      failure: null,
    );
    notifyListeners(); 

    final result = await _getWeatherUseCase.call(
      latitude: lat,
      longitude: lon,
    );

    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          failure: failure, 
          weather: null,
        );
      },
      (weatherEntity) {
        _state = _state.copyWith(
          isLoading: false,
          weather: weatherEntity, 
          failure: null,
        );
      },
    );

    notifyListeners();
  }
  
  void resetState() {
    _state = WeatherState.initial();
    notifyListeners();
  }
}