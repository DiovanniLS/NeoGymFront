import 'package:flutter/foundation.dart';

import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutViewModel extends ChangeNotifier {
  final WorkoutService service;

  WorkoutViewModel(this.service);

  List<Workout> _workouts = [];

  bool _loading = false;
  String? _errorMessage;

  List<Workout> get workouts =>
      List.unmodifiable(_workouts);

  bool get loading => _loading;

  String? get errorMessage => _errorMessage;

  Future<void> carregarFichas() async {
    _loading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _workouts =
      await service.buscarMinhasFichas();
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Workout? get primeiraFicha =>
      _workouts.isEmpty
          ? null
          : _workouts.first;
}