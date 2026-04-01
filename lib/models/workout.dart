import 'dart:math';

import 'package:neogym/models/exercise.dart';

class Workout {
  final String  id;
  final String title;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.title,
    required this.exercises,
  });
}


final List<Workout> workouts = [
  Workout(
    id: DateTime.now().toString(),
    title: "Peito + Tríceps",
    exercises: [
      Exercise(name: "Supino reto", sets: 4, reps: 10),
      Exercise(name: "Supino inclinado", sets: 3, reps: 12),
      Exercise(name: "Tríceps corda", sets: 3, reps: 12),
    ],
  ),
  Workout(
    id: DateTime.now().toString(),
    title: "Costas + Bíceps",
    exercises: [
      Exercise(name: "Puxada frontal", sets: 4, reps: 10),
      Exercise(name: "Remada curvada", sets: 3, reps: 12),
      Exercise(name: "Rosca direta", sets: 3, reps: 12),
    ],
  ),
];