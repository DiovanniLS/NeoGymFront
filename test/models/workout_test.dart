
import 'package:flutter_test/flutter_test.dart';
import 'package:neogym/models/workout.dart';
import 'package:neogym/models/AI_training.dart';

void main() {
  group('Workout', () {
    test('CT04 - Deve converter JSON em Workout', () {
      final workout = Workout.fromJson({
        'id': 1,
        'nome': 'Treino A',
        'alunoId': 10,
        'personalId': 20,
        'objetivo': 'Hipertrofia',
        'duracao': 60,
        'exercicios': [
          {
            'id': 1,
            'nome': 'Supino',
            'series': 3,
            'repeticoes': 12,
            'ordem': 1,
          }
        ],
      });

      expect(workout.id, 1);
      expect(workout.title, 'Treino A');
      expect(workout.exercises.length, 1);
      expect(workout.exercises.first.name, 'Supino');
    });

    test('CT05 - Deve utilizar valores padrão quando campos estiverem ausentes', () {
      final workout = Workout.fromJson({});

      expect(workout.title, '');
      expect(workout.exercises, isEmpty);
    });
  });

  group('AITraining', () {
    test('CT06 - Deve converter JSON em AITraining', () {
      final training = AITraining.fromJson({
        'nome': 'Treino IA',
        'objetivo': 'Condicionamento',
        'duracao': 45,
        'exercicios': [
          {
            'nome': 'Agachamento',
            'series': 3,
            'repeticoes': 15,
          }
        ],
      });

      expect(training.name, 'Treino IA');
      expect(training.objective, 'Condicionamento');
      expect(training.duration, 45);
      expect(training.exercises.first.name, 'Agachamento');
    });

    test('CT07 - Deve utilizar valores padrão quando campos estiverem ausentes', () {
      final training = AITraining.fromJson({});

      expect(training.name, '');
      expect(training.objective, '');
      expect(training.duration, 0);
      expect(training.exercises, isEmpty);
    });
  });
}
