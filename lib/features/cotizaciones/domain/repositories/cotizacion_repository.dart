import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/entidad_cotizacion.dart';
import '../../data/models/paginated_cotizaciones_result.dart';

abstract class CotizacionRepository {
  Future<void> guardarCotizacion(
    EntidadCotizacion cotizacion,
  );

  Future<List<EntidadCotizacion>>
      obtenerCotizaciones();

  Future<PaginatedCotizacionesResult>
      obtenerCotizacionesPaginadas({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>?
        lastDocument,
  });

  Future<void> eliminarCotizacion(
    String id,
  );

  Future<void> eliminarCotizaciones(
    List<String> ids,
  );

  Stream<List<EntidadCotizacion>>
      watchCotizaciones();
}