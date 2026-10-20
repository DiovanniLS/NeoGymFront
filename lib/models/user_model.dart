class UserModel {
  final int usuarioId;
  final String nome;
  final String email;
  final String tipo;

  UserModel({
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  factory UserModel.fromLoginResponse(
      dynamic response,
      ) {
    return UserModel(
      usuarioId: response.usuarioId,
      nome: response.nome,
      email: response.email,
      tipo: response.tipo,
    );
  }
}