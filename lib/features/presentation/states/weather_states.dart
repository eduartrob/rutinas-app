import '../../../core/error/failures.dart';
import '../../domain/entities/weather_entitie.dart';

class WeatherState {
  final bool isLoading;
  final WeatherEntitie? weather; 
  final Failure? failure;    

  WeatherState({
    required this.isLoading,
    this.weather,
    this.failure,
  });

  // Estado Inicial: Necesario para resetear y arrancar la app
  factory WeatherState.initial() => WeatherState(
    isLoading: false,
    weather: null,
    failure: null,
  );

  // Método para crear una copia inmutable con cambios
  WeatherState copyWith({
    bool? isLoading,
    WeatherEntitie? weather,
    Failure? failure,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather, 
      failure: failure,
    );
  }
}