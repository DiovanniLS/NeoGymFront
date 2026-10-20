import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

import '../../models/workout.dart';
import 'criar_ficha_treino.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState
    extends State<WorkoutDetailScreen> {
  late Workout _workout;

  @override
  void initState() {
    super.initState();

    _workout = widget.workout;
  }

  Future<void> _editarFicha() async {
    final result = await Navigator.push<Workout>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateWorkoutScreen(
          workout: _workout,
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _workout = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: _workout.title,
      ),

      body: _workout.exercises.isEmpty
          ? const Center(
        child: Text(
          'Nenhum exercício cadastrado.',
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workout.exercises.length,
        itemBuilder: (context, index) {
          final exercise =
          _workout.exercises[index];

          return Container(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(15),
              color: Colors.grey[100],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                  ),
                ),

                Text(
                  '${exercise.sets}x${exercise.reps}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // Próxima etapa:
            // iniciar o treino.
          },
          child: const Text(
            'Iniciar treino',
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Editar ficha',
        onPressed: _editarFicha,
        child: const Icon(Icons.edit),
      ),
    );
  }
}