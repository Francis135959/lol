import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/cotizacion_repository.dart';

class HistorialCotizacionesViewModel extends ChangeNotifier {
  final CotizacionRepository repository;

  HistorialCotizacionesViewModel(this.repository);

  final Set<String> seleccionadas = {};

  bool estaSeleccionada(String id) => seleccionadas.contains(id);

  void toggleSeleccion(String id) {
    if (seleccionadas.contains(id)) {
      seleccionadas.remove(id);
    } else {
      seleccionadas.add(id);
    }
    notifyListeners();
  }

  void seleccionarMultiples(List<String> ids) {
    seleccionadas.addAll(ids);
    notifyListeners();
  }

  void limpiarSeleccion() {
    seleccionadas.clear();
    notifyListeners();
  }

  Future<void> eliminarSeleccionadas() async {
    if (seleccionadas.isEmpty) return;
    await repository.eliminarCotizaciones(seleccionadas.toList());
    seleccionadas.clear();
    notifyListeners();
  }

  Future<void> eliminarCotizacion(String id) async {
    await repository.eliminarCotizacion(id);
    seleccionadas.remove(id);
    notifyListeners();
  }
}