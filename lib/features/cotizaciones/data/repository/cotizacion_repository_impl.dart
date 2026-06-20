import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/entidad_cotizacion.dart';
import '../../domain/repositories/cotizacion_repository.dart';

import '../datasources/cotizacion_local_datasource.dart';
import '../datasources/cotizacion_remote_datasource.dart';

import '../mappers/cotizaciones_mapper.dart';
import '../models/paginated_cotizaciones_result.dart';
import '../models/model_cotizacion.dart';

class CotizacionRepositoryImp implements CotizacionRepository {
  final CotizacionLocalDatasource localDatasource;
  final CotizacionRemoteDatasource remoteDatasource;

  CotizacionRepositoryImp({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<void> guardarCotizacion(
      EntidadCotizacion cotizacion,
      ) async {
    final model = CotizacionMapper.aModel(cotizacion);

    await remoteDatasource.guardarCotizacion(model);
  }

  @override
  Future<List<EntidadCotizacion>> obtenerCotizaciones() async {
    try {
      final cotizacionesLocales =
      await localDatasource.obtenerCotizaciones();

      if (cotizacionesLocales.isNotEmpty) {
        return cotizacionesLocales
            .map(CotizacionMapper.aEntidad)
            .toList();
      }

      final cotizacionesRemotas =
      await remoteDatasource.obtenerCotizaciones();

      return cotizacionesRemotas
          .map(CotizacionMapper.aEntidad)
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<PaginatedCotizacionesResult> obtenerCotizacionesPaginadas({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    final resultadoRemoto = await remoteDatasource.obtenerCotizacionesPaginadas(
      limit: limit,
      lastDocument: lastDocument,
    );

    final entidades = resultadoRemoto.cotizaciones
        .map((model) => CotizacionMapper.aEntidad(model as ModelCotizacion))
        .toList();

    return PaginatedCotizacionesResult(
      cotizaciones: entidades,
      lastDocument: resultadoRemoto.lastDocument,
      hasMore: resultadoRemoto.hasMore,
    );
  }

  @override
  Stream<List<EntidadCotizacion>> watchCotizaciones() {
    return remoteDatasource.watchCotizaciones().map(
          (items) => items
          .map(CotizacionMapper.aEntidad)
          .toList(),
    );
  }

  @override
  Future<void> eliminarCotizacion(
      String id,
      ) {
    return remoteDatasource
        .eliminarCotizacion(id);
  }

  @override
  Future<void> eliminarCotizaciones(
      List<String> ids,
      ) {
    return remoteDatasource
        .eliminarCotizaciones(ids);
  }
}