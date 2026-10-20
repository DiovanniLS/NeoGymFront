class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int accessTokenExpiresIn;
  final int refreshTokenExpiresIn;
  final int usuarioId;
  final String nome;
  final String email;
  final String tipo;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.accessTokenExpiresIn,
    required this.refreshTokenExpiresIn,
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'],
      accessTokenExpiresIn: json['accessTokenExpiresIn'],
      refreshTokenExpiresIn: json['refreshTokenExpiresIn'],
      usuarioId: json['usuarioId'],
      nome: json['nome'],
      email: json['email'],
      tipo: json['tipo'],
    );
  }
}