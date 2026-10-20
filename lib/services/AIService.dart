import 'package:dio/dio.dart';
import '../models/AI_training.dart';

class AIService {
  final Dio _dio;

  AIService(this._dio);

  Future<AITraining> gerarTreino({
    required int alunoId,
    required String objetivo,
    required String nivel,
    required int diasSemana,
    required int duracaoMinutos,
    String? observacoes,
  }) async {
    try {
      final response = await _dio.post(
        '/ia/treino',
        data: {
          'alunoId': alunoId,
          'objetivo': objetivo,
          'nivel': nivel,
          'diasSemana': diasSemana,
          'duracaoMinutos': duracaoMinutos,
          'observacoes': observacoes,
        },
      );

      return AITraining.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data?['message'] ??
              'Não foi possível gerar o treino.',
        );
      }

      throw Exception(
        'Não foi possível conectar ao servidor.',
      );
    }
  }
}