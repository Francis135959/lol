import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

import '../../utils/client_validators.dart';

enum AccionTipo {
  nuevo,
  actualizar,
  restaurar,
}

class ClientFormViewModel extends ChangeNotifier {
  final ClientRepository repository;

  ClientFormViewModel(
    this.repository,
  );

  final nombreController =
      TextEditingController();

  final rutController =
      TextEditingController();

  final telefonoController =
      TextEditingController();

  final correoController =
      TextEditingController();

  String? nombreError;
  String? rutError;
  String? telefonoError;
  String? correoError;

  bool loading = false;

  String? clienteExistenteId;

  bool clienteAutocompletado = false;

  bool clienteEliminado = false;

  bool modoEdicion = false;

  ClientEntity? clienteExistente;

  Timer? rutDebounce;

  AccionTipo get accionTipo {

    if (modoEdicion) {
      return AccionTipo.actualizar;
    }

    if (clienteAutocompletado) {

      if (clienteEliminado) {
        return AccionTipo.restaurar;
      }

      return AccionTipo.actualizar;
    }

    return AccionTipo.nuevo;
  }

  String get botonTexto {

    switch (accionTipo) {

      case AccionTipo.nuevo:
        return 'Guardar cliente';

      case AccionTipo.actualizar:
        return 'Guardar cambios';

      case AccionTipo.restaurar:
        return 'Restaurar cliente';
    }
  }

  IconData get botonIcono {

    switch (accionTipo) {

      case AccionTipo.nuevo:
        return Icons.add;

      case AccionTipo.actualizar:
        return Icons.save;

      case AccionTipo.restaurar:
        return Icons.restore;
    }
  }

  String get mensajeTexto {

    if (clienteEliminado) {

      return 'Cliente eliminado anteriormente. Al guardar se restaurará.';
    }

    if (clienteAutocompletado && !modoEdicion) {

      return 'Cliente existente. Datos autocompletados.';
    }

    return '';
  }

  IconData get mensajeIcono {

    if (clienteEliminado) {
      return Icons.warning_amber_rounded;
    }

    return Icons.info_outline;
  }

  void cargarClienteParaEditar(
    ClientEntity cliente,
  ) {

    modoEdicion = true;

    clienteExistenteId = cliente.id;

    clienteExistente = cliente;

    clienteAutocompletado = false;

    clienteEliminado = false;

    nombreController.text = cliente.nombre;

    rutController.text = cliente.rut;

    telefonoController.text = cliente.telefono;

    correoController.text = cliente.correo;

    validarNombre(cliente.nombre);

    validarRut(cliente.rut);

    validarTelefono(cliente.telefono);

    validarCorreo(cliente.correo);

    notifyListeners();
  }

