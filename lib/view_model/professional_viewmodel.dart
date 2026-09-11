import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../services/professional_service.dart';

class ProfessionalViewModel extends ChangeNotifier {
  final ProfessionalService service;

  ProfessionalViewModel(this.service);

  List<Professional> professionals = [];

  bool isLoading = false;

  Future<void> loadProfessionals() async {
    isLoading = true;
    notifyListeners();

    try {
      professionals = await service.getProfessionals();
    } catch (e) {
      debugPrint('Erro ao carregar profissionais: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}