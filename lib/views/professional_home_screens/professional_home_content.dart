import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_model/AuthViewModel.dart';
import '../../components/card_principal.dart';

class ProfessionalHomeContent extends StatefulWidget {
  const ProfessionalHomeContent({super.key});

  @override
  State<ProfessionalHomeContent> createState() =>
      _ProfessionalHomeContentState();
}

class _ProfessionalHomeContentState
    extends State<ProfessionalHomeContent> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(user?.nome ?? "Profissional"),

                const SizedBox(height: 30),

                _buildAppointmentsCard(),

                const SizedBox(height: 30),

                _buildClientsCard(),

                const SizedBox(height: 30),

                _buildMessagesCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildHeader(String name) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $name 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text(
                'seus atendimentos de hoje',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person),
        ),
      ],
    );
  }

  // 📅 AGENDA
  Widget _buildAppointmentsCard() {
    return CardPrincipal(
      leading: const Icon(Icons.calendar_today, color: Colors.orange),
      title: "Agenda do Dia",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Divider(),
          Text("09:00 • Lucas"),
          SizedBox(height: 8),
          Text("10:00 • Ana"),
          SizedBox(height: 8),
          Text("14:00 • Marcos"),
        ],
      ),
      button: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/agendaPro");
        },
        child: const Text("Ver agenda"),
      ),
    );
  }

  // 👥 CLIENTES
  Widget _buildClientsCard() {
    return CardPrincipal(
      leading: const Icon(Icons.people, color: Colors.blue),
      title: "Clientes",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Clientes ativos"),
              Text(
                "24",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Novos esta semana"),
              Text(
                "3",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "Você possui alunos aguardando retorno 🏋️",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      button: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, "/proClientScreen");
        },
        child: const Text("Ver Clientes"),
      ),
    );
  }

  // 💬 MENSAGENS
  Widget _buildMessagesCard() {
    return CardPrincipal(
      leading: const Icon(Icons.chat, color: Colors.green),
      title: "Mensagens",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mensagens não lidas"),
              Text(
                "5",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "Última mensagem:",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 6),

          const Text(
            "\"Aluno perguntou sobre treino de perna\"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      button: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        child: const Text("Abrir Chat"),
      ),
    );
  }
}