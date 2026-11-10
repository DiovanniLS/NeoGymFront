import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/components/foto_usuario.dart';

import '../../models/client_status.dart';
import '../../models/professional_client.dart';
import '../../view_model/auth_view_model.dart';
import '../chat_screen.dart';
import 'client_agenda_screen.dart';
import 'client_history_screen.dart';
import 'client_training_history_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  final ProfessionalClient client;

  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const UniversalAppBar(
        title: 'Perfil do aluno',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(context),

              const SizedBox(height: 30),

              Text(
                'Gerenciar aluno',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Acesse as informações e atividades deste aluno.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 17),

              _buildOption(
                context,
                icon: Icons.calendar_month_rounded,
                title: 'Agendamentos',
                subtitle: 'Consulte os horários e compromissos',
                color: NeoGymColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientAgendaScreen(
                        client: client,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildOption(
                context,
                icon: Icons.fitness_center_rounded,
                title: 'Treinos',
                subtitle: 'Visualize fichas e acompanhe os treinos',
                color: NeoGymColors.water,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientTrainingHistoryScreen(
                        client: client,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildOption(
                context,
                icon: Icons.history_rounded,
                title: 'Histórico',
                subtitle: 'Veja os atendimentos anteriores',
                color: NeoGymColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientHistoryScreen(
                        client: client,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildOption(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Mensagem',
                subtitle: 'Converse diretamente com o aluno',
                color: NeoGymColors.primaryDark,
                onTap: () => _abrirChat(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final statusColor = _statusColor(client.status, context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            NeoGymColors.primary,
            NeoGymColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: NeoGymColors.primary.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 2,
              ),
            ),
            child: FotoUsuario(
              key: ValueKey(client.usuarioId),
              usuarioId: client.usuarioId,
              width: 92,
              height: 92,
              borderRadius: 1000,
              iconSize: 42,
            ),
          ),

          const SizedBox(height: 17),

          Text(
            client.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            client.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _statusLabel(client.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _abrirChat(context),
              icon: const Icon(
                Icons.chat_rounded,
                size: 18,
              ),
              label: const Text('Conversar com aluno'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: theme.colorScheme.outline
                  .withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirChat(BuildContext context) {
    final user = context.read<AuthViewModel>().user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar o usuário logado.'),
        ),
      );
      return;
    }

    if (user.usuarioId == client.usuarioId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não é possível iniciar uma conversa consigo mesmo.'),
        ),
      );
      return;
    }

    final ids = [user.usuarioId, client.usuarioId]..sort();
    final chatId = 'chat_${ids[0]}_${ids[1]}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          name: client.name,
          Image: '',
          usuarioId: client.usuarioId,
          chatId: chatId,
        ),
      ),
    );
  }

  Color _statusColor(ClientStatus status, BuildContext context) {
    switch (status) {
      case ClientStatus.active:
        return NeoGymColors.success;
      case ClientStatus.pending:
        return NeoGymColors.warning;
      case ClientStatus.inactive:
        return Theme.of(context).colorScheme.onSurface
            .withValues(alpha: 0.65);
    }
  }

  String _statusLabel(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return 'Vínculo ativo';
      case ClientStatus.pending:
        return 'Vínculo pendente';
      case ClientStatus.inactive:
        return 'Vínculo inativo';
    }
  }
}