/// Register request model for API
class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String fsmToken;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.fsmToken = '', // Optional for testing
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'fsmToken': fsmToken,
    };
  }
}
