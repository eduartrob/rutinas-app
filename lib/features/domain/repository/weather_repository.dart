import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../entities/weather_entitie.dart';

abstract class WeatherRepository {
   Future<Either<Failure, WeatherEntitie>> getCurrentWeather(
    double latitude, 
    double longitude
  );
}

