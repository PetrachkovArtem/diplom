class LoginResponse {
  LoginResponse({
    required this.accessToken,
    required this.email,
    required this.role,
    required this.bindToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        bindToken: json['bindToken'] as String? ?? '',
      );

  final String accessToken;
  final String email;
  final String role;
  final String bindToken;
}

class MeResponse {
  MeResponse({
    required this.id,
    required this.email,
    required this.role,
    required this.bindToken,
    required this.pricePerKwh,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) => MeResponse(
        id: json['id'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        bindToken: json['bindToken'] as String? ?? '',
        pricePerKwh: (json['pricePerKwh'] as num?)?.toDouble() ?? 0,
      );

  final String id;
  final String email;
  final String role;
  final String bindToken;
  final double pricePerKwh;
}
