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

  Future<void> concluirAgendamento(int id) async {
    await _dio.patch('/agendamentos/$id/concluir');
  }

  Future<Agendamento> criarAgendamento({
    int? alunoId,
    int? profissionalId,
    required String tipoProfissional,
    required String titulo,
    String? descricao,
    required DateTime dataHora,
  }) async {
    // Exige exatamente um dos IDs, conforme o usuário que cria.
    if ((alunoId == null) == (profissionalId == null)) {
      throw ArgumentError(
        'Informe alunoId ou profissionalId, mas não ambos.',
      );
    }

    final dados = <String, dynamic>{
      'tipoProfissional': tipoProfissional.toUpperCase(),
      'titulo': titulo.trim(),
      'descricao': descricao?.trim().isEmpty == true
          ? null
          : descricao?.trim(),
      'dataHora': dataHora.toIso8601String(),
    };

    if (alunoId != null) {
      dados['alunoId'] = alunoId;
    } else {
      dados['profissionalId'] = profissionalId;
    }

    final response = await _dio.post(
      '/agendamentos',
      data: dados,
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