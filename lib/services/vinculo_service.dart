import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

}