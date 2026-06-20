import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/foundation.dart';

enum EstadoConexion {
  online,
  offline,
  syncing,
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<EstadoConexion> statusNotifier = ValueNotifier(EstadoConexion.online);
  StreamSubscription? _subscription;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    checkInitialConnection();
  }

  Future<void> checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((result) => result != ConnectivityResult.none);
    if (!hasConnection) {
      statusNotifier.value = EstadoConexion.offline;
      return;
    }
    if (statusNotifier.value == EstadoConexion.offline) {
      statusNotifier.value = EstadoConexion.syncing;
      Future.delayed(const Duration(seconds: 2),
        () {
          statusNotifier.value = EstadoConexion.online;
        },
      );
      return;
    }
    statusNotifier.value = EstadoConexion.online;
  }

  void dispose() {
    _subscription?.cancel();
  }
}