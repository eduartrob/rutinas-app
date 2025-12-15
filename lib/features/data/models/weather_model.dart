import '../../domain/entities/weather_entitie.dart'; 

class WeatherModel {
  final double latitude;
  final double longitude;
  final double temperature; 

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.temperature,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      temperature: json['current_weather']['temperature'] as double,
    );
  }

  WeatherEntitie toEntity() {
    return WeatherEntitie(
      latitude: this.latitude,
      longitude: this.longitude,
      temperature: this.temperature,
    );
  }
}