
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/swipeable_card.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/agendamento.dart';

import '../../view_model/agendamento_view_model.dart';

class ProfessionalAgendaScreen extends StatefulWidget {
  const ProfessionalAgendaScreen({super.key});

  @override
  State<ProfessionalAgendaScreen> createState() =>
      _ProfessionalAgendaScreenState();
}

class _ProfessionalAgendaScreenState
    extends State<ProfessionalAgendaScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<AgendamentoViewModel>()
          .carregarAgendamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgendamentoViewModel>();

    return Scaffold(
      appBar: UniversalAppBar(
        title: 'Minha agenda',
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(AgendamentoViewModel viewModel) {
    if (viewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.error != null) {
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
              const SizedBox(height: 12),
              Text(
                viewModel.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewModel.carregarAgendamentos,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = groupByDay(viewModel.agendamentos);

    return RefreshIndicator(
      onRefresh: viewModel.carregarAgendamentos,
      child: grouped.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(30),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum atendimento agendado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Seus atendimentos aparecerão aqui '
                'quando estiverem cadastrados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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
              ...entry.value.map(buildEventCard),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildEventCard(Agendamento agendamento) {
    final status = agendamento.status;

    final bool concluido = status == 'CONCLUIDA';
    final bool cancelado = status == 'CANCELADA';

    final Color corStatus = concluido
        ? NeoGymColors.primary
        : cancelado
        ? Colors.red
        : Colors.orange;

    final IconData iconeStatus = concluido
        ? Icons.check_circle
        : cancelado
        ? Icons.cancel
        : Icons.schedule;

    return SwipeableCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: corStatus.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.event_note,
          color: corStatus,
        ),
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
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 17,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Aluno #${agendamento.alunoId}',
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 17,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                formatTime(agendamento.dataHora),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Status: ${formatStatus(status)}',
            style: TextStyle(
              color: corStatus,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Icon(
        iconeStatus,
        color: corStatus,
      ),
      onTap: () => showEventDetails(agendamento),

      // O SwipeableCard já deve cuidar da confirmação.
      // Não abra outro modal de confirmação aqui.
      onDelete: () => _excluirAgendamento(agendamento),
    );
  }

  Future<void> _excluirAgendamento(
      Agendamento agendamento,
      ) async {
    try {
      await context
          .read<AgendamentoViewModel>()
          .excluirAgendamento(agendamento.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atendimento excluído com sucesso.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível excluir o atendimento.',
          ),
        ),
      );
    }
  }

  void showEventDetails(Agendamento agendamento) {
    final status = agendamento.status;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agendamento.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              buildDetailRow(
                Icons.person_outline,
                'Aluno',
                'Aluno #${agendamento.alunoId}',
              ),
              buildDetailRow(
                Icons.calendar_today_outlined,
                'Data',
                formatCompleteDate(agendamento.dataHora),
              ),
              buildDetailRow(
                Icons.access_time,
                'Horário',
                formatTime(agendamento.dataHora),
              ),
              buildDetailRow(
                Icons.info_outline,
                'Status',
                formatStatus(status),
              ),
              if (agendamento.descricao != null &&
                  agendamento.descricao!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(agendamento.descricao!),
              ],
              const SizedBox(height: 12),
              if (status != 'CONCLUIDA' &&
                  status != 'CANCELADA')
                const Text(
                  'Para concluir ou cancelar este atendimento, '
                      'a operação precisa ser salva pela API.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDetailRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: NeoGymColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Agendamento>> groupByDay(
      List<Agendamento> list,
      ) {
    final Map<String, List<Agendamento>> map = {};

    final sorted = List<Agendamento>.from(list)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    for (final agendamento in sorted) {
      final key = formatDay(agendamento.dataHora);

      map.putIfAbsent(key, () => []);
      map[key]!.add(agendamento);
    }

    return map;
  }

  String formatDay(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (eventDay == today) return 'Hoje';
    if (eventDay == tomorrow) return 'Amanhã';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String formatCompleteDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatStatus(String status) {
    switch (status) {
      case 'AGENDADA':
        return 'Agendada';
      case 'CONFIRMADA':
        return 'Confirmada';
      case 'CANCELADA':
        return 'Cancelada';
      case 'CONCLUIDA':
        return 'Concluída';
      default:
        return status;
    }
  }
}
