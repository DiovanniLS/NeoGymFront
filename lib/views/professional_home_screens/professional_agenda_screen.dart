import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/swipeable_card.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/agendamento.dart';

import '../../view_model/agendamento_view_model.dart';
import 'add_agenda_event.dart';

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
      context.read<AgendamentoViewModel>().carregarAgendamentos();
    });
  }

  Future<void> _abrirNovoAtendimento() async {
    final criado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAgendaEvent(),
      ),
    );

    if (!mounted || criado != true) return;

    // O ViewModel já recarrega após a criação.
    // Esta segunda consulta garante a atualização ao retornar à tela.
    await context.read<AgendamentoViewModel>().carregarAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgendamentoViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: UniversalAppBar(title: 'Minha agenda'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoAtendimento,
        backgroundColor: NeoGymColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo atendimento'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: NeoGymColors.primary,
          onRefresh: viewModel.carregarAgendamentos,
          child: _buildBody(viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(AgendamentoViewModel viewModel) {
    final theme = Theme.of(context);

    if (viewModel.loading && viewModel.agendamentos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildIntro(),
          const SizedBox(height: 28),
          const SizedBox(
            height: 90,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const Center(
            child: Text('Carregando seus atendimentos...'),
          ),
        ],
      );
    }

    if (viewModel.error != null && viewModel.agendamentos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildIntro(),
          const SizedBox(height: 30),
          _buildErrorState(viewModel),
        ],
      );
    }

    final agrupados = groupByDay(viewModel.agendamentos);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        _buildIntro(),
        const SizedBox(height: 22),

        _buildSummary(viewModel.agendamentos),

        if (viewModel.error != null) ...[
          const SizedBox(height: 14),
          _buildInlineError(viewModel),
        ],

        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: Text(
                'Seus compromissos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            if (viewModel.loading)
              const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),

        const SizedBox(height: 5),

        Text(
          'Organizados por data e horário.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),

        const SizedBox(height: 18),

        if (agrupados.isEmpty)
          _buildEmptyState()
        else
          ...agrupados.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDayHeader(
                    entry.key,
                    entry.value.length,
                  ),
                  const SizedBox(height: 12),
                  ...entry.value.map(
                        (agendamento) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: buildEventCard(agendamento),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildIntro() {
    final theme = Theme.of(context);
    final agora = DateTime.now();

    const dias = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];

    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    final data =
        '${dias[agora.weekday - 1]}, ${agora.day} de '
        '${meses[agora.month - 1]}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organize sua rotina',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Acompanhe seus atendimentos e mantenha tudo em dia.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: NeoGymColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: NeoGymColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                data,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: NeoGymColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(List<Agendamento> agendamentos) {
    final ativos = agendamentos
        .where((a) =>
    a.status != 'CANCELADA' && a.status != 'CONCLUIDA')
        .length;

    final concluidos = agendamentos
        .where((a) => a.status == 'CONCLUIDA')
        .length;

    final cancelados = agendamentos
        .where((a) => a.status == 'CANCELADA')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildMetric(
            'Em aberto',
            ativos,
            Icons.event_note_rounded,
            NeoGymColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetric(
            'Concluídos',
            concluidos,
            Icons.check_circle_outline_rounded,
            NeoGymColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetric(
            'Cancelados',
            cancelados,
            Icons.cancel_outlined,
            NeoGymColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(
      String titulo,
      int valor,
      IconData icone,
      Color cor,
      ) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 21),
          const SizedBox(height: 10),
          Text(
            '$valor',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String titulo, int quantidade) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
            color: NeoGymColors.primary,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            '$quantidade ${quantidade == 1 ? 'atendimento' : 'atendimentos'}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: NeoGymColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 35,
              color: NeoGymColors.primary,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            'Sua agenda está vazia',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Quando houver atendimentos cadastrados, eles aparecerão aqui.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AgendamentoViewModel viewModel) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 45,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Não foi possível carregar sua agenda',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: viewModel.carregarAgendamentos,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineError(AgendamentoViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NeoGymColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: NeoGymColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Falha ao atualizar os dados. Exibindo os últimos dados carregados.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            onPressed: viewModel.carregarAgendamentos,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tentar novamente',
          ),
        ],
      ),
    );
  }

  Widget buildEventCard(Agendamento agendamento) {
    final status = agendamento.status;
    final concluido = status == 'CONCLUIDA';
    final cancelado = status == 'CANCELADA';
    final corStatus = _corStatus(status);

    return SwipeableCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: corStatus.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.event_note_rounded,
          color: corStatus,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agendamento.titulo,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              decoration: concluido ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Aluno #${agendamento.alunoId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(width: 5),
              Text(
                formatTime(agendamento.dataHora),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: corStatus.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              formatStatus(status),
              style: TextStyle(
                color: corStatus,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      trailing: concluido
          ? const Icon(
        Icons.check_circle_rounded,
        color: NeoGymColors.success,
      )
          : cancelado
          ? const Icon(
        Icons.cancel_rounded,
        color: NeoGymColors.error,
      )
          : IconButton(
        tooltip: 'Marcar como concluído',
        icon: const Icon(Icons.check_circle_outline_rounded),
        color: NeoGymColors.primary,
        onPressed: () => _confirmarConclusao(agendamento),
      ),
      onTap: () => showEventDetails(agendamento),
      onDelete: () => _excluirAgendamento(agendamento),
    );
  }

  Future<void> _confirmarConclusao(
      Agendamento agendamento, {
        VoidCallback? onConcluido,
      }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Concluir atendimento?'),
        content: Text(
          'Deseja marcar "${agendamento.titulo}" como concluído?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Concluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await context
          .read<AgendamentoViewModel>()
          .concluirAgendamento(agendamento.id);

      if (!mounted) return;
      onConcluido?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atendimento concluído com sucesso.'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Erro ao concluir agendamento: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível concluir o atendimento.'),
        ),
      );
    }
  }

  Future<void> _excluirAgendamento(Agendamento agendamento) async {
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
          content: Text('Não foi possível excluir o atendimento.'),
        ),
      );
    }
  }

  void showEventDetails(Agendamento agendamento) {
    final status = agendamento.status;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: NeoGymColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_note_rounded,
                      size: 27,
                      color: NeoGymColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        agendamento.titulo,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              buildDetailRow(
                Icons.person_outline_rounded,
                'Aluno',
                'Aluno #${agendamento.alunoId}',
              ),
              buildDetailRow(
                Icons.calendar_today_rounded,
                'Data',
                formatCompleteDate(agendamento.dataHora),
              ),
              buildDetailRow(
                Icons.access_time_rounded,
                'Horário',
                formatTime(agendamento.dataHora),
              ),
              buildDetailRow(
                Icons.info_outline_rounded,
                'Status',
                formatStatus(status),
              ),
              if (agendamento.descricao != null &&
                  agendamento.descricao!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Descrição',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(agendamento.descricao!),
              ],
              if (status != 'CONCLUIDA' && status != 'CANCELADA') ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      _confirmarConclusao(
                        agendamento,
                        onConcluido: () {
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Marcar como concluído'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(
      IconData icon,
      String title,
      String value,
      ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NeoGymColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: NeoGymColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'CONCLUIDA':
        return NeoGymColors.success;
      case 'CANCELADA':
        return NeoGymColors.error;
      case 'CONFIRMADA':
        return NeoGymColors.primary;
      case 'AGENDADA':
      default:
        return NeoGymColors.warning;
    }
  }

  Map<String, List<Agendamento>> groupByDay(
      List<Agendamento> list,
      ) {
    final Map<String, List<Agendamento>> mapa = {};
    final ordenados = List<Agendamento>.from(list)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    for (final agendamento in ordenados) {
      final chave = formatDay(agendamento.dataHora);
      mapa.putIfAbsent(chave, () => []);
      mapa[chave]!.add(agendamento);
    }

    return mapa;
  }

  String formatDay(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (eventDay == today) return 'Hoje';
    if (eventDay == tomorrow) return 'Amanhã';

    const dias = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];

    final nomeDia = dias[date.weekday - 1];
    final data =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return '${nomeDia[0].toUpperCase()}${nomeDia.substring(1)} • $data';
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