import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/agendamento.dart';
import '../models/hidratacao_local.dart';
import '../models/workout.dart';
import '../repositories/hidratacao_repository.dart';
import '../services/agendamento_service.dart';
import '../services/api_client.dart';
import '../services/workout_service.dart';

class DiaProgresso {
  final String data;
  final String diaSemana;
  final int totalMl;
  final int metaMl;
  final bool registrado;

  const DiaProgresso({
    required this.data,
    required this.diaSemana,
    required this.totalMl,
    required this.metaMl,
    required this.registrado,
  });

  bool get metaAtingida =>
      registrado && totalMl >= metaMl;
}

class ProgressoViewModel extends ChangeNotifier {
  final int usuarioId;

  final AgendamentoService _agendamentoService;
  final WorkoutService _workoutService;
  final HidratacaoRepository _hidratacaoRepository;

  ProgressoViewModel({
    required this.usuarioId,
    AgendamentoService? agendamentoService,
    WorkoutService? workoutService,
    HidratacaoRepository? hidratacaoRepository,
  })  : _agendamentoService =
      agendamentoService ?? AgendamentoService(),
        _workoutService =
            workoutService ?? WorkoutService(ApiClient.dio),
        _hidratacaoRepository =
            hidratacaoRepository ?? HidratacaoRepository();

  bool _loading = false;
  String? _errorMessage;

  List<Agendamento> _agendamentos = [];
  List<Workout> _fichas = [];
  List<DiaProgresso> _ultimosSeteDias = [];

  int _hidratacaoAtualMl = 0;
  int _metaHidratacaoMl = 2500;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  int get hidratacaoAtualMl => _hidratacaoAtualMl;
  int get metaHidratacaoMl => _metaHidratacaoMl;

  List<DiaProgresso> get ultimosSeteDias =>
      List.unmodifiable(_ultimosSeteDias);

  int get fichasDisponiveis => _fichas.length;

  double get percentualHidratacao {
    if (_metaHidratacaoMl <= 0) return 0;

    return (_hidratacaoAtualMl / _metaHidratacaoMl)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  int get agendamentosConcluidosSemana {
    return _agendamentosDaSemana
        .where((item) => item.status == 'CONCLUIDA')
        .length;
  }

  int get agendamentosPendentesSemana {
    return _agendamentosDaSemana.where((item) {
      return item.status == 'AGENDADA' ||
          item.status == 'CONFIRMADA';
    }).length;
  }

  int get totalAgendamentosSemana =>
      _agendamentosDaSemana.length;

  List<Agendamento> get _agendamentosDaSemana {
    final agora = DateTime.now();

    final hoje = DateTime(
      agora.year,
      agora.month,
      agora.day,
    );

    final inicioSemana = hoje.subtract(
      Duration(days: hoje.weekday - 1),
    );

    final fimSemana = inicioSemana.add(
      const Duration(days: 7),
    );

    return _agendamentos.where((item) {
      return !item.dataHora.isBefore(inicioSemana) &&
          item.dataHora.isBefore(fimSemana);
    }).toList();
  }

  int get diasComRegistro {
    return _ultimosSeteDias
        .where((dia) => dia.registrado)
        .length;
  }

  int get diasComMetaAtingida {
    return _ultimosSeteDias
        .where((dia) => dia.metaAtingida)
        .length;
  }

  double get mediaHidratacaoRegistradaMl {
    final diasRegistrados = _ultimosSeteDias
        .where((dia) => dia.registrado)
        .toList();

    if (diasRegistrados.isEmpty) return 0;

    final total = diasRegistrados.fold<int>(
      0,
          (soma, dia) => soma + dia.totalMl,
    );

    return total / diasRegistrados.length;
  }

  Future<void> carregar() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Dados reais da API.
      _agendamentos =
      await _agendamentoService.buscarMeusAgendamentos();

      _fichas =
      await _workoutService.buscarMinhasFichas();

      // Dados locais persistidos no SQLite.
      await _carregarHidratacao();
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar progresso: $e');
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage =
      'Não foi possível carregar seu progresso.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _carregarHidratacao() async {
    final preferencias =
    await _hidratacaoRepository.buscarPreferencias(
      usuarioId,
    );

    _metaHidratacaoMl = preferencias?.metaMl ?? 2500;

    final agora = DateTime.now();

    final hoje = DateTime(
      agora.year,
      agora.month,
      agora.day,
    );

    final dataHoje = _formatarData(hoje);

    // Garante que o dia atual tenha um registro.
    final registroHoje =
    await _hidratacaoRepository.obterOuCriarDia(
      usuarioId: usuarioId,
      data: dataHoje,
      metaMl: _metaHidratacaoMl,
    );

    _hidratacaoAtualMl = registroHoje.totalMl;

    // Busca dados históricos, sem recriar os dias anteriores.
    final historico =
    await _hidratacaoRepository.buscarHistorico(
      usuarioId,
      limite: 30,
    );

    final registrosPorData = <String, HidratacaoDia>{
      for (final registro in historico)
        registro.data: registro,
    };

    final dias = <DiaProgresso>[];

    const nomesDias = [
      'Seg',
      'Ter',
      'Qua',
      'Qui',
      'Sex',
      'Sáb',
      'Dom',
    ];

    for (int i = 6; i >= 0; i--) {
      final data = hoje.subtract(Duration(days: i));
      final chaveData = _formatarData(data);

      final registro = registrosPorData[chaveData];

      dias.add(
        DiaProgresso(
          data: chaveData,
          diaSemana: nomesDias[data.weekday - 1],
          totalMl: registro?.totalMl ?? 0,
          metaMl: registro?.metaMl ?? _metaHidratacaoMl,
          registrado: registro != null,
        ),
      );
    }

    _ultimosSeteDias = dias;
  }

  String _formatarData(DateTime data) {
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');

    return '${data.year}-$mes-$dia';
  }
}