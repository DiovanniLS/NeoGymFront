import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/client_status.dart';
import '../models/professional.dart';
import '../models/professional_client.dart';
import 'api_client.dart';

class VinculoService {
  final Dio dio = ApiClient.dio;

  Future<void> solicitarVinculo({
    required int profissionalUsuarioId,
    required String tipoProfissional,
  }) async {
    try {
      await dio.post(
        '/vinculos',
        data: {
          'profissionalUsuarioId': profissionalUsuarioId,
          'tipoProfissional': tipoProfissional,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
    } on DioException catch (e) {
      debugPrint('Erro ao solicitar vínculo: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Resposta: ${e.response?.data}');
      rethrow;
    }
  }

  Future<String?> consultarStatusVinculo({
    required int outroUsuarioId,
  }) async {
    try {
      final response = await dio.get(
        '/vinculos/status/$outroUsuarioId',
      );

      if (response.data['existe'] != true) {
        return null;
      }

      return response.data['status']?.toString();
    } on DioException catch (e) {
      debugPrint('Erro ao consultar vínculo: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Resposta: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<ProfessionalClient>> buscarAlunosVinculados() async {
    final response = await dio.get('/vinculos/alunos');

    final List<dynamic> data = response.data;

    return data.map((item) {
      return ProfessionalClient(
        id: item['alunoId'],
        usuarioId: item['usuarioId'],
        name: item['nome'] ?? '',
        email: item['email'] ?? '',
        status: ClientStatus.active,
        lastActivity: 'Cliente vinculado',
      );
    }).toList();
  }

  Future<List<Professional>> buscarProfissionaisVinculados() async {
    try {
      final response = await dio.get('/vinculos/profissionais');

      final List<dynamic> data = response.data;

      return data.map((item) {
        return Professional(
          id: item['vinculoId']?.toString() ?? '',
          usuarioId: (item['usuarioId'] as num?)?.toInt() ?? 0,
          name: item['nome'] ?? '',
          specialty: 'Personal Trainer',
          rating: 0,
          image: '',
          distance: 0,
          isOnline: false,
          type: 'PERSONAL',
          lat: null,
          lng: null,
          radiusKm: 5,
          workplaces: const [],
        );
      }).toList();
    } on DioException catch (e) {
      debugPrint('Erro ao buscar Personais vinculados: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Resposta: ${e.response?.data}');
      rethrow;
    }
  }

}