import 'package:app/core/config/api_config.dart';
import 'package:app/core/network/base_api_client.dart';

/// Remote data source for password recovery operations
abstract class RecoveryPasswordRemoteDatasource {
  /// Request password reset - sends code to email
  Future<bool> forgotPassword(String email);
  
  /// Verify reset code
  Future<bool> verifyCode(int code);
  
  /// Reset password with code
  Future<bool> resetPassword(int code, String newPassword);
}

/// Implementation of recovery password remote data source
class RecoveryPasswordRemoteDatasourceImpl implements RecoveryPasswordRemoteDatasource {
  final BaseApiClient apiClient;

  RecoveryPasswordRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<bool> forgotPassword(String email) async {
    final response = await apiClient.post(
      url: ApiConfig.forgotPasswordEndpoint,
      body: {'email': email},
    );
    return response['validation'] == true;
  }

  @override
  Future<bool> verifyCode(int code) async {
    final response = await apiClient.post(
      url: ApiConfig.verifyCodeEndpoint,
      body: {'codeVerification': code},
    );
    return response['validation'] == true;
  }

  @override
  Future<bool> resetPassword(int code, String newPassword) async {
    await apiClient.post(
      url: ApiConfig.resetPasswordEndpoint,
      body: {
        'codeVerification': code,
        'newPassword': newPassword,
      },
    );
    return true;
  }
}
