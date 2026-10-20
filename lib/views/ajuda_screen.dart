import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

class AjudaScreen extends StatelessWidget {
  const AjudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UniversalAppBar(
        title: 'Ajuda',
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Perguntas frequentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildQuestion(
            'Como encontro um profissional?',
            'Acesse a área de profissionais para visualizar '
                'personais e outros profissionais disponíveis.',
          ),

          _buildQuestion(
            'Como faço um agendamento?',
            'Na tela de atividades, toque no botão +, '
                'selecione um profissional vinculado e informe '
                'data e horário.',
          ),

          _buildQuestion(
            'Como vejo minhas fichas de treino?',
            'Acesse "Minhas fichas" para visualizar as fichas '
                'disponibilizadas pelos profissionais.',
          ),

          _buildQuestion(
            'Como funciona a hidratação?',
            'A hidratação permite registrar seu consumo diário '
                'e acompanhar sua meta de água.',
          ),

          _buildQuestion(
            'Ainda preciso de ajuda',
            'Utilize a opção "Reportar problema" para enviar '
                'uma mensagem para nossa equipe.',
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(
      String title,
      String answer,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}