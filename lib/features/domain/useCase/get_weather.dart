import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/weather_entitie.dart';
import '../repository/weather_repository.dart';


class GetCurrentWeather {
  final WeatherRepository repository;

  GetCurrentWeather({required this.repository});

  Future<Either<Failure, WeatherEntitie>> call({
    required double latitude,
    required double longitude,
  }) async {
    return await repository.getCurrentWeather(latitude, longitude);
  }
}