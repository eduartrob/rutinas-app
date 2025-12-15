import 'package:app/core/config/api_config.dart';
import 'package:app/core/network/base_api_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

/// Remote data source for login operations
abstract class LoginRemoteDatasource {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

/// Implementation of login remote data source
class LoginRemoteDatasourceImpl implements LoginRemoteDatasource {
  final BaseApiClient apiClient;

  LoginRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await apiClient.post(
      url: ApiConfig.loginEndpoint,
      body: request.toJson(),
    );
    
    return LoginResponseModel.fromJson(response);
  }
}
