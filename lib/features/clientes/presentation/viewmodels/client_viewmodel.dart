import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/state/base_state.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

class ClientViewModel extends ChangeNotifier {
  final ClientRepository repository;

  ClientViewModel(this.repository);

  BaseState<List<ClientEntity>> state =
      BaseState.initial();

  StreamSubscription<List<ClientEntity>>?
      _subscription;

  Future<void> cargarClientes() async {
    state = BaseState.loading();

    notifyListeners();

    try {
      final clientes =
          await repository.obtenerClientes();

      state = BaseState.success(clientes);
    } catch (e) {
      state = BaseState.error(e.toString());
    }

    notifyListeners();
  }

  StreamSubscription<List<ClientEntity>>
      watchClientes() {
    _subscription?.cancel();

    _subscription =
        repository.watchClientes().listen(
      (clientes) {
        state = BaseState.success(clientes);

        notifyListeners();
      },
      onError: (error) {
        state = BaseState.error(
          error.toString(),
        );

        notifyListeners();
      },
    );

    return _subscription!;
  }

  Future<void> guardarCliente(
    ClientEntity cliente,
  ) async {
    try {
      await repository.guardarCliente(cliente);
    } catch (e) {
      state = BaseState.error(
        e.toString(),
      );

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }
}