
import 'package:flutter_test/flutter_test.dart';
import 'package:neogym/models/agendamento.dart';

void main() {
  group('Agendamento.fromJson', () {
    test('CT01 - Deve converter corretamente um JSON completo', () {
      final json = {
        'id': 10,
        'alunoId': 3,
        'profissionalId': 7,
        'tipoProfissional': 'PERSONAL',
        'profissionalNome': 'Carlos Silva',
        'titulo': 'Avaliação física',
        'descricao': 'Primeira avaliação',
        'dataHora': '2026-11-11T14:30:00',
        'status': 'AGENDADA',
        'criadoEm': '2026-11-10T10:00:00',
      };

      final agendamento = Agendamento.fromJson(json);

      expect(agendamento.id, 10);
      expect(agendamento.alunoId, 3);
      expect(agendamento.profissionalId, 7);
      expect(agendamento.tipoProfissional, 'PERSONAL');
      expect(agendamento.profissionalNome, 'Carlos Silva');
      expect(agendamento.titulo, 'Avaliação física');
      expect(agendamento.descricao, 'Primeira avaliação');
      expect(
        agendamento.dataHora,
        DateTime(2026, 11, 11, 14, 30),
      );
      expect(agendamento.status, 'AGENDADA');
      expect(
        agendamento.criadoEm,
        DateTime(2026, 11, 10, 10),
      );
    });

    test('CT02 - Deve aplicar valores padrão para campos nulos', () {
      final json = {
        'id': 11,
        'alunoId': 4,
        'profissionalId': 8,
        'tipoProfissional': null,
        'profissionalNome': null,
        'titulo': null,
        'descricao': null,
        'dataHora': '2026-11-12T09:00:00',
        'status': null,
        'criadoEm': '2026-11-10T11:00:00',
      };

      final agendamento = Agendamento.fromJson(json);

      expect(agendamento.tipoProfissional, '');
      expect(agendamento.profissionalNome, isNull);
      expect(agendamento.titulo, '');
      expect(agendamento.descricao, isNull);
      expect(agendamento.status, 'AGENDADA');
    });

    test('CT03 - Deve rejeitar uma data inválida', () {
      final json = {
        'id': 12,
        'alunoId': 4,
        'profissionalId': 8,
        'tipoProfissional': 'PERSONAL',
        'profissionalNome': 'Carlos Silva',
        'titulo': 'Avaliação',
        'descricao': null,
        'dataHora': 'data-invalida',
        'status': 'AGENDADA',
        'criadoEm': '2026-11-10T11:00:00',
      };

      expect(
            () => Agendamento.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
