import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../cotizaciones/domain/entities/entidad_cotizacion.dart';
import '../../cotizaciones/domain/entities/material_item_entity.dart';
import '../../cotizaciones/domain/entities/labor_item_entity.dart';
import '../../cotizaciones/domain/repositories/cotizacion_repository.dart';
import '../../clientes/domain/entities/client_entity.dart';
import '../../clientes/domain/repositories/client_repository.dart';

class BackupService {
  final CotizacionRepository _cotizacionRepository;
  final ClientRepository _clientRepository;

  BackupService({
    required CotizacionRepository cotizacionRepository,
    required ClientRepository clientRepository,
  })  : _cotizacionRepository = cotizacionRepository,
        _clientRepository = clientRepository;

  String defaultFileName() {
    final now = DateTime.now();
    final fecha =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hora =
        '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
    return 'backup_${fecha}_$hora.json';
  }

  Future<bool> solicitarPermisosAlmacenamiento() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) return false;

    final fallback = await Permission.storage.request();
    return fallback.isGranted;
  }

  Future<String> _construirJsonRespaldo() async {
    final cotizaciones =
        await _cotizacionRepository.watchCotizaciones().first;
    final clientes = await _clientRepository.watchClientes().first;

    if (cotizaciones.isEmpty && clientes.isEmpty) {
      throw Exception('No hay datos en el historial local para respaldar.');
    }

    final listaCotizaciones = cotizaciones.map((c) {
      return {
        'id': c.id,
        'clienteId': c.clienteId,
        'nombreCliente': c.nombreCliente,
        'metrosCuadrados': c.metrosCuadrados,
        'direccion': c.direccion,
        'tipoTrabajo': c.tipoTrabajo,
        'transport': c.transport,
        'utility': c.utility,
        'iva': c.iva,
        'total': c.total,
        'status': c.status,
        'version': c.version,
        'createdAt': c.createdAt.toIso8601String(),
        'materials': c.materials
            .map((m) => {
                  'nombre': m.nombre,
                  'cantidad': m.cantidad,
                  'precioUnitario': m.precioUnitario,
                })
            .toList(),
        'labor': c.labor
            .map((l) => {
                  'cargo': l.cargo,
                  'valorJornada': l.valorJornada,
                  'dias': l.dias,
                })
            .toList(),
      };
    }).toList();

    final listaClientes = clientes.map((c) {
      return {
        'id': c.id,
        'nombre': c.nombre,
        'rut': c.rut,
        'telefono': c.telefono,
        'correo': c.correo,
        'isDeleted': c.isDeleted,
        'createdAt': c.createdAt.toIso8601String(),
      };
    }).toList();

    final backupCompleto = {
      'fecha_respaldo': DateTime.now().toIso8601String(),
      'clientes': listaClientes,
      'cotizaciones': listaCotizaciones,
    };

    return const JsonEncoder.withIndent('  ').convert(backupCompleto);
  }

  Future<String?> exportarListaAJson() async {
    final tienePermiso = await solicitarPermisosAlmacenamiento();
    if (!tienePermiso) {
      throw Exception(
        'Se necesitan permisos de almacenamiento para guardar el backup.',
      );
    }

    final jsonString = await _construirJsonRespaldo();

    final carpeta = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecciona la carpeta de destino',
    );

    if (carpeta == null) return null;

    final fileName = defaultFileName();
    final filePath = '$carpeta/$fileName';

    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  Future<String?> exportarListaAJsonConNombre(String nombreArchivo) async {
    final tienePermiso = await solicitarPermisosAlmacenamiento();
    if (!tienePermiso) {
      throw Exception(
        'Se necesitan permisos de almacenamiento para guardar el backup.',
      );
    }

    final jsonString = await _construirJsonRespaldo();

    final carpeta = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecciona la carpeta de destino',
    );

    if (carpeta == null) return null;

    final nombre =
        nombreArchivo.endsWith('.json') ? nombreArchivo : '$nombreArchivo.json';
    final filePath = '$carpeta/$nombre';

    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  Future<int?> restaurarDesdeSelector() async {
    final tienePermiso = await solicitarPermisosAlmacenamiento();
    if (!tienePermiso) {
      throw Exception(
        'Se necesitan permisos de almacenamiento para leer el backup.',
      );
    }

    final resultado = await FilePicker.pickFiles(
      dialogTitle: 'Selecciona el archivo de backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (resultado == null || resultado.files.isEmpty) return null;

    final path = resultado.files.single.path;
    if (path == null) {
      throw Exception('No se pudo obtener la ruta del archivo seleccionado.');
    }

    return restaurarDesdeArchivo(File(path));
  }

  Future<int> restaurarDesdeArchivo(File file) async {
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> datos = jsonDecode(jsonString);

      int registrosRestaurados = 0;

      final List<dynamic> clientesJson = datos['clientes'] ?? [];

      for (final item in clientesJson) {
        if (item is! Map) continue;

        final cliente = ClientEntity(
          id: item['id']?.toString() ?? '',
          nombre: item['nombre']?.toString() ?? '',
          rut: item['rut']?.toString() ?? '',
          telefono: item['telefono']?.toString() ?? '',
          correo: item['correo']?.toString() ?? '',
          isDeleted: item['isDeleted'] == true,
          createdAt:
              DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
                  DateTime.now(),
        );

        await _clientRepository.guardarCliente(cliente);
        registrosRestaurados++;
      }

      final List<dynamic> cotizacionesJson = datos['cotizaciones'] ?? [];

      for (final item in cotizacionesJson) {
        if (item is! Map) continue;

        final materiales = (item['materials'] as List? ?? []).map((m) {
          final map = m as Map? ?? {};
          return MaterialItemEntity(
            nombre: map['nombre']?.toString() ?? '',
            cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0.0,
            precioUnitario:
                (map['precioUnitario'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        final manoDeObra = (item['labor'] as List? ?? []).map((l) {
          final map = l as Map? ?? {};
          return LaborItemEntity(
            cargo: map['cargo']?.toString() ?? '',
            valorJornada: (map['valorJornada'] as num?)?.toInt() ?? 0,
            dias: (map['dias'] as num?)?.toInt() ?? 0,
          );
        }).toList();

        final tiposTrabajo = (item['tipoTrabajo'] as List? ?? [])
            .map((e) => e.toString())
            .toList();

        final cotizacion = EntidadCotizacion(
          id: item['id']?.toString() ?? '',
          clienteId: item['clienteId']?.toString() ?? '',
          nombreCliente: item['nombreCliente']?.toString() ?? '',
          materials: materiales,
          labor: manoDeObra,
          metrosCuadrados:
              (item['metrosCuadrados'] as num?)?.toDouble() ?? 0.0,
          direccion: item['direccion']?.toString() ?? '',
          tipoTrabajo: tiposTrabajo,
          transport: (item['transport'] as num?)?.toDouble() ?? 0.0,
          utility: (item['utility'] as num?)?.toDouble() ?? 0.0,
          iva: (item['iva'] as num?)?.toDouble() ?? 0.0,
          total: (item['total'] as num?)?.toDouble() ?? 0.0,
          status: item['status']?.toString() ?? 'draft',
          version: (item['version'] as num?)?.toInt() ?? 1,
          createdAt:
              DateTime.tryParse(item['createdAt']?.toString() ?? '') ??
                  DateTime.now(),
        );

        await _cotizacionRepository.guardarCotizacion(cotizacion);
        registrosRestaurados++;
      }

      return registrosRestaurados;
    } catch (e) {
      throw Exception('Error al restaurar desde backup: $e');
    }
  }

  Future<int> sincronizarFirestoreVerificable() async {
    try {
      final firestore = FirebaseFirestore.instance;
      int totalSubidos = 0;

      final clientes = await _clientRepository.watchClientes().first;
      final cotizaciones =
          await _cotizacionRepository.watchCotizaciones().first;

      for (final cliente in clientes) {
        await firestore.collection('clients').doc(cliente.id).set(
          {
            'id': cliente.id,
            'nombre': cliente.nombre,
            'rut': cliente.rut,
            'telefono': cliente.telefono,
            'correo': cliente.correo,
            'isDeleted': cliente.isDeleted,
            'createdAt': cliente.createdAt.toIso8601String(),
            'syncedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        totalSubidos++;
      }

      for (final cotizacion in cotizaciones) {
        await firestore.collection('quotes').doc(cotizacion.id).set(
          {
            'id': cotizacion.id,
            'clienteId': cotizacion.clienteId,
            'nombreCliente': cotizacion.nombreCliente,
            'metrosCuadrados': cotizacion.metrosCuadrados,
            'direccion': cotizacion.direccion,
            'tipoTrabajo': cotizacion.tipoTrabajo,
            'transport': cotizacion.transport,
            'utility': cotizacion.utility,
            'iva': cotizacion.iva,
            'total': cotizacion.total,
            'status': cotizacion.status,
            'version': cotizacion.version,
            'createdAt': cotizacion.createdAt.toIso8601String(),
            'materials': cotizacion.materials
                .map((m) => {
                      'nombre': m.nombre,
                      'cantidad': m.cantidad,
                      'precioUnitario': m.precioUnitario,
                    })
                .toList(),
            'labor': cotizacion.labor
                .map((l) => {
                      'cargo': l.cargo,
                      'valorJornada': l.valorJornada,
                      'dias': l.dias,
                    })
                .toList(),
            'syncedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        totalSubidos++;
      }

      await firestore.waitForPendingWrites();

      return totalSubidos;
    } catch (e) {
      throw Exception('Error en sincronización: $e');
    }
  }
}