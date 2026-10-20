import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

class PreferenciasScreen extends StatefulWidget {
  const PreferenciasScreen({super.key});

  @override
  State<PreferenciasScreen> createState() =>
      _PreferenciasScreenState();
}

class _PreferenciasScreenState
    extends State<PreferenciasScreen> {
  bool lembretesTreino = true;
  bool lembretesAgendamento = true;
  bool notificacoesGerais = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UniversalAppBar(
        title: 'Preferências',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notificações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text(
              'Lembretes de treino',
            ),
            subtitle: const Text(
              'Receber lembretes sobre seus treinos',
            ),
            value: lembretesTreino,
            onChanged: (value) {
              setState(() {
                lembretesTreino = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text(
              'Lembretes de agendamento',
            ),
            subtitle: const Text(
              'Avisos sobre atividades agendadas',
            ),
            value: lembretesAgendamento,
            onChanged: (value) {
              setState(() {
                lembretesAgendamento = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text(
              'Notificações gerais',
            ),
            value: notificacoesGerais,
            onChanged: (value) {
              setState(() {
                notificacoesGerais = value;
              });
            },
          ),

          const Divider(height: 30),

          const Text(
            'Aparência',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          ListTile(
            title: const Text('Tema'),
            subtitle: const Text('Claro'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              // Futuramente tema claro/escuro.
            },
          ),
        ],
      ),
    );
  }
}