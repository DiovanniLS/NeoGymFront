
import 'package:flutter/material.dart';

import '../../Resources/neo_gym_colors.dart';
import '../../components/universal_app_bar.dart';
import '../../models/agendamento.dart';
import '../../models/professional_client.dart';
import '../../services/agendamento_service.dart';

class ClientAgendaScreen extends StatefulWidget {
  final ProfessionalClient client;

  const ClientAgendaScreen({
    super.key,
    required this.client,
  });

  @override
  State<ClientAgendaScreen> createState() =>
      _ClientAgendaScreenState();
}

class _ClientAgendaScreenState extends State<ClientAgendaScreen> {
  final AgendamentoService _service = AgendamentoService();

  late Future<List<Agendamento>> _future;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _future = _service.buscarAgendamentosDoAluno(
      widget.client.id,
    );
  }

  Future<void> _atualizar() async {
    final future = _service.buscarAgendamentosDoAluno(
      widget.client.id,
    );

    setState(() {
      _future = future;
    });

    try {
      await future;
    } catch (_) {
      // O FutureBuilder apresenta o estado de erro.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: 'Agenda do aluno',
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _mensagem(
              icon: Icons.error_outline,
              titulo: 'Não foi possível carregar a agenda',
              descricao:
              'Verifique sua conexão e tente novamente.',
              botao: ElevatedButton(
                onPressed: _atualizar,
                child: const Text('Tentar novamente'),
              ),
            );
          }

          final agendamentos =
          List<Agendamento>.from(snapshot.data ?? [])
            ..sort(
                  (a, b) =>
                  a.dataHora.compareTo(b.dataHora),
            );

          if (agendamentos.isEmpty) {
            return RefreshIndicator(
              onRefresh: _atualizar,
              child: ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum agendamento encontrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Os atendimentos de ${widget.client.name} '
                        'com você aparecerão aqui.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final grupos = _agruparPorDia(agendamentos);

          return RefreshIndicator(
            onRefresh: _atualizar,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.client.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Agendamentos vinculados ao seu atendimento',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ...grupos.entries.map((entry) {
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...entry.value.map(_cardAgendamento),
                      const SizedBox(height: 18),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cardAgendamento(Agendamento agendamento) {
    final cancelado = agendamento.status == 'CANCELADA';
    final concluido = agendamento.status == 'CONCLUIDA';

    final Color cor = cancelado
        ? Colors.red
        : concluido
        ? NeoGymColors.primary
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withOpacity(0.12),
          child: Icon(
            cancelado
                ? Icons.event_busy
                : concluido
                ? Icons.check_circle_outline
                : Icons.calendar_month,
            color: cor,
          ),
        ),
        title: Text(
          agendamento.titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_formatarData(agendamento.dataHora)} • '
                    '${_formatarHora(agendamento.dataHora)}',
              ),
              const SizedBox(height: 3),
              Text(
                'Status: ${_formatarStatus(agendamento.status)}',
              ),
              if (agendamento.descricao != null &&
                  agendamento.descricao!.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(agendamento.descricao!),
              ],
            ],
          ),
        ),
        isThreeLine: true,
        onTap: () => _mostrarDetalhes(agendamento),
      ),
    );
  }

  void _mostrarDetalhes(Agendamento agendamento) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agendamento.titulo,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Aluno: ${widget.client.name}'),
              const SizedBox(height: 8),
              Text(
                'Data: ${_formatarData(agendamento.dataHora)}',
              ),
              const SizedBox(height: 8),
              Text(
                'Horário: ${_formatarHora(agendamento.dataHora)}',
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${_formatarStatus(agendamento.status)}',
              ),
              if (agendamento.descricao != null &&
                  agendamento.descricao!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Descrição',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(agendamento.descricao!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _mensagem({
    required IconData icon,
    required String titulo,
    required String descricao,
    Widget? botao,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
            ),
            if (botao != null) ...[
              const SizedBox(height: 16),
              botao,
            ],
          ],
        ),
      ),
    );
  }

  Map<String, List<Agendamento>> _agruparPorDia(
      List<Agendamento> agendamentos,
      ) {
    final Map<String, List<Agendamento>> grupos = {};

    for (final agendamento in agendamentos) {
      final chave = _formatarDia(agendamento.dataHora);
      grupos.putIfAbsent(chave, () => []).add(agendamento);
    }

    return grupos;
  }

  String _formatarDia(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dia = DateTime(data.year, data.month, data.day);
    final amanha = hoje.add(const Duration(days: 1));

    if (dia == hoje) return 'Hoje';
    if (dia == amanha) return 'Amanhã';

    return _formatarData(data);
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
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
}
