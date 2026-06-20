import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/firestore/firestore_collections.dart';
import '../../../../core/firestore/firestore_service.dart';

import '../models/model_cotizacion.dart';
import '../models/paginated_cotizaciones_result.dart';

class CotizacionRemoteDatasource {
  final FirestoreService firestoreService;

  CotizacionRemoteDatasource(
    this.firestoreService,
  );

  Future<List<ModelCotizacion>>
      obtenerCotizaciones() async {
    final snapshot =
        await firestoreService
            .collection(
              FirestoreCollections.cotizaciones,
            )
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get(
              const GetOptions(
                source: Source.server,
              ),
            );

    return snapshot.docs.map(
      (doc) {
        return ModelCotizacion.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      },
    ).toList();
  }

  Future<PaginatedCotizacionesResult>
      obtenerCotizacionesPaginadas({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>?
        lastDocument,
  }) async {
    Query<Map<String, dynamic>> query =
        firestoreService
            .collection(
              FirestoreCollections.cotizaciones,
            )
            .orderBy(
              'createdAt',
              descending: true,
            )
            .limit(
              limit,
            );

    if (lastDocument != null) {
      query = query.startAfterDocument(
        lastDocument,
      );
    }

    final snapshot =
        await query.get();

    final cotizaciones =
        snapshot.docs.map(
      (doc) {
        return ModelCotizacion.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      },
    ).toList();

    return PaginatedCotizacionesResult(
      cotizaciones: cotizaciones,
      lastDocument:
          snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : null,
      hasMore:
          snapshot.docs.length == limit,
    );
  }

  Future<void> guardarCotizacion(
    ModelCotizacion cotizacion,
  ) async {
    try {
      await firestoreService
          .collection(
            FirestoreCollections.cotizaciones,
          )
          .doc(
            cotizacion.id,
          )
          .set(
            cotizacion.toJson(),
          )
          .timeout(
            const Duration(
              seconds: 10,
            ),
          );

      if (kDebugMode) {
        debugPrint(
          'Cotizacion sincronizada: ${cotizacion.id}',
        );
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Firebase error: ${e.code}',
        );
      }

      switch (e.code) {
        case 'unavailable':
          throw AppException(
            'Servidor no disponible',
          );

        case 'permission-denied':
          throw AppException(
            'Permisos insuficientes',
          );

        default:
          throw AppException(
            'Error Firebase',
          );
      }
    } on TimeoutException {
      throw AppException(
        'Timeout de conexión',
      );
    } catch (_) {
      throw AppException(
        'Error inesperado',
      );
    }
  }

  Future<void> eliminarCotizacion(
    String id,
  ) async {
    await firestoreService
        .collection(
          FirestoreCollections.cotizaciones,
        )
        .doc(id)
        .delete();
  }

  Future<void> eliminarCotizaciones(
    List<String> ids,
  ) async {
    final batch =
        firestoreService.batch();

    for (final id in ids) {
      batch.delete(
        firestoreService
            .collection(
              FirestoreCollections.cotizaciones,
            )
            .doc(id),
      );
    }

    await batch.commit();
  }

  Stream<List<ModelCotizacion>>
      watchCotizaciones() {
    return firestoreService
        .collection(
          FirestoreCollections.cotizaciones,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return ModelCotizacion.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
          },
        ).toList();
      },
    );
  }
}