import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_collections.dart';
import '../../../../core/firestore/firestore_service.dart';

import '../models/model_cotizacion.dart';

class CotizacionLocalDatasource {
  final FirestoreService firestoreService;

  CotizacionLocalDatasource(
    this.firestoreService,
  );

  Future<List<ModelCotizacion>> obtenerCotizaciones() async {
    final snapshot = await firestoreService
        .collection(FirestoreCollections.cotizaciones)
        .orderBy('createdAt', descending: true)
        .get(
          const GetOptions(
            source: Source.cache,
          ),
        );

    return snapshot.docs.map((doc) {
      return ModelCotizacion.fromJson(
        doc.data(),
      );
    }).toList();
  }
}