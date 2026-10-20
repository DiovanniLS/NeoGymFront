class Exercise {
  final int? id;
  final String name;
  final int sets;
  final int reps;
  final int? order;

  Exercise({
    this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.order,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['nome'] ?? '',
      sets: json['series'] ?? 0,
      reps: json['repeticoes'] ?? 0,
      order: json['ordem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'series': sets,
      'repeticoes': reps,
      'ordem': order,
    };
  }
}