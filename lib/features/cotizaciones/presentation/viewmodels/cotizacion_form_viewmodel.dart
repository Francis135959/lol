import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/state/base_viewmodel.dart';
import '../../domain/entities/entidad_cotizacion.dart';
import '../../domain/entities/material_item_entity.dart';
import '../../domain/entities/labor_item_entity.dart';
import '../../domain/repositories/cotizacion_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../configuracion/presentation/viewmodels/settings_viewmodel.dart';
import '../../domain/utils/motor_calculo.dart';

class CotizacionFormViewModel extends BaseViewModel {
  final CotizacionRepository _repository;
  Timer? _debounceTimer;

  final direccionController = TextEditingController();
  final m2Controller = TextEditingController();
  final transportController = TextEditingController();
  final utilityController = TextEditingController(text: '10');
  final ivaController = TextEditingController();

  CotizacionFormViewModel({required CotizacionRepository repository})
      : _repository = repository {
    final ivaGlobal = sl<SettingsViewModel>().state.data?.iva ?? 19.0;
    ivaController.text = ivaGlobal.toString().replaceAll(RegExp(r'\.0$'), '');
  }

  final List<String> opcionesTipoTrabajo = [
    'Pintura de Muros Interiores',
    'Pintura de Fachadas',
    'Barnizado/Lacado',
    'Tratamiento de Humedades/Sellado',
    'Yeso'
  ];

  bool isConCliente = false;

  final ValueNotifier<List<String>> tipoTrabajoNotifier = ValueNotifier([]);
  final ValueNotifier<List<MaterialItemEntity>> materialesNotifier = ValueNotifier([]);
  final ValueNotifier<List<LaborItemEntity>> manoDeObraNotifier = ValueNotifier([]);
  final ValueNotifier<ResultadoCotizacion?> resultadoNotifier = ValueNotifier(null);

  List<MaterialItemEntity> get materiales => materialesNotifier.value;
  List<LaborItemEntity> get manoDeObra => manoDeObraNotifier.value;

  int _cachedTotalMateriales = 0;
  int _cachedTotalManoObra = 0;

  String _id = '';
  String _clienteId = '';
  String _nombreCliente = '';
  String _status = 'draft';
  int _version = 1;
  DateTime? _createdAt;

  String get id => _id;
  String get clienteId => _clienteId;
  String get nombreCliente => _nombreCliente;
  DateTime? get createdAt => _createdAt;

  String? _tipoTrabajoError;
  String? _direccionError;
  String? _m2Error;
  String? _transportError;
  String? _utilityError;
  String? _ivaError;

  String? get tipoTrabajoError => _tipoTrabajoError;
  String? get direccionError => _direccionError;
  String? get m2Error => _m2Error;
  String? get transportError => _transportError;
  String? get utilityError => _utilityError;
  String? get ivaError => _ivaError;

  double get m2 => double.tryParse(m2Controller.text) ?? 0.0;
  double get transport => double.tryParse(transportController.text) ?? 0.0;
  double get utility => double.tryParse(utilityController.text) ?? 0.0;
  double get iva => double.tryParse(ivaController.text) ?? 0.0;

  double get subtotal => resultadoNotifier.value?.subtotalBase ?? 0.0;
  double get total => resultadoNotifier.value?.totalFinal ?? 0.0;

  void agregarMaterial(String nombre, int cantidad, int precioUnitario) {
    if (cantidad <= 0 || precioUnitario <= 0) return;
    final nuevoMaterial = MaterialItemEntity(
      nombre: nombre,
      cantidad: cantidad.toDouble(),
      precioUnitario: precioUnitario.toDouble(),
    );
    materialesNotifier.value = [...materialesNotifier.value, nuevoMaterial];
    _recalcularYGuardar();
  }

  void editarMaterial(int index, String nuevoNombre, int nuevaCantidad, int nuevoPrecio) {
    if (nuevaCantidad <= 0 || nuevoPrecio <= 0) return;
    if (index >= 0 && index < materialesNotifier.value.length) {
      final nuevaLista = List<MaterialItemEntity>.from(materialesNotifier.value);
      nuevaLista[index] = MaterialItemEntity(
        nombre: nuevoNombre,
        cantidad: nuevaCantidad.toDouble(),
        precioUnitario: nuevoPrecio.toDouble(),
      );
      materialesNotifier.value = nuevaLista;
      _recalcularYGuardar();
    }
  }

