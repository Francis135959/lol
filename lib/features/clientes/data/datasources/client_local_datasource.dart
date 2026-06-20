import '../models/client_dto.dart';

import '../../../../core/firestore/firestore_service.dart';

import '../../../../core/firestore/firestore_collections.dart';

class ClientLocalDatasource {

  final FirestoreService firestoreService;

  ClientLocalDatasource(
    this.firestoreService,
  );

  Stream<List<ClientDTO>>
      watchClientes() {

    return firestoreService
        .collection(FirestoreCollections.clientes)
        .where('isDeleted',isEqualTo: false,)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(
            (doc) { return ClientDTO.desdeMapa(doc.data(),doc.id,); },
            ).toList(); } );
  }

  Future<List<ClientDTO>>
      obtenerClientes() async {

    final snapshot =
        await firestoreService
            .collection(FirestoreCollections.clientes,)
            .where('isDeleted',isEqualTo: false,)
            .get();

    return snapshot.docs.map(
      (doc) {
        return ClientDTO.desdeMapa(
          doc.data(),
          doc.id,
        );
      },
    ).toList();
  }

  Future<ClientDTO?>
      obtenerCliente(
    String id,
  ) async {

    final doc =
        await firestoreService
            .collection(
              FirestoreCollections.clientes,
            )

            .doc(id)
            .get();

    if (!doc.exists) {
      return null;
    }

    return ClientDTO.desdeMapa(doc.data()!,doc.id,);
  }
}