class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String nome;
  final String email;
  final String tipo;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  factory LoginResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoginResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      nome: json['nome'],
      email: json['email'],
      tipo: json['tipo'],
    );
  }
}