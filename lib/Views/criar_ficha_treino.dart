import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final TextEditingController titleController = TextEditingController();

  List<Exercise> exercises = [];

  void addExercise() {
    setState(() {
      exercises.add(
        Exercise(name: "Novo exercício", sets: 3, reps: 10),
      );
    });
  }

  void saveWorkout() {
    final workout = Workout(
      id: DateTime.now().toString(),
      title: titleController.text,
      exercises: exercises,
    );

    print("Workout criado: ${workout.title}");

    Navigator.pop(context, workout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar ficha")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Nome da ficha",
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[100],
                    ),
                    child: Column(
                      children: [

                        TextField(
                          decoration: const InputDecoration(
                            labelText: "Exercício",
                          ),
                          onChanged: (value) {
                            exercises[index] = Exercise(
                              name: value,
                              sets: exercises[index].sets,
                              reps: exercises[index].reps,
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Séries",
                                ),
                                onChanged: (value) {
                                  exercises[index] = Exercise(
                                    name: exercises[index].name,
                                    sets: int.tryParse(value) ?? 0,
                                    reps: exercises[index].reps,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Reps",
                                ),
                                onChanged: (value) {
                                  exercises[index] = Exercise(
                                    name: exercises[index].name,
                                    sets: exercises[index].sets,
                                    reps: int.tryParse(value) ?? 0,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            IconButton(
                              onPressed: () {
                                setState(() {
                                  exercises.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: addExercise,
              child: const Text("Adicionar exercício"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: saveWorkout,
              child: const Text("Salvar ficha"),
            ),
          ],
        ),
      ),
    );
  }
}