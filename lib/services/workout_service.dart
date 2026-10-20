import 'package:dio/dio.dart';

import '../models/AI_training.dart';
import '../models/workout.dart';

class WorkoutService {
  final Dio _dio;

  WorkoutService(this._dio);

  Future<List<Workout>> buscarMinhasFichas() async {
    try {
      final response = await _dio.get(
        '/fichas-treino/minhas',
      );

      final List<dynamic> data =
      response.data as List<dynamic>;

      return data
          .map(
            (json) => Workout.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Não foi possível carregar suas fichas.',
      );
    }
  }

  Future<List<Workout>> buscarFichasDoAluno(
      int alunoId,
      ) async {
    try {
      final response = await _dio.get(
        '/fichas-treino/aluno/$alunoId',
      );

      final List<dynamic> data = response.data as List<dynamic>;

      return data
          .map(
            (json) => Workout.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Não foi possível carregar as fichas deste aluno.',
      );
    }
  }

  Future<Workout> salvarTreinoComoFicha({
    required int alunoId,
    required AITraining training,
  }) async {
    try {
      final response = await _dio.post(
        '/fichas-treino',
        data: {
          'alunoId': alunoId,
          'nome': training.name,
          'objetivo': training.objective,
          'duracao': training.duration,
          'exercicios': training.exercises
              .map(
                (exercise) => {
              'nome': exercise.name,
              'series': exercise.sets,
              'repeticoes': exercise.repetitions,
            },
          )
              .toList(),
        },
      );

      return Workout.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            'Não foi possível salvar o treino.',
      );
    }
  }
}