  void eliminarMaterial(int index) {
    if (index >= 0 && index < materialesNotifier.value.length) {
      final nuevaLista = List<MaterialItemEntity>.from(materialesNotifier.value);
      nuevaLista.removeAt(index);
      materialesNotifier.value = nuevaLista;
      _recalcularYGuardar();
    }
  }

  void agregarLabor(String cargo, int valorJornada, int dias) {
    if (valorJornada <= 0 || dias <= 0) return;
    final nuevaLabor = LaborItemEntity(
      cargo: cargo,
      valorJornada: valorJornada,
      dias: dias,
    );
    manoDeObraNotifier.value = [...manoDeObraNotifier.value, nuevaLabor];
    _recalcularYGuardar();
  }

  void editarLabor(int index, String nuevoCargo, int nuevoValor, int nuevosDias) {
    if (nuevoValor <= 0 || nuevosDias <= 0) return;
    if (index >= 0 && index < manoDeObraNotifier.value.length) {
      final nuevaLista = List<LaborItemEntity>.from(manoDeObraNotifier.value);
      nuevaLista[index] = LaborItemEntity(
        cargo: nuevoCargo,
        valorJornada: nuevoValor,
        dias: nuevosDias,
      );
      manoDeObraNotifier.value = nuevaLista;
      _recalcularYGuardar();
    }
  }

  void eliminarLabor(int index) {
    if (index >= 0 && index < manoDeObraNotifier.value.length) {
      final nuevaLista = List<LaborItemEntity>.from(manoDeObraNotifier.value);
      nuevaLista.removeAt(index);
      manoDeObraNotifier.value = nuevaLista;
      _recalcularYGuardar();
    }
  }

  void _recalcularYGuardar() {
    _cachedTotalMateriales = materialesNotifier.value.fold(0, (sum, item) => sum + (item.cantidad * item.precioUnitario).toInt());
    _cachedTotalManoObra = manoDeObraNotifier.value.fold(0, (sum, item) => sum + item.subtotal);

    final porcentajeIva = iva / 100.0;
    final manoDeObraTotal = _cachedTotalManoObra + (m2 * 15000);

    resultadoNotifier.value = MotorCalculo.calcular(
      totalMateriales: _cachedTotalMateriales.toDouble(),
      totalManoObra: manoDeObraTotal.toDouble(),
      transporte: transport,
      porcentajeUtilidad: utility / 100.0,
      porcentajeIva: porcentajeIva,
    );

    _huboCambio();
  }

  void setCliente(String id, String nombre) {
    _clienteId = id;
    _nombreCliente = nombre;
    _huboCambio();
  }

  void toggleTipoTrabajo(String opcion) {
    final actual = List<String>.from(tipoTrabajoNotifier.value);
    if (actual.contains(opcion)) {
      actual.remove(opcion);
    } else {
      actual.add(opcion);
    }
    tipoTrabajoNotifier.value = actual;
    _tipoTrabajoError = actual.isEmpty ? 'Seleccione al menos un tipo de trabajo' : null;
    _huboCambio();
  }

  void validarDireccion(String value) {
    _direccionError = value.trim().isEmpty ? 'La dirección es obligatoria' : null;
    _huboCambio();
  }

  void validarM2(String value) {
    if (value.trim().isEmpty) {
      _m2Error = 'Ingrese los m² (Obligatorio)';
    } else if (double.tryParse(value) == null || double.parse(value) <= 0) {
      _m2Error = 'Debe ser mayor a 0';
    } else {
      _m2Error = null;
    }
    _recalcularYGuardar();
  }

  void validarTransporte(String value) {
    if (value.trim().isEmpty) {
      _transportError = 'Ingrese el costo de transporte (Obligatorio)';
    } else if (double.tryParse(value) == null || double.parse(value) < 0) {
      _transportError = 'Número inválido';
    } else {
      _transportError = null;
    }
    _recalcularYGuardar();
  }

  void validarUtilidad(String value) {
    if (value.trim().isEmpty) {
      _utilityError = 'Ingrese el porcentaje de utilidad';
    } else {
      final val = double.tryParse(value);
      if (val == null) {
        _utilityError = 'Número inválido';
      } else if (val < 0 || val > 100) {
        _utilityError = 'Debe estar entre 0 y 100';
      } else {
        _utilityError = null;
      }
    }
    _recalcularYGuardar();
  }

