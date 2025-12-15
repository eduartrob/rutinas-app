// lib/features/data/repository/weather_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/weather_entitie.dart'; 
import '../../domain/repository/weather_repository.dart'; 
import '../datasource/service_get.dart'; 
import '../models/weather_model.dart'; // 💡 CORRECCIÓN: Quitamos 'as data_model'

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService weatherService;

  WeatherRepositoryImpl({required this.weatherService});

  @override
  Future<Either<Failure, WeatherEntitie>> getCurrentWeather(
      double latitude, double longitude) async {
    try {
      final WeatherModel weatherModel = await weatherService.fetchCurrentWeather(
        latitude,
        longitude,
      );
      
      final WeatherEntitie weatherEntity = weatherModel.toEntity();

      return Right(weatherEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}