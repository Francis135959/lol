import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client_entity.dart';
import '../../utils/client_validators.dart';

class ClientDTO extends ClientEntity {
  ClientDTO({
    required super.id,
    required super.nombre,
    required super.rut,
    required super.telefono,
    required super.correo,
    required super.createdAt,
    super.isDeleted,
  });

  Map<String, dynamic> aMapa() {
    return {
      'nombre': nombre,
      'rut': rut,
      'rutNormalizado': ClientValidators.normalizarRut(rut),
      'telefono': telefono,
      'correo': correo,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
    };
  }

  factory ClientDTO.desdeMapa(
      Map<String, dynamic> map,
      String id,
      ) {
    DateTime parsedDate = DateTime.now();

    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
      } else if (map['createdAt'] is int) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int);
      }
    }

    return ClientDTO(
      id: id,
      nombre: map['nombre'] ?? '',
      rut: map['rut'] ?? '',
      telefono: map['telefono'] ?? '',
      correo: map['correo'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
      createdAt: parsedDate,
    );
  }
}