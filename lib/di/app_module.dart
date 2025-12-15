// lib/app/app_module.dart

import 'package:http/http.dart' as http;

// Core
import '../core/network/base_api_client.dart';

// Weather feature (existing)
import '../features/data/datasource/service_get.dart';
import '../features/data/datasource/weather_service_impl.dart';
import '../features/data/repository/weather_repository_impl.dart';
import '../features/domain/useCase/get_weather.dart';
import '../features/domain/repository/weather_repository.dart';
import '../features/presentation/providers/weather_provider.dart';

// Auth - Login feature
import '../features/auth/login/data/datasources/login_remote_datasource.dart';
import '../features/auth/login/data/repositories/login_repository_impl.dart';
import '../features/auth/login/domain/repositories/login_repository.dart';
import '../features/auth/login/domain/usecases/login_usecase.dart';
import '../features/auth/login/presentation/providers/login_provider.dart';

// Auth - Register feature
import '../features/auth/register/data/datasources/register_remote_datasource.dart';
import '../features/auth/register/data/repositories/register_repository_impl.dart';
import '../features/auth/register/domain/repositories/register_repository.dart';
import '../features/auth/register/domain/usecases/register_usecase.dart';
import '../features/auth/register/presentation/providers/register_provider.dart';

// Auth - Recovery Password feature
import '../features/auth/recovery_password/data/datasources/recovery_password_remote_datasource.dart';
import '../features/auth/recovery_password/data/repositories/recovery_password_repository_impl.dart';
import '../features/auth/recovery_password/domain/repositories/recovery_password_repository.dart';
import '../features/auth/recovery_password/domain/usecases/recovery_password_usecases.dart';
import '../features/auth/recovery_password/presentation/providers/recovery_password_provider.dart';

// Routines feature
import '../features/routines/data/datasources/routine_remote_datasource.dart';
import '../features/routines/data/repositories/routine_repository_impl.dart';
import '../features/routines/domain/repositories/routine_repository.dart';
import '../features/routines/domain/usecases/routine_usecases.dart';
import '../features/routines/presentation/providers/routines_provider.dart';

/// App module for dependency injection
class AppModule {
  static final AppModule _instance = AppModule._internal();

  factory AppModule() {
    return _instance;
  }
  
  AppModule._internal();

  // Core
  late http.Client httpClient;
  late BaseApiClient apiClient;

  // Weather feature (existing)
  late WeatherNotifier weatherNotifier;
  late GetCurrentWeather getWeatherUseCase;
  late WeatherRepository weatherRepository;
  late WeatherService weatherService;

  // Login feature
  late LoginProvider loginProvider;
  late LoginUseCase loginUseCase;
  late LoginRepository loginRepository;
  late LoginRemoteDatasource loginRemoteDatasource;

  // Register feature
  late RegisterProvider registerProvider;
  late RegisterUseCase registerUseCase;
  late RegisterRepository registerRepository;
  late RegisterRemoteDatasource registerRemoteDatasource;

  // Recovery Password feature
  late RecoveryPasswordProvider recoveryPasswordProvider;
  late ForgotPasswordUseCase forgotPasswordUseCase;
  late VerifyCodeUseCase verifyCodeUseCase;
  late ResetPasswordUseCase resetPasswordUseCase;
  late RecoveryPasswordRepository recoveryPasswordRepository;
  late RecoveryPasswordRemoteDatasource recoveryPasswordRemoteDatasource;

  // Routines feature
  late RoutinesProvider routinesProvider;
  late GetRoutinesUseCase getRoutinesUseCase;
  late CreateRoutineUseCase createRoutineUseCase;
  late UpdateRoutineUseCase updateRoutineUseCase;
  late ToggleRoutineUseCase toggleRoutineUseCase;
  late DeleteRoutineUseCase deleteRoutineUseCase;
  late RoutineRepository routineRepository;
  late RoutineRemoteDatasource routineRemoteDatasource;

  void init() {
    // Core
    httpClient = http.Client();
    apiClient = BaseApiClient();

    // Weather feature (existing)
    weatherService = WeatherServiceImpl(apiClient: apiClient);
    weatherRepository = WeatherRepositoryImpl(weatherService: weatherService);
    getWeatherUseCase = GetCurrentWeather(repository: weatherRepository);
    weatherNotifier = WeatherNotifier(getWeatherUseCase: getWeatherUseCase);

    // Login feature
    loginRemoteDatasource = LoginRemoteDatasourceImpl(apiClient: apiClient);
    loginRepository = LoginRepositoryImpl(remoteDatasource: loginRemoteDatasource);
    loginUseCase = LoginUseCase(repository: loginRepository);
    loginProvider = LoginProvider(loginUseCase: loginUseCase);

    // Register feature
    registerRemoteDatasource = RegisterRemoteDatasourceImpl(apiClient: apiClient);
    registerRepository = RegisterRepositoryImpl(remoteDatasource: registerRemoteDatasource);
    registerUseCase = RegisterUseCase(repository: registerRepository);
    registerProvider = RegisterProvider(registerUseCase: registerUseCase);

    // Recovery Password feature
    recoveryPasswordRemoteDatasource = RecoveryPasswordRemoteDatasourceImpl(apiClient: apiClient);
    recoveryPasswordRepository = RecoveryPasswordRepositoryImpl(remoteDatasource: recoveryPasswordRemoteDatasource);
    forgotPasswordUseCase = ForgotPasswordUseCase(repository: recoveryPasswordRepository);
    verifyCodeUseCase = VerifyCodeUseCase(repository: recoveryPasswordRepository);
    resetPasswordUseCase = ResetPasswordUseCase(repository: recoveryPasswordRepository);
    recoveryPasswordProvider = RecoveryPasswordProvider(
      forgotPasswordUseCase: forgotPasswordUseCase,
      verifyCodeUseCase: verifyCodeUseCase,
      resetPasswordUseCase: resetPasswordUseCase,
    );

    // Routines feature
    routineRemoteDatasource = RoutineRemoteDatasourceImpl(apiClient: apiClient);
    routineRepository = RoutineRepositoryImpl(remoteDatasource: routineRemoteDatasource);
    getRoutinesUseCase = GetRoutinesUseCase(repository: routineRepository);
    createRoutineUseCase = CreateRoutineUseCase(repository: routineRepository);
    updateRoutineUseCase = UpdateRoutineUseCase(repository: routineRepository);
    toggleRoutineUseCase = ToggleRoutineUseCase(repository: routineRepository);
    deleteRoutineUseCase = DeleteRoutineUseCase(repository: routineRepository);
    routinesProvider = RoutinesProvider(
      getRoutinesUseCase: getRoutinesUseCase,
      createRoutineUseCase: createRoutineUseCase,
      updateRoutineUseCase: updateRoutineUseCase,
      toggleRoutineUseCase: toggleRoutineUseCase,
      deleteRoutineUseCase: deleteRoutineUseCase,
    );
  }
}
