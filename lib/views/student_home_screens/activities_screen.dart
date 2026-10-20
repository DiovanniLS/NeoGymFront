import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/swipeable_card.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/agendamento.dart';

import '../../view_model/agendamento_view_model.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendamentoViewModel>().carregarAgendamentos();
    });
  }


  Future<void> _excluirAgendamento(Agendamento agendamento) async {
    try {
      await context
          .read<AgendamentoViewModel>()
          .excluirAgendamento(agendamento.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atividade excluída com sucesso.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir a atividade.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgendamentoViewModel>();

    if (viewModel.loading) {
      return Scaffold(
        appBar: UniversalAppBar(
          title: "Próximas atividades",
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (viewModel.error != null) {
      return Scaffold(
        appBar: UniversalAppBar(
          title: "Próximas atividades",
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  viewModel.error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    viewModel.carregarAgendamentos();
                  },
                  child: const Text("Tentar novamente"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final grouped = groupByDay(viewModel.agendamentos);

    return Scaffold(
      appBar: UniversalAppBar(
        title: "Próximas atividades",
      ),

      body: RefreshIndicator(
        onRefresh: viewModel.carregarAgendamentos,
        child: grouped.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.event_busy,
              size: 60,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                "Nenhuma atividade agendada.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        )
            : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...entry.value.map(
                      (agendamento) => buildCard(agendamento),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            "/addAtiv",
          );

          // Atualiza a lista quando voltar do cadastro
          if (mounted) {
            context
                .read<AgendamentoViewModel>()
                .carregarAgendamentos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, List<Agendamento>> groupByDay(
      List<Agendamento> list,
      ) {
    final Map<String, List<Agendamento>> map = {};

    final sortedList = [...list]
      ..sort(
            (a, b) => a.dataHora.compareTo(b.dataHora),
      );

    for (final item in sortedList) {
      final key = formatDay(item.dataHora);

      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }

    return map;
  }

  Widget buildCard(Agendamento agendamento) {
    final bool concluido =
        agendamento.status == 'CONCLUIDA';

    final bool cancelado =
        agendamento.status == 'CANCELADA';

    final String tipoProfissional =
    agendamento.tipoProfissional == 'PERSONAL'
        ? 'Personal Trainer'
        : 'Nutricionista';

    return SwipeableCard(
      leading: Icon(
        concluido
            ? Icons.check_circle
            : cancelado
            ? Icons.cancel
            : Icons.schedule,
        color: concluido
            ? NeoGymColors.primary
            : cancelado
            ? Colors.red
            : Colors.black,
      ),

      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agendamento.titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration:
              concluido ? TextDecoration.lineThrough : null,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            formatTime(agendamento.dataHora),
          ),

          const SizedBox(height: 2),

          Text(
            agendamento.profissionalNome ?? tipoProfissional,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),

      onTap: () {
        mostrarDetalhesAgendamento(
          context,
          agendamento,
        );
      },

      trailing: Checkbox(
        value: concluido,
        onChanged: null,
      ),

       onDelete: () => _excluirAgendamento(agendamento),
    );
  }

  void mostrarDetalhesAgendamento(
      BuildContext context,
      Agendamento agendamento,
      ) {
    final bool cancelado =
        agendamento.status == 'CANCELADA';

    final String tipoProfissional =
    agendamento.tipoProfissional == 'PERSONAL'
        ? 'Personal Trainer'
        : 'Nutricionista';

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agendamento.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Data: ${formatDate(agendamento.dataHora)}",
              ),

              const SizedBox(height: 6),

              Text(
                "Horário: ${formatTime(agendamento.dataHora)}",
              ),

              const SizedBox(height: 6),

              Text(
                "Profissional: ${agendamento.profissionalNome ?? tipoProfissional}",
              ),

              const SizedBox(height: 6),

              Text(
                "Status: ${agendamento.status}",
                style: TextStyle(
                  color: cancelado ? Colors.red : null,
                ),
              ),

              if (agendamento.descricao != null &&
                  agendamento.descricao!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),

                const Text(
                  "Descrição",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  agendamento.descricao!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String formatDay(DateTime date) {
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Hoje";
    }

    final tomorrow = now.add(
      const Duration(days: 1),
    );

    if (date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year) {
      return "Amanhã";
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}