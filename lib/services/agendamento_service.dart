import 'package:dio/dio.dart';

import 'package:neogym/models/agendamento.dart';
import 'package:neogym/services/api_client.dart';

class AgendamentoService {
  final Dio _dio;

  AgendamentoService([Dio? dio]) : _dio = dio ?? ApiClient.dio;

  Future<List<Agendamento>> buscarMeusAgendamentos() async {
    final response = await _dio.get('/agendamentos/minhas');

    final List<dynamic> data = response.data;

    return data
        .map(
          (json) => Agendamento.fromJson(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }

  Future<void> excluirAgendamento(int id) async {
    await _dio.delete('/agendamentos/$id');
  }

  Future<Agendamento> criarAgendamento({
    required int profissionalId,
    required String tipoProfissional,
    required String titulo,
    String? descricao,
    required DateTime dataHora,
  }) async {
    final response = await _dio.post(
      '/agendamentos',
      data: {
        'profissionalId': profissionalId,
        'tipoProfissional': tipoProfissional,
        'titulo': titulo,
        'descricao': descricao,
        'dataHora': dataHora.toIso8601String(),
      },
    );

    return Agendamento.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<List<Agendamento>> buscarAgendamentosDoAluno(
      int alunoId,
      ) async {
    final response = await _dio.get(
      '/agendamentos/aluno/$alunoId',
    );

    final List<dynamic> data = response.data;

    return data
        .map(
          (json) => Agendamento.fromJson(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }

}