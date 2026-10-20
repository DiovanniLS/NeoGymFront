
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/models/agendamento.dart';

import '../../view_model/auth_view_model.dart';
import '../../view_model/agendamento_view_model.dart';

class ProfessionalHomeContent extends StatefulWidget {
  const ProfessionalHomeContent({super.key});

  @override
  State<ProfessionalHomeContent> createState() =>
      _ProfessionalHomeContentState();
}

class _ProfessionalHomeContentState
    extends State<ProfessionalHomeContent> {
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
    final user = context.watch<AuthViewModel>().user;
    final vm = context.watch<AgendamentoViewModel>();

    final agendamentos = vm.agendamentos;
    final nome = user?.nome ?? 'Profissional';

    final agora = DateTime.now();

    final inicioSemana = DateTime(
      agora.year,
      agora.month,
      agora.day,
    ).subtract(Duration(days: agora.weekday - 1));

    final fimSemana = inicioSemana.add(
      const Duration(days: 7),
    );

    final atendimentosSemana = agendamentos.where((a) {
      return !a.dataHora.isBefore(inicioSemana) &&
          a.dataHora.isBefore(fimSemana) &&
          a.status != 'CANCELADA';
    }).length;

    final alunosComAgendamentos = agendamentos
        .where((a) => a.status != 'CANCELADA')
        .map((a) => a.alunoId)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: NeoGymColors.primary,
          onRefresh: vm.carregarAgendamentos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(nome),

                const SizedBox(height: 25),

                const Text(
                  'Visão geral',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 13),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        titulo: 'Atendimentos',
                        subtitulo: 'Nesta semana',
                        valor: vm.error != null
                            ? '—'
                            : '$atendimentosSemana',
                        icone: Icons.calendar_month_rounded,
                        cor: NeoGymColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        titulo: 'Alunos',
                        subtitulo: 'Com agendamentos',
                        valor: vm.error != null
                            ? '—'
                            : '$alunosComAgendamentos',
                        icone: Icons.groups_rounded,
                        cor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _buildSectionHeader(
                  titulo: 'Agenda de hoje',
                  subtitulo: 'Seus próximos atendimentos',
                  acao: 'Ver agenda',
                  onTap: () {
                    Navigator.pushNamed(context, '/agendaPro');
                  },
                ),

                const SizedBox(height: 14),

                _buildAppointmentsCard(
                  agendamentos,
                  loading: vm.loading,
                  error: vm.error,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Acesso rápido',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 13),

                _buildQuickAction(
                  icone: Icons.people_alt_rounded,
                  titulo: 'Meus alunos',
                  descricao: 'Consulte alunos e seus treinos',
                  cor: Colors.deepPurple,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/proClientScreen',
                    );
                  },
                ),

                const SizedBox(height: 10),

                _buildQuickAction(
                  icone: Icons.calendar_month_rounded,
                  titulo: 'Minha agenda',
                  descricao: 'Visualize seus compromissos',
                  cor: NeoGymColors.primary,
                  onTap: () {
                    Navigator.pushNamed(context, '/agendaPro');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String nome) {
    final theme = Theme.of(context);
    final agora = DateTime.now();

    final saudacao = agora.hour < 12
        ? 'Bom dia'
        : agora.hour < 18
        ? 'Boa tarde'
        : 'Boa noite';

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

    final dataFormatada =
        '${dias[agora.weekday - 1]}, ${agora.day} de '
        '${meses[agora.month - 1]}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeoGymColors.primary,
            NeoGymColors.primary.withOpacity(0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: NeoGymColors.primary.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saudacao,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        dataFormatada,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.45),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                _iniciais(nome),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String titulo,
    required String subtitulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 23,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitulo,
            maxLines: 2,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color
                  ?.withOpacity(0.65),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String titulo,
    required String subtitulo,
    required String acao,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(acao),
        ),
      ],
    );
  }

  Widget _buildAppointmentsCard(
      List<Agendamento> agendamentos, {
        required bool loading,
        String? error,
      }) {
    final agora = DateTime.now();

    final atendimentosHoje = agendamentos.where((a) {
      final data = a.dataHora;

      return data.year == agora.year &&
          data.month == agora.month &&
          data.day == agora.day &&
          a.status != 'CANCELADA';
    }).toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final theme = Theme.of(context);

    Widget conteudo;

    if (loading) {
      conteudo = const Padding(
        padding: EdgeInsets.symmetric(vertical: 35),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (error != null) {
      conteudo = Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 35,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            const Text(
              'Não foi possível carregar a agenda.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                context
                    .read<AgendamentoViewModel>()
                    .carregarAgendamentos();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    } else if (atendimentosHoje.isEmpty) {
      conteudo = Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 46,
              color: NeoGymColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tudo tranquilo por aqui!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Você não tem atendimentos agendados para hoje.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color
                    ?.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } else {
      conteudo = Column(
        children: [
          ...atendimentosHoje.take(3).map((agendamento) {
            return _buildAppointmentRow(agendamento);
          }),
          if (atendimentosHoje.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '+ ${atendimentosHoje.length - 3} outros atendimentos',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color
                      ?.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: conteudo,
    );
  }

  Widget _buildAppointmentRow(Agendamento agendamento) {
    final theme = Theme.of(context);
    final corStatus = _corStatus(agendamento.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: NeoGymColors.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatarHora(agendamento.dataHora),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NeoGymColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agendamento.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: corStatus.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatarStatus(agendamento.status),
                    style: TextStyle(
                      color: corStatus,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.disabledColor,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icone,
    required String titulo,
    required String descricao,
    required Color cor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'CONCLUIDA':
        return Colors.teal;
      case 'CONFIRMADA':
        return NeoGymColors.primary;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatarStatus(String status) {
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

  String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }

  String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return 'P';
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first.substring(0, 1)}'
        '${partes.last.substring(0, 1)}'
        .toUpperCase();
  }
}
