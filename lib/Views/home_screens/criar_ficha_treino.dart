import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

import '../../models/exercise.dart';
import '../../models/workout.dart';

class CreateWorkoutScreen extends StatefulWidget {

  final Workout? workout;

  const CreateWorkoutScreen({super.key, this.workout});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final TextEditingController titleController = TextEditingController();

  List<Exercise> exercises = [];


  @override
  void initState() {
    super.initState();

    if (widget.workout != null) {
      titleController.text = widget.workout!.title;

      exercises = widget.workout!.exercises.map((e) {
        return Exercise(
          name: e.name,
          sets: e.sets,
          reps: e.reps,
        );
      }).toList();
    } else {
      exercises = [];
    }
  }

  void addExercise() {
    setState(() {
      exercises.add(
        Exercise(name: "Novo exercício", sets: 3, reps: 10),
      );
    });
  }

  void saveWorkout() {
    final updatedWorkout = Workout(
      id: widget.workout?.id ?? DateTime.now().toString(),
      title: titleController.text,
      exercises: exercises,
    );

    Navigator.pop(context, updatedWorkout);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(title: "Criar ficha"),
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
                          controller: TextEditingController(text: ex.name),
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
                                controller: TextEditingController(text: ex.sets.toString()),
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
                                controller: TextEditingController(text: ex.reps.toString()),
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