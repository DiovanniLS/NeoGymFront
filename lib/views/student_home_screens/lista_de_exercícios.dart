import 'package:flutter/material.dart';
import 'package:neogym/components/swipeable_card.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/workout.dart';
import 'package:neogym/services/api_client.dart';
import 'package:neogym/views/student_home_screens/tela_detalhes_exercicios.dart';
import 'package:provider/provider.dart';

import '../../services/workout_service.dart';
import '../../view_model/workout_view_model.dart';
import 'criar_ficha_treino.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = WorkoutViewModel(
          WorkoutService(ApiClient.dio),
        );

        viewModel.carregarFichas();

        return viewModel;
      },
      child: const _WorkoutListView(),
    );
  }
}

class _WorkoutListView extends StatelessWidget {
  const _WorkoutListView();

  @override
  Widget build(BuildContext context) {
    final viewModel =
    context.watch<WorkoutViewModel>();

    return Scaffold(
      appBar: UniversalAppBar(
        title: 'Minhas fichas',
      ),
      body: _buildBody(
        context,
        viewModel,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Criar ficha',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateWorkoutScreen(),
            ),
          );

          if (context.mounted) {
            await viewModel.carregarFichas();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      WorkoutViewModel viewModel,
      ) {
    if (viewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),

              const SizedBox(height: 16),

              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed:
                viewModel.carregarFichas,
                child: const Text(
                  'Tentar novamente',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (viewModel.workouts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                size: 48,
                color: Colors.grey,
              ),

              SizedBox(height: 16),

              Text(
                'Você ainda não possui fichas de treino.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.carregarFichas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.workouts.length,
        itemBuilder: (context, index) {
          final workout =
          viewModel.workouts[index];

          return _buildWorkoutCard(
            context,
            workout,
          );
        },
      ),
    );
  }

  Widget _buildWorkoutCard(
      BuildContext context,
      Workout workout,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      child: SwipeableCard(
        leading: const Icon(
          Icons.fitness_center,
        ),

        content: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              workout.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${workout.exercises.length} exercícios',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  WorkoutDetailScreen(
                    workout: workout,
                  ),
            ),
          );
        }, onDelete: () {  },
      ),
    );
  }
}