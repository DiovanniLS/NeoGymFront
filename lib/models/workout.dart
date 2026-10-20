import 'exercise.dart';

class Workout {
  final int? id;
  final String title;
  final int? alunoId;
  final int? personalId;
  final String? objective;
  final int? duration;
  final List<Exercise> exercises;

  Workout({
    this.id,
    required this.title,
    required this.exercises,
    this.alunoId,
    this.personalId,
    this.objective,
    this.duration,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      title: json['nome'] ?? '',
      alunoId: json['alunoId'],
      personalId: json['personalId'],
      objective: json['objetivo'],
      duration: json['duracao'],
      exercises: (json['exercicios'] as List? ?? [])
          .map(
            (e) => Exercise.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': title,
      'alunoId': alunoId,
      'personalId': personalId,
      'objetivo': objective,
      'duracao': duration,
      'exercicios': exercises
          .map((e) => e.toJson())
          .toList(),
    };
  }
}