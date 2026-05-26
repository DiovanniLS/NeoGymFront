import 'package:flutter/material.dart';

import '../../components/card_principal.dart';

class ProfessionalHomeContent extends StatefulWidget {

  const ProfessionalHomeContent({
    super.key,
  });

  @override
  State<ProfessionalHomeContent> createState() => _ProfessionalHomeContentState();
}

class _ProfessionalHomeContentState extends State<ProfessionalHomeContent> {
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: const [

                    Text(
                      'Olá, João 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'Você possui 5 atendimentos hoje',
                    ),
                  ],
                ),

                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _buildAppointmentsCard(),

            const SizedBox(height: 20),

            _buildClientsCard(),

            const SizedBox(height: 20),

            _buildMessagesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsCard() {

    return CardPrincipal(

      leading: const Icon(
        Icons.calendar_today,
        color: Colors.orange,
      ),

      title: "Agenda do Dia",

      content: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: const [

          Text("09:00 • Lucas"),
          SizedBox(height: 8),

          Text("10:00 • Ana"),
          SizedBox(height: 8),

          Text("14:00 • Marcos"),
        ],
      ),

      button: ElevatedButton(
        onPressed: () {},
        child: const Text("Ver agenda"),
      ),
    );
  }

  Widget _buildClientsCard() {
    return CardPrincipal(
      leading: const Icon(
        Icons.people,
        color: Colors.blue,
      ),

      title: "Clientes",

      content: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Divider(color: Colors.grey[200]),

          const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [
              Text("Clientes ativos"),
              Text(
                "24",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [
              Text("Novos esta semana"),
              Text(
                "3",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            "Você possui alunos aguardando retorno 🏋️",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),

      button: ElevatedButton(
        onPressed: () {

        },

        child: const Text(
          "Ver Clientes",
        ),
      ),
    );
  }

  Widget _buildMessagesCard() {
    return CardPrincipal(
      leading: const Icon(
        Icons.chat,
        color: Colors.green,
      ),

      title: "Mensagens",

      content: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Divider(color: Colors.grey[200]),

          const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [
              Text("Mensagens não lidas"),
              Text(
                "5",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "Última mensagem:",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "\"Aluno perguntou sobre treino de perna\"",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      button: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/chat',
          );
        },

        child: const Text(
          "Abrir Chat",
        ),
      ),
    );
  }
}