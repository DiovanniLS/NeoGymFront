import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Resources/neo_gym_colors.dart';
import '../../components/universal_app_bar.dart';
import '../../models/professional_client.dart';
import '../../view_model/auth_view_model.dart';
import '../chat_screen.dart';
import 'client_agenda_screen.dart';
import 'client_history_screen.dart';
import 'client_training_history_screen.dart';
import 'create_training_ai_screen.dart';

class ClientDetailsScreen
    extends StatelessWidget {

  final ProfessionalClient client;

  const ClientDetailsScreen({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: client.name,
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [

            CircleAvatar(
              radius: 45,

              backgroundColor:
              NeoGymColors.primary
                  .withOpacity(0.12),

              child: Text(
                _getInitials(
                  client.name,
                ),

                style: TextStyle(
                  fontSize: 26,
                  color:
                  NeoGymColors.primary,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              client.name,
              style:
              const TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              client.email,
              style:
              const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            _buildOption(
              context,
              icon: Icons.calendar_month,
              title: 'Agendamentos',
              subtitle: 'Ver agenda do aluno',
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

            _buildOption(
              context,
              icon: Icons.fitness_center,
              title: 'Treinos',
              subtitle: 'Visualizar fichas e criar novos treinos',
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

            _buildOption(
              context,
              icon: Icons.history,
              title: 'Histórico',
              subtitle: 'Atendimentos concluídos e cancelados',
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

            _buildOption(
              context,
              icon:
              Icons.chat_outlined,
              title:
              "Mensagem",
              subtitle:
              "Conversar com o aluno",
              onTap: () {
                final user = context.read<AuthViewModel>().user;

                if (user == null) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      name: client.name,
                      Image: '',
                      chatId: _gerarChatId(
                        user.usuarioId,
                        client.usuarioId,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  String _gerarChatId(
      int usuarioA,
      int usuarioB,
      ) {
    final ids = [usuarioA, usuarioB]..sort();

    return 'chat_${ids[0]}_${ids[1]}';
  }

  Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: ListTile(
        onTap: onTap,

        leading: Container(
          width: 45,
          height: 45,

          decoration: BoxDecoration(
            color:
            NeoGymColors.primary
                .withOpacity(0.1),

            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color:
            NeoGymColors.primary,
          ),
        ),

        title: Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w600,
          ),
        ),

        subtitle:
        Text(subtitle),

        trailing:
        const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }

  String _getInitials(
      String name,
      ) {
    final parts =
    name.trim().split(" ");

    if (parts.length == 1) {
      return parts[0][0]
          .toUpperCase();
    }

    return (
        parts.first[0] +
            parts.last[0]
    ).toUpperCase();
  }
}