  void validarIva(String value) {
    if (value.trim().isEmpty) {
      _ivaError = 'Ingrese el porcentaje de IVA';
    } else {
      final val = double.tryParse(value);
      if (val == null) {
        _ivaError = 'Número inválido';
      } else if (val < 0 || val > 100) {
        _ivaError = 'Debe estar entre 0 y 100';
      } else {
        _ivaError = null;
      }
    }
    _recalcularYGuardar();
  }

  bool validarFormulario() {
    validarDireccion(direccionController.text);
    validarM2(m2Controller.text);
    validarTransporte(transportController.text);
    validarUtilidad(utilityController.text);
    validarIva(ivaController.text);

    _tipoTrabajoError = tipoTrabajoNotifier.value.isEmpty
        ? 'Seleccione al menos un tipo de trabajo'
        : null;

    notifyListeners();

    return _direccionError == null &&
        _m2Error == null &&
        _transportError == null &&
        _utilityError == null &&
        _ivaError == null &&
        _tipoTrabajoError == null;
  }

  void _huboCambio() {
    notifyListeners();
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _guardarAutomaticamente();
    });
  }

  Future<void> guardarExplicitamente(EntidadCotizacion cotizacion) async {
    _id = cotizacion.id;
    _clienteId = cotizacion.clienteId;
    _nombreCliente = cotizacion.nombreCliente;
    try {
      await _repository.guardarCotizacion(cotizacion);
    } catch (e) {
      debugPrint("Error guardando cotización: $e");
    }
  }

  Future<void> _guardarAutomaticamente() async {
    if (_tipoTrabajoError != null || _direccionError != null || _m2Error != null || _transportError != null) return;
    if (_id.isEmpty) _id = 'COT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    if (_clienteId.isEmpty) {
      _clienteId = isConCliente
          ? 'sin-cliente-${DateTime.now().millisecondsSinceEpoch}'
          : 'rapida-${DateTime.now().millisecondsSinceEpoch}';
    }

    if (_nombreCliente.isEmpty) {
      _nombreCliente = isConCliente ? 'Sin cliente asignado' : 'Cotización Rápida';
    }

    final cotizacion = EntidadCotizacion(
      id: _id,
      clienteId: _clienteId,
      nombreCliente: _nombreCliente,
      materials: List.from(materialesNotifier.value),
      labor: List.from(manoDeObraNotifier.value),
      metrosCuadrados: m2,
      direccion: direccionController.text.trim(),
      tipoTrabajo: List.from(tipoTrabajoNotifier.value),
      transport: transport,
      utility: utility,
      iva: iva,
      total: total,
      status: _status,
      version: _version,
      createdAt: _createdAt ?? DateTime.now(),
    );

    try {
      await _repository.guardarCotizacion(cotizacion);
    } catch (e) {
      debugPrint("Error en persistencia automática: $e");
    }
  }

  void cargarCotizacion(EntidadCotizacion cotizacion) {
    _id = cotizacion.id;
    _clienteId = cotizacion.clienteId;
    _nombreCliente = cotizacion.nombreCliente;
    _status = cotizacion.status;
    _version = cotizacion.version;
    _createdAt = cotizacion.createdAt;

    materialesNotifier.value = List.from(cotizacion.materials);
    manoDeObraNotifier.value = List.from(cotizacion.labor);
    tipoTrabajoNotifier.value = List.from(cotizacion.tipoTrabajo);
    direccionController.text = cotizacion.direccion;

    m2Controller.text = cotizacion.metrosCuadrados.toString().replaceAll(RegExp(r'\.0$'), '');
    transportController.text = cotizacion.transport > 0 ? cotizacion.transport.toInt().toString() : '';

    utilityController.text = cotizacion.utility.toString().replaceAll(RegExp(r'\.0$'), '');
    ivaController.text = cotizacion.iva.toString().replaceAll(RegExp(r'\.0$'), '');

    _recalcularYGuardar();
  }

  bool esValidaParaGenerarPdf() {
    if (!validarFormulario()) return false;
    if (total <= 0) return false;
    return true;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    direccionController.dispose();
    m2Controller.dispose();
    transportController.dispose();
    utilityController.dispose();
    ivaController.dispose();
    materialesNotifier.dispose();
    manoDeObraNotifier.dispose();
    resultadoNotifier.dispose();
    tipoTrabajoNotifier.dispose();
    super.dispose();
  }
}