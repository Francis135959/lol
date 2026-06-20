import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/state/base_state.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

class ClientesPaginadosViewModel extends ChangeNotifier {
  final ClientRepository repository;

  ClientesPaginadosViewModel(
    this.repository,
  );

  BaseState<List<ClientEntity>> state =
      BaseState.initial();

  final List<ClientEntity> _clientes = [];

  DocumentSnapshot<Map<String, dynamic>>?
      _lastDocument;

  bool _isLoading = false;

  bool _hasMore = true;

  bool get hasMore => _hasMore;

  bool get isLoading => _isLoading;

  Future<void> cargarInicial() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    state = BaseState.loading();

    notifyListeners();

    try {
      _clientes.clear();

      _lastDocument = null;

      _hasMore = true;

      final result =
          await repository.obtenerClientesPaginados(
        limit: 20,
      );

      _clientes.addAll(
        result.clientes,
      );

      _lastDocument =
          result.lastDocument;

      _hasMore =
          result.hasMore;

      state = BaseState.success(
        List.unmodifiable(
          _clientes,
        ),
      );
    } catch (e) {
      state = BaseState.error(
        e.toString(),
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> cargarMas() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    _isLoading = true;

    notifyListeners();

    try {
      final result =
          await repository.obtenerClientesPaginados(
        limit: 20,
        lastDocument:
            _lastDocument,
      );

      _clientes.addAll(
        result.clientes,
      );

      _lastDocument =
          result.lastDocument;

      _hasMore =
          result.hasMore;

      state = BaseState.success(
        List.unmodifiable(
          _clientes,
        ),
      );
    } catch (e) {
      state = BaseState.error(
        e.toString(),
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> eliminarCliente(
    String id,
  ) async {
    await repository.eliminarCliente(
      id,
    );

    _clientes.removeWhere(
      (cliente) => cliente.id == id,
    );

    state = BaseState.success(
      List.unmodifiable(
        _clientes,
      ),
    );

    notifyListeners();
  }

  Future<void> refrescar() async {
    await cargarInicial();
  }
}