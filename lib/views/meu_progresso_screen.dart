import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/view_model/auth_view_model.dart';
import 'package:neogym/view_model/progresso_view_model.dart';

class MeuProgressoScreen extends StatelessWidget {
  const MeuProgressoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthViewModel>().user;

    if (usuario == null) {
      return Scaffold(
        appBar: UniversalAppBar(
          title: 'Meu progresso',
        ),
        body: const Center(
          child: Text('Faça login para consultar seu progresso.'),
        ),
      );
    }

    return ChangeNotifierProvider(
      key: ValueKey(usuario.usuarioId),
      create: (_) => ProgressoViewModel(
        usuarioId: usuario.usuarioId,
      )..carregar(),
      child: const _MeuProgressoView(),
    );
  }
}

class _MeuProgressoView extends StatelessWidget {
  const _MeuProgressoView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProgressoViewModel>();

    return Scaffold(
      appBar: UniversalAppBar(
        title: 'Meu progresso',
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ProgressoViewModel viewModel,
      ) {
    if (viewModel.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewModel.carregar,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.carregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Resumo da semana',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.check_circle_outline,
                  title: 'Concluídos',
                  value: '${viewModel.agendamentosConcluidosSemana}',
                  subtitle: 'agendamentos',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.calendar_month,
                  title: 'Agendados',
                  value: '${viewModel.agendamentosPendentesSemana}',
                  subtitle: 'pendentes',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _MetricCard(
            icon: Icons.fitness_center,
            title: 'Minhas fichas',
            value: '${viewModel.fichasDisponiveis}',
            subtitle: 'fichas disponíveis',
            wide: true,
          ),

          const SizedBox(height: 28),

          const Text(
            'Hidratação de hoje',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _buildHidratacaoCard(viewModel),

          const SizedBox(height: 28),

          const Text(
            'Últimos 7 dias',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Consumo de água registrado no aplicativo.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          _buildGraficoHidratacao(viewModel),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Média registrada',
                  value:
                  '${(viewModel.mediaHidratacaoRegistradaMl / 1000).toStringAsFixed(1)} L',
                  subtitle: 'por dia registrado',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.flag_outlined,
                  title: 'Meta atingida',
                  value:
                  '${viewModel.diasComMetaAtingida}/${viewModel.diasComRegistro}',
                  subtitle: 'dias registrados',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Os dias sem registro de hidratação não entram na média. '
                'Os agendamentos concluídos representam atividades marcadas '
                'como concluídas no sistema.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHidratacaoCard(
      ProgressoViewModel viewModel,
      ) {
    final atual = viewModel.hidratacaoAtualMl;
    final meta = viewModel.metaHidratacaoMl;

    final litrosAtual = (atual / 1000).toStringAsFixed(1);
    final litrosMeta = (meta / 1000).toStringAsFixed(1);

    final percentual =
    (viewModel.percentualHidratacao * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop,
                color: NeoGymColors.primary,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$litrosAtual L de $litrosMeta L',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$percentual%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: viewModel.percentualHidratacao,
              minHeight: 10,
              color: NeoGymColors.primary,
              backgroundColor: Colors.grey.shade300,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            atual >= meta
                ? 'Meta diária atingida. Parabéns!'
                : 'Faltam ${meta - atual} ml para atingir sua meta.'
                .replaceAllMapped(
              RegExp(r'(\d+)( ml)'),
                  (match) => '${match[1]} ml',
            ),
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoHidratacao(
      ProgressoViewModel viewModel,
      ) {
    final dias = viewModel.ultimosSeteDias;

    final maiorMeta = dias.fold<int>(
      0,
          (maior, dia) => math.max(
        maior,
        math.max(dia.metaMl, dia.totalMl),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dias.map((dia) {
          final proporcao = maiorMeta == 0
              ? 0.0
              : (dia.totalMl / maiorMeta)
              .clamp(0.0, 1.0)
              .toDouble();

          final altura = dia.registrado
              ? math.max(4.0, 76.0 * proporcao)
              : 3.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    dia.registrado
                        ? '${(dia.totalMl / 1000).toStringAsFixed(1)}'
                        : '—',
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 76,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: altura,
                        decoration: BoxDecoration(
                          color: dia.metaAtingida
                              ? NeoGymColors.primary
                              : Colors.blueGrey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    dia.diaSemana,
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool wide;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: NeoGymColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}