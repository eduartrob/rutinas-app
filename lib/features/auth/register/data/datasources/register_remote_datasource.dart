import 'package:app/core/config/api_config.dart';
import 'package:app/core/network/base_api_client.dart';
import 'package:app/features/auth/login/data/models/login_response_model.dart';
import '../models/register_request_model.dart';

/// Remote data source for register operations
abstract class RegisterRemoteDatasource {
  Future<LoginResponseModel> register(RegisterRequestModel request);
}

/// Implementation of register remote data source
class RegisterRemoteDatasourceImpl implements RegisterRemoteDatasource {
  final BaseApiClient apiClient;

  RegisterRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    final response = await apiClient.post(
      url: ApiConfig.registerEndpoint,
      body: request.toJson(),
    );
    
    return LoginResponseModel.fromJson(response);
  }
}