  void onRutChanged(
    String value,
  ) {

    validarRut(value);

    if (modoEdicion) {
      return;
    }

    rutDebounce?.cancel();

    rutDebounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        await buscarRut();
      },
    );
  }

  Future<void> buscarRut() async {

    final rut =
        rutController.text.trim();

    if (!ClientValidators.esRutValido(rut)) {

      _limpiarAutocompletado();

      notifyListeners();

      return;
    }

    try {

      final cliente =
          await repository.buscarPorRut(rut);

      if (cliente == null) {

        _limpiarAutocompletado();

        notifyListeners();

        return;
      }

      clienteExistenteId = cliente.id;

      clienteExistente = cliente;

      clienteAutocompletado = true;

      clienteEliminado = cliente.isDeleted;

      nombreController.text = cliente.nombre;

      telefonoController.text = cliente.telefono;

      correoController.text = cliente.correo;

      validarNombre(
        nombreController.text,
      );

      validarTelefono(
        telefonoController.text,
      );

      validarCorreo(
        correoController.text,
      );

      notifyListeners();

    } catch (e) {

      debugPrint(
        'Error buscando cliente: $e',
      );
    }
  }

  void _limpiarAutocompletado() {

    clienteExistenteId = null;

    clienteExistente = null;

    clienteAutocompletado = false;

    clienteEliminado = false;
  }

  bool validar() {

    nombreError = null;

    rutError = null;

    telefonoError = null;

    correoError = null;

    final nombre =
        nombreController.text.trim();

    final rut =
        rutController.text.trim();

    final telefono =
        telefonoController.text.trim();

    final correo =
        correoController.text.trim();

    if (nombre.isEmpty) {
      nombreError = 'Ingrese nombre';
    } else if (!ClientValidators.esNombreValido(nombre)) {
      nombreError = 'Mínimo 3 caracteres, solo letras';
    }

    if (rut.isEmpty) {

      rutError =
          'Ingrese RUT';

    } else if (
        !ClientValidators
            .esRutValido(rut)) {

      rutError =
          'RUT inválido';
    }

    if (telefono.isEmpty) {

      telefonoError =
          'Ingrese teléfono';

    } else if (
        !ClientValidators
            .esTelefonoValido(
                telefono)) {

      telefonoError =
          'Teléfono inválido';
    }

    if (correo.isEmpty) {

      correoError =
          'Ingrese correo';

    } else if (
        !ClientValidators
            .esCorreoValido(
                correo)) {

      correoError =
          'Correo inválido';
    }

    notifyListeners();

    return nombreError == null &&
        rutError == null &&
        telefonoError == null &&
        correoError == null;
  }

  void validarNombre(
    String value,
  ) {

    if (value.trim().isEmpty) {
      nombreError = 'Ingrese nombre';
    } else if (!ClientValidators.esNombreValido(value)) {
      nombreError = 'Mínimo 3 caracteres, solo letras';
    } else {
      nombreError = null;
    }

    notifyListeners();
  }

  void validarRut(
    String value,
  ) {

    if (value.trim().isEmpty) {

      rutError =
          'Ingrese RUT';

    } else if (
        !ClientValidators
            .esRutValido(value)) {

      rutError =
          'RUT inválido';

    } else {

      rutError = null;
    }

    notifyListeners();
  }

  void validarTelefono(
    String value,
  ) {

    if (value.trim().isEmpty) {

      telefonoError =
          'Ingrese teléfono';

    } else if (
        !ClientValidators
            .esTelefonoValido(
                value)) {

      telefonoError =
          'Teléfono inválido';

    } else {

      telefonoError = null;
    }

    notifyListeners();
  }

  void validarCorreo(
    String value,
  ) {

    if (value.trim().isEmpty) {

      correoError =
          'Ingrese correo';

    } else if (
        !ClientValidators
            .esCorreoValido(
                value)) {

      correoError =
          'Correo inválido';

    } else {

      correoError = null;
    }

    notifyListeners();
  }

  Future<bool> guardar() async {

    if (!validar()) {
      return false;
    }

    loading = true;

    notifyListeners();

    try {

      if (clienteExistenteId != null &&
          clienteExistente != null) {

        final clienteActualizado =
            ClientEntity(
          id: clienteExistenteId!,
          nombre: nombreController.text.trim(),
          rut: rutController.text.trim(),
          telefono: telefonoController.text.trim(),
          correo: correoController.text.trim(),
          isDeleted: false,
          createdAt:
              clienteExistente!.createdAt,
        );

        await repository
            .actualizarCliente(
          clienteActualizado,
        );

      } else {

        final cliente =
            ClientEntity(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          nombre:
              nombreController.text.trim(),
          rut:
              rutController.text.trim(),
          telefono:
              telefonoController.text.trim(),
          correo:
              correoController.text.trim(),
          createdAt: DateTime.now(),
        );

        await repository
            .guardarCliente(cliente);
      }

      return true;

    } catch (e) {

      debugPrint(
        'Error guardando cliente: $e',
      );

      return false;

    } finally {

      loading = false;

      notifyListeners();
    }
  }

  void limpiarFormulario() {

    nombreController.clear();

    rutController.clear();

    telefonoController.clear();

    correoController.clear();

    _limpiarAutocompletado();

    nombreError = null;

    rutError = null;

    telefonoError = null;

    correoError = null;

    modoEdicion = false;

    notifyListeners();
  }

  @override
  void dispose() {

    rutDebounce?.cancel();

    nombreController.dispose();

    rutController.dispose();

    telefonoController.dispose();

    correoController.dispose();

    super.dispose();
  }
}