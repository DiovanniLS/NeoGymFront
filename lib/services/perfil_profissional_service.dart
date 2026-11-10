import 'package:dio/dio.dart';
import 'api_client.dart';

class PerfilProfissionalService {
  final Dio _dio;

  PerfilProfissionalService([Dio? dio])
      : _dio = dio ?? ApiClient.dio;

  String _endpoint(bool isNutricionista) {
    return isNutricionista
        ? '/nutricionistas/me'
        : '/personais/me';
  }

  String _mensagemErro(
      DioException e,
      String mensagemPadrao,
      ) {
    final data = e.response?.data;

    if (data is Map) {
      final mensagem = data['message'] ??
          data['mensagem'] ??
          data['error'];

      if (mensagem != null) {
        return mensagem.toString();
      }
    }

    return mensagemPadrao;
  }

  Future<Map<String, dynamic>> buscarMeuPerfil({
    bool isNutricionista = false,
  }) async {
    try {
      final response = await _dio.get(
        _endpoint(isNutricionista),
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensagemErro(
          e,
          'Não foi possível carregar o perfil profissional.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> atualizarMeuPerfil({
    required String especialidade,
    required String apresentacao,
    required String areasAtuacao,
    required String horariosDisponiveis,
    bool isNutricionista = false,
  }) async {
    try {
      final response = await _dio.put(
        _endpoint(isNutricionista),
        data: {
          'especialidade': especialidade,
          'apresentacao': apresentacao,
          'areasAtuacao': areasAtuacao,
          'horariosDisponiveis': horariosDisponiveis,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        _mensagemErro(
          e,
          'Não foi possível salvar o perfil profissional.',
        ),
      );
    }
  }
}