import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entidad_cotizacion.dart';

class PaginatedCotizacionesResult {
  final List<EntidadCotizacion> cotizaciones;

  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  final bool hasMore;

  const PaginatedCotizacionesResult({
    required this.cotizaciones,
    required this.lastDocument,
    required this.hasMore,
  });
}