import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workout.exercises.length,
        itemBuilder: (context, index) {
          final ex = workout.exercises[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey[100],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(ex.name),
                ),
                Text("${ex.sets}x${ex.reps}"),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Iniciar treino"),
        ),
      ),
    );
  }
}