import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../firestore/cache_manager.dart';

class CacheService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final Map<String, StreamSubscription>
      _activeSubscriptions = {};

  CacheService() {
    _inicializar();
  }

  void _inicializar() {
    FirestoreCacheManager.configurarCache();

    if (kDebugMode) {
      debugPrint('CacheService inicializado');
    }
  }

  Future<List<Map<String, dynamic>>>
      getCollectionData({
    required String collection,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
    bool preferCache = true,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(
        orderBy,
        descending: descending,
      );
    }

    try {
      if (preferCache) {
        final cacheResult = await query.get(
          const GetOptions(source: Source.cache),
        );

        if (cacheResult.docs.isNotEmpty) {
          final docs = cacheResult.docs
              .map((doc) => doc.data())
              .toList();

          return _aplicarPaginacionLocalMap(
            docs,
            limit,
            offset,
          );
        }
      }

      final serverResult = await query.get(
        const GetOptions(source: Source.server),
      );

      final docs = serverResult.docs
          .map((doc) => doc.data())
          .toList();

      return _aplicarPaginacionLocalMap(
        docs,
        limit,
        offset,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Error obteniendo $collection: $e',
        );
      }

      rethrow;
    }
  }

  List<Map<String, dynamic>>
      _aplicarPaginacionLocalMap(
    List<Map<String, dynamic>> docs,
    int? limit,
    int? offset,
  ) {
    var resultados =
        List<Map<String, dynamic>>.from(docs);

    if (offset != null &&
        offset > 0 &&
        offset < resultados.length) {
      resultados = resultados.skip(offset).toList();
    }

    if (limit != null &&
        resultados.length > limit) {
      resultados = resultados.take(limit).toList();
    }

    return resultados;
  }

  Stream<List<T>> watchCollection<T>({
    required String collection,
    required T Function(
      Map<String, dynamic>,
      String,
    ) fromMap,
    int? limit,
  }) {
    cancelStream(collection);

    Query<Map<String, dynamic>> query =
        _firestore.collection(collection);

    if (limit != null) {
      query = query.limit(limit);
    }

    final stream = query.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return fromMap(
            doc.data(),
            doc.id,
          );
        }).toList();
      },
    );

    final subscription = stream.listen(null);

    _activeSubscriptions[collection] =
        subscription;

    return stream;
  }

  void cancelStream(String collection) {
    final subscription =
        _activeSubscriptions[collection];

    if (subscription != null) {
      subscription.cancel();

      _activeSubscriptions.remove(collection);

      if (kDebugMode) {
        debugPrint(
          'Stream cancelado: $collection',
        );
      }
    }
  }

  void cancelAllStreams() {
    for (final subscription
        in _activeSubscriptions.values) {
      subscription.cancel();
    }

    _activeSubscriptions.clear();

    if (kDebugMode) {
      debugPrint(
        'Todos los streams cancelados',
      );
    }
  }

  Future<Map<String, dynamic>>
      getEstadisticas() async {
    return await FirestoreCacheManager
        .obtenerEstadisticasCache();
  }

  Future<void> resetCache() async {
    cancelAllStreams();

    await FirestoreCacheManager
        .limpiarTodoCache();

    if (kDebugMode) {
      debugPrint('Cache reiniciado');
    }
  }

  void dispose() {
    cancelAllStreams();
  }
}
