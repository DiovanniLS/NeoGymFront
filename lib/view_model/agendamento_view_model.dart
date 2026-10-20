import 'package:flutter/foundation.dart';

import 'package:neogym/models/agendamento.dart';
import 'package:neogym/services/agendamento_service.dart';

class AgendamentoViewModel extends ChangeNotifier {
  final AgendamentoService _service;

  AgendamentoViewModel({
    AgendamentoService? service,
  }) : _service = service ?? AgendamentoService();

  List<Agendamento> _agendamentos = [];

  bool _loading = false;
  String? _error;

  List<Agendamento> get agendamentos => _agendamentos;

  bool get loading => _loading;

  String? get error => _error;

  Future<void> excluirAgendamento(int id) async {
    await _service.excluirAgendamento(id);

    _agendamentos.removeWhere(
          (agendamento) => agendamento.id == id,
    );

    notifyListeners();
  }

  Future<void> carregarAgendamentos() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _agendamentos = await _service.buscarMeusAgendamentos();
    } catch (e) {
      _error = 'Não foi possível carregar os agendamentos.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}