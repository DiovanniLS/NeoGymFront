import 'dart:math';

import 'package:flutter/material.dart';
import 'package:neogym/Views/tela_detalhes_exercicios.dart';
import 'package:neogym/models/workout.dart';

import 'criar_ficha_treino.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Fichas")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];

          return Dismissible(
            key: ValueKey(workout.id),
            direction: DismissDirection.endToStart,

            onDismissed: (direction) {
              setState(() {
                workouts.remove(workout);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${workout.title} removido!')),
              );
            },

            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Remover ficha"),
                  content: Text("Deseja remover ${workout.title}?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Remover"),
                    ),
                  ],
                ),
              );
            },

            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF7A18),
                    Color(0xFFFF3D00),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(workout: workout),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orange[100],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        workout.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newWorkout = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
          );

          if (newWorkout != null) {
            setState(() {
              workouts.add(newWorkout);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
