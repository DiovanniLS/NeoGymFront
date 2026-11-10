import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/models/agendamento.dart';

import '../../components/foto_perfil.dart';
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
  static const Color _azul = NeoGymColors.primary;
  static const Color _turquesa = NeoGymColors.primaryDark;
  static const Color _roxo = NeoGymColors.water;
  static const Color _laranja =	NeoGymColors.warning;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AgendamentoViewModel>().carregarAgendamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final vm = context.watch<AgendamentoViewModel>();
    final agendamentos = vm.agendamentos;
    final nomeCompleto = user?.nome.trim() ?? '';
    final nome = nomeCompleto.isEmpty
        ? 'Profissional'
        : nomeCompleto.split(RegExp(r'\s+')).first;

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final inicioSemana = hoje.subtract(
      Duration(days: hoje.weekday - 1),
    );
    final fimSemana = inicioSemana.add(const Duration(days: 7));

    final agendamentosAtivos = agendamentos.where(
          (a) => a.status != 'CANCELADA',
    );

    final atendimentosSemana = agendamentosAtivos.where((a) {
      return !a.dataHora.isBefore(inicioSemana) &&
          a.dataHora.isBefore(fimSemana);
    }).length;

    final alunosComAgendamentos = agendamentosAtivos
        .map((a) => a.alunoId)
        .toSet()
        .length;

    final atendimentosHoje = agendamentos.where((a) {
      return a.dataHora.year == agora.year &&
          a.dataHora.month == agora.month &&
          a.dataHora.day == agora.day &&
          !a.dataHora.isBefore(agora) &&
          a.status != 'CANCELADA';
    }).toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: _azul,
          onRefresh: vm.carregarAgendamentos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(nome),
                const SizedBox(height: 24),

                _buildWelcomeCard(
                  nome: nome,
                  loading: vm.loading,
                  erro: vm.error,
                  atendimentosHoje: atendimentosHoje.length,
                ),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  titulo: 'Visão geral',
                  subtitulo: 'Acompanhe sua rotina profissional',
                  icone: Icons.space_dashboard_rounded,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        titulo: 'Atendimentos',
                        subtitulo: 'Nesta semana',
                        valor: vm.loading
                            ? '...'
                            : vm.error != null
                            ? '—'
                            : '$atendimentosSemana',
                        icone: Icons.calendar_month_rounded,
                        cor: _azul,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        titulo: 'Alunos',
                        subtitulo: 'Com agendamentos',
                        valor: vm.loading
                            ? '...'
                            : vm.error != null
                            ? '—'
                            : '$alunosComAgendamentos',
                        icone: Icons.groups_rounded,
                        cor: _roxo,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  titulo: 'Próximos atendimentos',
                  subtitulo: 'Sua programação para hoje',
                  icone: Icons.event_available_rounded,
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/agendaPro');
                    },
                    child: const Text('Ver agenda'),
                  ),
                ),

                const SizedBox(height: 12),

                _buildAppointmentsCard(
                  atendimentosHoje,
                  loading: vm.loading,
                  error: vm.error,
                  onRetry: vm.carregarAgendamentos,
                ),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  titulo: 'Acesso rápido',
                  subtitulo: 'O que você precisa, a poucos toques',
                  icone: Icons.bolt_rounded,
                ),

                const SizedBox(height: 14),

                _buildQuickAction(
                  icone: Icons.people_alt_rounded,
                  titulo: 'Meus alunos',
                  descricao: 'Consulte alunos e acompanhe seus treinos',
                  cor: _roxo,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/proClientScreen',
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildQuickAction(
                  icone: Icons.calendar_month_rounded,
                  titulo: 'Minha agenda',
                  descricao: 'Consulte seus compromissos e horários',
                  cor: _azul,
                  onTap: () {
                    Navigator.pushNamed(context, '/agendaPro');
                  },
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Seu trabalho transforma vidas. Continue evoluindo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
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

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$saudacao,',
                style: const TextStyle(
                  color: NeoGymColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Vamos organizar seus atendimentos?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: NeoGymColors.primary.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: const FotoPerfil(radius: 27),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard({
    required String nome,
    required bool loading,
    required String? erro,
    required int atendimentosHoje,
  }) {
    final textoStatus = loading
        ? 'Atualizando sua agenda...'
        : erro != null
        ? 'Não foi possível atualizar sua agenda.'
        : atendimentosHoje == 0
        ? 'Você não tem próximos atendimentos hoje.'
        : atendimentosHoje == 1
        ? 'Você tem 1 atendimento pela frente hoje.'
        : 'Você tem $atendimentosHoje atendimentos pela frente hoje.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_azul, _turquesa],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _azul.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'PAINEL PROFISSIONAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Seu trabalho, sua evolução.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.fitness_center_rounded,
                size: 42,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            'Olá, $nome! Organize sua rotina e acompanhe seus alunos.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.93),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.today_rounded,
                  color: Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    textoStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
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
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 13,
            offset: const Offset(0, 5),
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
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 22,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            valor,
            style: TextStyle(
              color: cor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            maxLines: 2,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color
                  ?.withValues(alpha: 0.7),
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _azul.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icone,
            color: _azul,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitulo,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildAppointmentsCard(
      List<Agendamento> agendamentos, {
        required bool loading,
        required String? error,
        required VoidCallback onRetry,
      }) {
    final theme = Theme.of(context);

    Widget conteudo;

    if (loading) {
      conteudo = const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
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
              size: 36,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            const Text(
              'Não foi possível carregar sua agenda.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    } else if (agendamentos.isEmpty) {
      conteudo = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: _azul.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 31,
                color: _azul,
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'Agenda livre por enquanto',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Seus próximos atendimentos aparecerão aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.7),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    } else {
      conteudo = Column(
        children: [
          ...agendamentos.take(3).map(_buildAppointmentRow),
          if (agendamentos.length > 3) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '+ ${agendamentos.length - 3} atendimentos restantes hoje',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color
                      ?.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: conteudo,
    );
  }

  Widget _buildAppointmentRow(Agendamento agendamento) {
    final corStatus = _corStatus(agendamento.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 61,
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _azul.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _formatarHora(agendamento.dataHora),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _azul,
                fontSize: 13,
                fontWeight: FontWeight.w800,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
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
                    _formatarStatus(agendamento.status),
                    style: TextStyle(
                      color: corStatus,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
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
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.23),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 24,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
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
        return _azul;
      case 'CANCELADA':
        return Colors.red;
      default:
        return _laranja;
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
}