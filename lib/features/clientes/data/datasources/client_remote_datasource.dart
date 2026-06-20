import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client_dto.dart';
import '../models/paginated_clients_result.dart';

import '../../../../core/firestore/firestore_service.dart';
import '../../../../core/firestore/firestore_collections.dart';

class ClientRemoteDatasource {
  final FirestoreService firestoreService;

  ClientRemoteDatasource(
    this.firestoreService,
  );

  Future<void> guardarCliente(
    ClientDTO cliente,
  ) async {
    await firestoreService
        .collection(
          FirestoreCollections.clientes,
        )
        .doc(cliente.id)
        .set(
          cliente.aMapa(),
        );
  }

  Future<void> actualizarCliente(
    ClientDTO cliente,
  ) async {
    await firestoreService
        .collection(
          FirestoreCollections.clientes,
        )
        .doc(cliente.id)
        .update(
          cliente.aMapa(),
        );
  }

  Future<void> eliminarCliente(
    String id,
  ) async {
    await firestoreService
        .collection(
          FirestoreCollections.clientes,
        )
        .doc(id)
        .update(
      {
        'isDeleted': true,
      },
    );
  }

  Future<PaginatedClientsResult>
      obtenerClientesPaginados({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>?
        lastDocument,
  }) async {
    Query<Map<String, dynamic>> query =
        firestoreService
            .collection(
              FirestoreCollections.clientes,
            )
            .where(
              'isDeleted',
              isEqualTo: false,
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

    final clientes =
        snapshot.docs.map(
      (doc) {
        return ClientDTO.desdeMapa(
          doc.data(),
          doc.id,
        );
      },
    ).toList();

    return PaginatedClientsResult(
      clientes: clientes,
      lastDocument:
          snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : null,
      hasMore:
          snapshot.docs.length >= limit,
    );
  }
}