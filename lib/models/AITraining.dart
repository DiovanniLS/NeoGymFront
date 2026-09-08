class AITraining {
  final String name;
  final String objective;
  final int duration;
  final List<AIExercise> exercises;

  AITraining({
    required this.name,
    required this.objective,
    required this.duration,
    required this.exercises,
  });

  factory AITraining.fromJson(
      Map<String, dynamic> json,
      ) {
    return AITraining(
      name: json['name'] ?? '',
      objective: json['objective'] ?? '',
      duration: json['duration'] ?? 0,
      exercises: (json['exercises'] as List?)
          ?.map(
            (e) => AIExercise.fromJson(e),
      )
          .toList() ??
          [],
    );
  }
}

class AIExercise {
  String name;
  int sets;
  int repetitions;

  AIExercise({
    required this.name,
    required this.sets,
    required this.repetitions,
  });

  factory AIExercise.fromJson(
      Map<String, dynamic> json,
      ) {
    return AIExercise(
      name: json['name'] ?? '',
      sets: json['sets'] ?? 0,
      repetitions: json['repetitions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'repetitions': repetitions,
    };
  }
}