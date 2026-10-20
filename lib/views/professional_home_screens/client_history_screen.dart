import 'package:flutter/material.dart';

import '../../Resources/neo_gym_colors.dart';
import '../../components/universal_app_bar.dart';
import '../../models/agendamento.dart';
import '../../models/professional_client.dart';
import '../../services/agendamento_service.dart';

class ClientHistoryScreen extends StatefulWidget {
  final ProfessionalClient client;

  const ClientHistoryScreen({
    super.key,
    required this.client,
  });

  @override
  State<ClientHistoryScreen> createState() =>
      _ClientHistoryScreenState();
}

class _ClientHistoryScreenState
    extends State<ClientHistoryScreen> {
  final AgendamentoService _service = AgendamentoService();

  late Future<List<Agendamento>> _future;
  String _filtro = 'CONCLUIDA';

  @override
  void initState() {
    super.initState();
    _future = _buscarHistorico();
  }

  Future<List<Agendamento>> _buscarHistorico() async {
    final registros = await _service.buscarAgendamentosDoAluno(
      widget.client.id,
    );

    return registros
        .where(
          (a) =>
      a.status == 'CONCLUIDA' ||
          a.status == 'CANCELADA',
    )
        .toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
  }

  Future<void> _atualizar() async {
    final future = _buscarHistorico();

    setState(() {
      _future = future;
    });

    try {
      await future;
    } catch (_) {
      // O FutureBuilder mostra a mensagem de erro.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: 'Histórico',
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
            return _estadoVazioOuErro(
              icone: Icons.error_outline,
              titulo: 'Não foi possível carregar o histórico',
              descricao: 'Verifique a conexão e tente novamente.',
              botao: ElevatedButton(
                onPressed: _atualizar,
                child: const Text('Tentar novamente'),
              ),
            );
          }

          final registros = snapshot.data ?? [];

          final concluidos = registros
              .where((a) => a.status == 'CONCLUIDA')
              .length;

          final cancelados = registros
              .where((a) => a.status == 'CANCELADA')
              .length;

          final filtrados = registros
              .where((a) => a.status == _filtro)
              .toList();

          return RefreshIndicator(
            onRefresh: _atualizar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  widget.client.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Histórico de atendimentos com você',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _resumo(
                        'Concluídos',
                        concluidos,
                        Icons.check_circle_outline,
                        NeoGymColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _resumo(
                        'Cancelados',
                        cancelados,
                        Icons.event_busy,
                        Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Concluídos'),
                      selected: _filtro == 'CONCLUIDA',
                      onSelected: (_) {
                        setState(() => _filtro = 'CONCLUIDA');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Cancelados'),
                      selected: _filtro == 'CANCELADA',
                      onSelected: (_) {
                        setState(() => _filtro = 'CANCELADA');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (filtrados.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 45),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 58,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _filtro == 'CONCLUIDA'
                              ? 'Nenhum atendimento concluído'
                              : 'Nenhum atendimento cancelado',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Os registros aparecerão aqui quando '
                              'houver atendimentos com esse status.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtrados.map(_cardHistorico),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _resumo(
      String titulo,
      int quantidade,
      IconData icone,
      Color cor,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: cor, size: 25),
            const SizedBox(height: 10),
            Text(
              '$quantidade',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              titulo,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardHistorico(Agendamento agendamento) {
    final concluido = agendamento.status == 'CONCLUIDA';
    final cor = concluido ? NeoGymColors.primary : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: cor.withOpacity(0.12),
          child: Icon(
            concluido ? Icons.check_circle : Icons.event_busy,
            color: cor,
          ),
        ),
        title: Text(
          agendamento.titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatarData(agendamento.dataHora)),
              const SizedBox(height: 3),
              Text(
                '${_formatarHora(agendamento.dataHora)}'
                    ' · ${concluido ? 'Concluído' : 'Cancelado'}',
              ),
              if (agendamento.descricao != null &&
                  agendamento.descricao!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(agendamento.descricao!),
              ],
            ],
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _estadoVazioOuErro({
    required IconData icone,
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
            Icon(icone, size: 48),
            const SizedBox(height: 12),
            Text(titulo, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(descricao, textAlign: TextAlign.center),
            if (botao != null) ...[
              const SizedBox(height: 16),
              botao,
            ],
          ],
        ),
      ),
    );
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
}