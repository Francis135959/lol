import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entidad_cotizacion.dart';
import '../../domain/entities/material_item_entity.dart';
import '../../domain/entities/labor_item_entity.dart';

class ModelCotizacion extends EntidadCotizacion {
  const ModelCotizacion({
    required super.id,
    required super.clienteId,       
    required super.nombreCliente,  
    required super.materials,
    required super.labor,
    required super.metrosCuadrados,
    required super.direccion,
    required super.tipoTrabajo,
    required super.transport,
    required super.utility,
    required super.iva,
    required super.total,
    required super.status,
    required super.version,
    required super.createdAt,
  });

  factory ModelCotizacion.fromJson(Map<String, dynamic> json) {
    return ModelCotizacion(
      id: json['id'],
      // Aquí el truco: si no encuentra 'clienteId', busca 'clientId'. ¡Así no se cae!
      clienteId: json['clienteId'] ?? json['clientId'] ?? '',
      nombreCliente: json['nombreCliente'] ?? 'Sin Nombre',
      
      materials: (json['materials'] as List<dynamic>?)?.map((m) => MaterialItemEntity(
        nombre: m['nombre']?.toString() ?? '',
        cantidad: (m['cantidad'] as num?)?.toDouble() ?? 0.0,
        precioUnitario: (m['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      )).toList() ?? [],
      
      labor: (json['labor'] as List<dynamic>?)?.map((l) => LaborItemEntity(
        cargo: l['cargo']?.toString() ?? '',
        valorJornada: (l['valorJornada'] as num?)?.toInt() ?? 0,
        dias: (l['dias'] as num?)?.toInt() ?? 0,
      )).toList() ?? [],

      transport: (json['transport'] as num?)?.toDouble() ?? 0.0,
      utility: (json['utility'] as num?)?.toDouble() ?? 0.0,
      iva: (json['iva'] as num?)?.toDouble() ?? 0.0,
      metrosCuadrados: (json['metrosCuadrados'] as num?)?.toDouble() ?? 0.0,
      direccion: json['direccion']?.toString() ?? '',
      tipoTrabajo: (json['tipoTrabajo'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      total: (json['total'] as num).toDouble(),
      createdAt: json['createdAt'] is String 
        ? DateTime.parse(json['createdAt'] as String) 
        : (json['createdAt'] as Timestamp).toDate(),
      status: json['status'] ?? 'draft',
      version: json['version']?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Mantuve 'clientId' tal cual lo tenías en tu código original para no romper tu BD
      'clientId': clienteId, 
      'nombreCliente': nombreCliente,
      
      // 2. TRADUCCIÓN DE SUBIDA (Dart -> Firebase)
      // Desarmamos las entidades estrictas y las volvemos a convertir en mapas simples 
      'materials': materials.map((m) => {
        'nombre': m.nombre,
        'cantidad': m.cantidad,
        'precioUnitario': m.precioUnitario,
      }).toList(),
      
      'labor': labor.map((l) => {
        'cargo': l.cargo,
        'valorJornada': l.valorJornada,
        'dias': l.dias,
      }).toList(),

      'transport': transport,
      'utility': utility,
      'iva': iva,
      'metrosCuadrados': metrosCuadrados,
      'direccion': direccion,
      'tipoTrabajo': tipoTrabajo,
      'total': total,
      'status': status,
      'version': version,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}