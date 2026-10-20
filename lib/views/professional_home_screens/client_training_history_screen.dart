
import 'package:flutter/material.dart';

import '../../Resources/neo_gym_colors.dart';
import '../../components/universal_app_bar.dart';
import '../../models/professional_client.dart';
import '../../models/workout.dart';
import '../../services/api_client.dart';
import '../../services/workout_service.dart';
import '../student_home_screens/tela_detalhes_exercicios.dart';
import 'create_training_ai_screen.dart';

class ClientTrainingHistoryScreen extends StatefulWidget {
  final ProfessionalClient client;

  const ClientTrainingHistoryScreen({
    super.key,
    required this.client,
  });

  @override
  State<ClientTrainingHistoryScreen> createState() =>
      _ClientTrainingHistoryScreenState();
}

class _ClientTrainingHistoryScreenState
    extends State<ClientTrainingHistoryScreen> {
  late final WorkoutService _service;
  late Future<List<Workout>> _future;

  @override
  void initState() {
    super.initState();

    _service = WorkoutService(ApiClient.dio);
    _carregar();
  }

  void _carregar() {
    _future = _service.buscarFichasDoAluno(
      widget.client.id,
    );
  }

  Future<void> _atualizar() async {
    final future = _service.buscarFichasDoAluno(
      widget.client.id,
    );

    setState(() {
      _future = future;
    });

    try {
      await future;
    } catch (_) {
      // O FutureBuilder apresenta o estado de erro.
    }
  }

  Future<void> _criarTreino() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTrainingAIScreen(
          student: widget.client,
        ),
      ),
    );

    if (mounted) {
      await _atualizar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: 'Treinos do aluno',
      ),
      body: FutureBuilder<List<Workout>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _estado(
              icon: Icons.error_outline,
              titulo: 'Erro ao carregar os treinos',
              descricao:
              'Não foi possível carregar as fichas de '
                  '${widget.client.name}.',
              acao: ElevatedButton(
                onPressed: _atualizar,
                child: const Text('Tentar novamente'),
              ),
            );
          }

          final fichas = snapshot.data ?? [];

          if (fichas.isEmpty) {
            return RefreshIndicator(
              onRefresh: _atualizar,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma ficha de treino',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.client.name} ainda não possui '
                        'fichas cadastradas por você.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: FilledButton.icon(
                      onPressed: _criarTreino,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Criar treino com IA'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _atualizar,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.client.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${fichas.length} '
                      '${fichas.length == 1 ? 'ficha cadastrada' : 'fichas cadastradas'}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 18),
                ...fichas.map(_cardTreino),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: NeoGymColors.primary,
        foregroundColor: Colors.white,
        onPressed: _criarTreino,
        icon: const Icon(Icons.add),
        label: const Text('Novo treino'),
      ),
    );
  }

  Widget _cardTreino(Workout workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NeoGymColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: NeoGymColors.primary,
          ),
        ),
        title: Text(
          workout.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${workout.exercises.length} '
                '${workout.exercises.length == 1 ? 'exercício' : 'exercícios'}',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(
                workout: workout,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _estado({
    required IconData icon,
    required String titulo,
    required String descricao,
    Widget? acao,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
            ),
            if (acao != null) ...[
              const SizedBox(height: 16),
              acao,
            ],
          ],
        ),
      ),
    );
  }
}
