class UserModel {

  final String nome;

  final String email;

  final String tipo;

  UserModel({
    required this.nome,
    required this.email,
    required this.tipo,
  });

  factory UserModel.fromLoginResponse(
      dynamic response,
      ) {

    return UserModel(

      nome: response.nome,

      email: response.email,

      tipo: response.tipo,
    );
  }
}