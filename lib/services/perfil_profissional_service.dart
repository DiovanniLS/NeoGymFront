import 'package:dio/dio.dart';
import 'api_client.dart';

class PerfilProfissionalService {
  final Dio _dio;

  PerfilProfissionalService([Dio? dio])
      : _dio = dio ?? ApiClient.dio;

  Future<Map<String, dynamic>> buscarMeuPerfil() async {
    try {
      final response = await _dio.get('/personais/me');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data is Map
            ? e.response?.data['message'] ??
            'Não foi possível carregar o perfil profissional.'
            : 'Não foi possível carregar o perfil profissional.',
      );
    }
  }

  Future<Map<String, dynamic>> atualizarMeuPerfil({
    required String especialidade,
    required String apresentacao,
    required String areasAtuacao,
    required String horariosDisponiveis,
  }) async {
    try {
      final response = await _dio.put(
        '/personais/me',
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
        e.response?.data is Map
            ? e.response?.data['message'] ??
            'Não foi possível salvar o perfil profissional.'
            : 'Não foi possível salvar o perfil profissional.',
      );
    }
  }
}