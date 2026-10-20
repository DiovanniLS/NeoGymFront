import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/hidratacao_repository.dart';

class StudentHomeViewModel extends ChangeNotifier {
  // Chaves antigas: usadas somente na migração para SQLite.
  static const String _waterDateKey = 'home_water_date';
  static const String _waterConsumedKey = 'home_water_consumed';
  static const String _waterGoalKey = 'home_water_goal';
  static const String _waterStepKey = 'home_water_step';

  static const String _sqliteMigrationKey =
      'home_water_sqlite_migrated_v1';

  final int usuarioId;
  final HidratacaoRepository _hidratacaoRepository;

  StudentHomeViewModel({
    required this.usuarioId,
    HidratacaoRepository? hidratacaoRepository,
  }) : _hidratacaoRepository =
      hidratacaoRepository ?? HidratacaoRepository();

  double _currentWater = 0;
  double _goalWater = 2.5;
  double _waterStep = 0.2;

  bool _loading = false;
  bool _syncingWater = false;

  String? _errorMessage;

  double get currentWater => _currentWater;
  double get goalWater => _goalWater;
  double get waterStep => _waterStep;

  bool get loading => _loading;
  bool get syncingWater => _syncingWater;
  String? get errorMessage => _errorMessage;

  double get waterProgress {
    if (_goalWater <= 0) return 0;

    return (_currentWater / _goalWater)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  bool get waterGoalReached =>
      _currentWater >= _goalWater;

  int get currentWaterMl =>
      (_currentWater * 1000).round();

  int get goalWaterMl =>
      (_goalWater * 1000).round();

  int get waterStepMl =>
      (_waterStep * 1000).round();

  Future<void> carregarDados() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _carregarHidratacaoLocal();
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar dados da Home: $e');
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage = 'Não foi possível carregar os dados.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _carregarHidratacaoLocal() async {
    final prefs = await SharedPreferences.getInstance();

    final migracaoConcluida =
        prefs.getBool(_sqliteMigrationKey) ?? false;

    // 1. Carrega as preferências do SQLite.
    final preferencias =
    await _hidratacaoRepository.buscarPreferencias(
      usuarioId,
    );

    if (preferencias != null) {
      _goalWater = preferencias.metaMl / 1000.0;
      _waterStep = preferencias.passoMl / 1000.0;
    } else {
      // 2. Na primeira inicialização, recupera as configurações
      // antigas do SharedPreferences.
      _goalWater = migracaoConcluida
          ? 2.5
          : prefs.getDouble(_waterGoalKey) ?? 2.5;

      _waterStep = migracaoConcluida
          ? 0.2
          : prefs.getDouble(_waterStepKey) ?? 0.2;

      await _salvarPreferenciasLocal();
    }

    // 3. Migra o último registro antigo uma única vez.
    if (!migracaoConcluida) {
      final dataAntiga = prefs.getString(_waterDateKey);
      final consumoAntigo =
      prefs.getDouble(_waterConsumedKey);

      if (dataAntiga != null && consumoAntigo != null) {
        final registroExistente =
        await _hidratacaoRepository.buscarDia(
          usuarioId: usuarioId,
          data: dataAntiga,
        );

        if (registroExistente == null) {
          final metaAntiga =
              prefs.getDouble(_waterGoalKey) ?? _goalWater;

          await _hidratacaoRepository.salvarDia(
            usuarioId: usuarioId,
            data: dataAntiga,
            totalMl: (consumoAntigo * 1000)
                .round()
                .clamp(0, 1000000),
            metaMl: (metaAntiga * 1000).round(),
          );
        }
      }

      // Só marcamos como migrado depois das operações anteriores.
      await prefs.setBool(
        _sqliteMigrationKey,
        true,
      );
    }

    // 4. Carrega ou cria o registro do dia atual.
    // O registro antigo de outro dia continua no histórico.
    final hoje = _dataHoje();

    final registroHoje =
    await _hidratacaoRepository.obterOuCriarDia(
      usuarioId: usuarioId,
      data: hoje,
      metaMl: goalWaterMl,
    );

    _currentWater = registroHoje.totalMl / 1000.0;
  }

  Future<void> adicionarAgua() async {
    if (_loading) return;

    _currentWater = (_currentWater + _waterStep)
        .clamp(0.0, _goalWater)
        .toDouble();

    await _salvarConsumoLocal();

    notifyListeners();

    if (waterGoalReached) {
      await _sincronizarHidratacao();
    }
  }

  Future<void> alterarMetaAgua(double novaMeta) async {
    if (novaMeta <= 0) return;

    _goalWater = novaMeta;

    await _salvarPreferenciasLocal();

    // Preserva o consumo e atualiza a meta do dia atual.
    await _salvarConsumoLocal();

    notifyListeners();

    if (waterGoalReached) {
      await _sincronizarHidratacao();
    }
  }

  Future<void> alterarQuantidadePorVez(
      double novaQuantidade,
      ) async {
    if (novaQuantidade <= 0) return;

    _waterStep = novaQuantidade;

    await _salvarPreferenciasLocal();

    notifyListeners();
  }

  Future<void> _salvarPreferenciasLocal() async {
    await _hidratacaoRepository.salvarPreferencias(
      usuarioId: usuarioId,
      metaMl: goalWaterMl,
      passoMl: waterStepMl,
    );
  }

  Future<void> _salvarConsumoLocal() async {
    await _hidratacaoRepository.salvarDia(
      usuarioId: usuarioId,
      data: _dataHoje(),
      totalMl: currentWaterMl,
      metaMl: goalWaterMl,
    );
  }

  Future<void> _sincronizarHidratacao() async {
    // A persistência local já acontece no SQLite.
    //
    // Quando houver um endpoint próprio de hidratação,
    // a sincronização com o backend será implementada aqui.
  }

  String _dataHoje() {
    final agora = DateTime.now();

    final mes = agora.month.toString().padLeft(2, '0');
    final dia = agora.day.toString().padLeft(2, '0');

    return '${agora.year}-$mes-$dia';
  }
}