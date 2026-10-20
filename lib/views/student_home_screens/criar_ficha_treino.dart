import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

import '../../models/exercise.dart';
import '../../models/workout.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final Workout? workout;

  const CreateWorkoutScreen({
    super.key,
    this.workout,
  });

  @override
  State<CreateWorkoutScreen> createState() =>
      _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState
    extends State<CreateWorkoutScreen> {
  final TextEditingController titleController =
  TextEditingController();

  final List<TextEditingController> exerciseControllers = [];
  final List<TextEditingController> setsControllers = [];
  final List<TextEditingController> repsControllers = [];

  List<Exercise> exercises = [];

  bool saving = false;

  @override
  void initState() {
    super.initState();

    if (widget.workout != null) {
      titleController.text = widget.workout!.title;

      exercises = widget.workout!.exercises
          .map(
            (e) => Exercise(
          name: e.name,
          sets: e.sets,
          reps: e.reps,
        ),
      )
          .toList();
    }

    _createControllers();
  }

  void _createControllers() {
    _disposeExerciseControllers();

    exerciseControllers.clear();
    setsControllers.clear();
    repsControllers.clear();

    for (final exercise in exercises) {
      exerciseControllers.add(
        TextEditingController(
          text: exercise.name,
        ),
      );

      setsControllers.add(
        TextEditingController(
          text: exercise.sets.toString(),
        ),
      );

      repsControllers.add(
        TextEditingController(
          text: exercise.reps.toString(),
        ),
      );
    }
  }

  void _disposeExerciseControllers() {
    for (final controller in exerciseControllers) {
      controller.dispose();
    }

    for (final controller in setsControllers) {
      controller.dispose();
    }

    for (final controller in repsControllers) {
      controller.dispose();
    }
  }

  void addExercise() {
    setState(() {
      exercises.add(
        Exercise(
          name: 'Novo exercício',
          sets: 3,
          reps: 10,
        ),
      );

      _createControllers();
    });
  }

  void removeExercise(int index) {
    setState(() {
      exercises.removeAt(index);
      _createControllers();
    });
  }

  Workout _buildWorkout() {
    final updatedExercises = List.generate(
      exercises.length,
          (index) {
        return Exercise(
          name: exerciseControllers[index]
              .text
              .trim(),
          sets: int.tryParse(
            setsControllers[index].text,
          ) ??
              0,
          reps: int.tryParse(
            repsControllers[index].text,
          ) ??
              0,
        );
      },
    );

    return Workout(
      id: widget.workout?.id,
      title: titleController.text.trim(),
      exercises: updatedExercises,
    );
  }

  Future<void> saveWorkout() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      _showMessage(
        'Informe um nome para a ficha.',
      );
      return;
    }

    final workout = _buildWorkout();

    if (workout.exercises.isEmpty) {
      _showMessage(
        'Adicione pelo menos um exercício.',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      /*
       * AQUI entraremos com o backend.
       *
       * Exemplo:
       *
       * final savedWorkout =
       *     await WorkoutService(...)
       *         .salvarFicha(workout);
       *
       * Depois:
       *
       * Navigator.pop(context, savedWorkout);
       */

      // Temporário para validar a tela.
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        workout,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Não foi possível salvar a ficha.',
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    _disposeExerciseControllers();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: widget.workout == null
            ? 'Criar ficha'
            : 'Editar ficha',
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Nome da ficha',
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(
                    index,
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving
                    ? null
                    : addExercise,
                child: const Text(
                  'Adicionar exercício',
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving
                    ? null
                    : saveWorkout,
                child: saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  widget.workout == null
                      ? 'Salvar ficha'
                      : 'Salvar alterações',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(int index) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          TextField(
            controller: exerciseControllers[index],
            decoration: const InputDecoration(
              labelText: 'Exercício',
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: setsControllers[index],
                  keyboardType:
                  TextInputType.number,
                  decoration:
                  const InputDecoration(
                    labelText: 'Séries',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: TextField(
                  controller: repsControllers[index],
                  keyboardType:
                  TextInputType.number,
                  decoration:
                  const InputDecoration(
                    labelText: 'Reps',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              IconButton(
                onPressed: saving
                    ? null
                    : () {
                  removeExercise(index);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}