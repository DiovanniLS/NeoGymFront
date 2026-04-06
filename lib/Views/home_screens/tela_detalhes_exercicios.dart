import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

import '../../models/workout.dart';
import 'criar_ficha_treino.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(title: widget.workout.title),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.workout.exercises.length,
        itemBuilder: (context, index) {
          final ex = widget.workout.exercises[index];

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

      floatingActionButton: FloatingActionButton(
        tooltip: "Editar ficha",
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateWorkoutScreen(workout: widget.workout),
            ),
          );

          if (result != null) {
            setState(() {
              widget.workout.title = result.title;
              widget.workout.exercises = result.exercises;
            });
          }
        },
        child: const Icon(Icons.edit),
      ),

    );
  }
}