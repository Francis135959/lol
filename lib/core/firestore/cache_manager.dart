import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreCacheManager {
  // Configuracion del cache
  static const int maxCacheMB = 100;

  // Colecciones controladas
  static const List<String> collections = ['clients', 'quotes',];

  // Configurar cache Firestore
  static void configurarCache() {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: maxCacheMB * 1024 * 1024,
    );

    if (kDebugMode) {
      debugPrint(
        'Cache Firestore configurado (${maxCacheMB}MB)',
      );
    }
  }


  static Future<void> limpiarTodoCache() async {
    try {
      await FirebaseFirestore.instance.terminate();

      await FirebaseFirestore.instance.clearPersistence();

      if (kDebugMode) {
        debugPrint('Cache local limpiado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error limpiando cache: $e');
      }
    }
  }

  // Estadisticas del cache
  static Future<Map<String, dynamic>>
      obtenerEstadisticasCache() async {
    final estadisticas = <String, dynamic>{};

    for (final collection in collections) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(collection)
            .get(
              const GetOptions(source: Source.cache),
            );

        estadisticas[collection] = {
          'documentos': snapshot.docs.length,
          'sizeEstimadoKB':
              _calcularSizeEstimado(snapshot.docs),
        };
      } catch (e) {
        estadisticas[collection] = {
          'error': e.toString(),
        };
      }
    }

    estadisticas['cacheMaxMB'] = maxCacheMB;

    return estadisticas;
  }

  // Estimación basica de tamaño cache
  static int _calcularSizeEstimado(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    return docs.length;
  }
}