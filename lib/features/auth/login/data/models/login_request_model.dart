/// Login request model for API
class LoginRequestModel {
  final String email;
  final String password;
  final String fsmToken;

  LoginRequestModel({
    required this.email,
    required this.password,
    this.fsmToken = '', // Optional for testing
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fsmToken': fsmToken,
    };
  }
}
