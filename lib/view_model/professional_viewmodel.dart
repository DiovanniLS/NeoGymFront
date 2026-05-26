import 'package:flutter/material.dart';

import '../models/professional.dart';

import '../services/professional_service.dart';

class ProfessionalViewModel
    extends ChangeNotifier {

  final ProfessionalService
  service =
  ProfessionalService();

  List<Professional>
  professionals = [];

  bool isLoading = false;

  Future<void>
  loadProfessionals() async {

    isLoading = true;

    notifyListeners();

    professionals =
    await service
        .getProfessionals();

    isLoading = false;

    notifyListeners();
  }
}