import 'package:app/core/config/api_config.dart';
import 'package:app/core/network/base_api_client.dart';
import '../models/routine_model.dart';

/// Remote data source for routine operations
abstract class RoutineRemoteDatasource {
  Future<RoutinesListResponseModel> getRoutines();
  Future<RoutineResponseModel> getRoutineById(String id);
  Future<RoutineResponseModel> createRoutine(Map<String, dynamic> data);
  Future<RoutineResponseModel> updateRoutine(String id, Map<String, dynamic> data);
  Future<RoutineResponseModel> toggleRoutine(String id);
  Future<void> deleteRoutine(String id);
}

/// Implementation of routine remote data source
class RoutineRemoteDatasourceImpl implements RoutineRemoteDatasource {
  final BaseApiClient apiClient;

  RoutineRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<RoutinesListResponseModel> getRoutines() async {
    final response = await apiClient.get(url: ApiConfig.routinesEndpoint);
    return RoutinesListResponseModel.fromJson(response);
  }

  @override
  Future<RoutineResponseModel> getRoutineById(String id) async {
    final response = await apiClient.get(url: ApiConfig.routineByIdEndpoint(id));
    return RoutineResponseModel.fromJson(response);
  }

  @override
  Future<RoutineResponseModel> createRoutine(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      url: ApiConfig.createRoutineEndpoint,
      body: data,
    );
    return RoutineResponseModel.fromJson(response);
  }

  @override
  Future<RoutineResponseModel> updateRoutine(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      url: ApiConfig.updateRoutineEndpoint(id),
      body: data,
    );
    return RoutineResponseModel.fromJson(response);
  }

  @override
  Future<RoutineResponseModel> toggleRoutine(String id) async {
    final response = await apiClient.put(
      url: ApiConfig.toggleRoutineEndpoint(id),
      body: {},
    );
    return RoutineResponseModel.fromJson(response);
  }

  @override
  Future<void> deleteRoutine(String id) async {
    await apiClient.delete(url: ApiConfig.deleteRoutineEndpoint(id));
  }
}
