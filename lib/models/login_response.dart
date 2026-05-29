class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String nome;
  final String email;
  final String tipo;
  final int usuarioId;
  final String tokenType;
  final int accessTokenExpiresIn;
  final int refreshTokenExpiresIn;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.usuarioId,
    required this.tokenType,
    required this.accessTokenExpiresIn,
    required this.refreshTokenExpiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      tipo: json['tipo'] ?? '',
      usuarioId: json['usuarioId'] ?? 0,
      tokenType: json['tokenType'] ?? '',
      accessTokenExpiresIn: json['accessTokenExpiresIn'] ?? 0,
      refreshTokenExpiresIn: json['refreshTokenExpiresIn'] ?? 0,
    );
  }
}