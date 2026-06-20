import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_collections.dart';
import '../../../../core/firestore/firestore_service.dart';

import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

import '../datasources/client_remote_datasource.dart';

import '../models/client_dto.dart';
import '../models/paginated_clients_result.dart';

import '../../utils/client_validators.dart';

class ClientRepositoryImpl
    implements ClientRepository {
  final FirestoreService firestoreService;

  final ClientRemoteDatasource
      remoteDatasource;

  ClientRepositoryImpl(
    this.firestoreService,
    this.remoteDatasource,
  );

  CollectionReference<Map<String, dynamic>>
      get _clientsCollection {
    return firestoreService.collection(
      FirestoreCollections.clientes,
    );
  }

  @override
  Future<void> guardarCliente(
    ClientEntity cliente,
  ) async {
    final dto = ClientDTO(
      id: cliente.id,
      nombre: cliente.nombre,
      rut: cliente.rut,
      telefono: cliente.telefono,
      correo: cliente.correo,
      createdAt: cliente.createdAt,
      isDeleted: cliente.isDeleted,
    );

    await _clientsCollection
        .doc(cliente.id)
        .set(
          dto.aMapa(),
        );
  }

  @override
  Future<void> actualizarCliente(
    ClientEntity cliente,
  ) async {
    final dto = ClientDTO(
      id: cliente.id,
      nombre: cliente.nombre,
      rut: cliente.rut,
      telefono: cliente.telefono,
      correo: cliente.correo,
      createdAt: cliente.createdAt,
      isDeleted: cliente.isDeleted,
    );

    await _clientsCollection
        .doc(cliente.id)
        .update(
          dto.aMapa(),
        );
  }

  @override
  Future<void> eliminarCliente(
    String id,
  ) async {
    await _clientsCollection
        .doc(id)
        .update(
      {
        'isDeleted': true,
      },
    );
  }

  @override
  Future<ClientEntity?>
      obtenerCliente(
    String id,
  ) async {
    final doc =
        await _clientsCollection
            .doc(id)
            .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return ClientDTO.desdeMapa(
      data,
      doc.id,
    );
  }

  @override
  Future<List<ClientEntity>>
      obtenerClientes() async {
    final snapshot =
        await _clientsCollection
            .where(
              'isDeleted',
              isEqualTo: false,
            )
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

  @override
  Stream<List<ClientEntity>>
      watchClientes() {
    return _clientsCollection
        .where(
          'isDeleted',
          isEqualTo: false,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return ClientDTO.desdeMapa(
              doc.data(),
              doc.id,
            );
          },
        ).toList();
      },
    );
  }

  @override
  Future<List<ClientEntity>>
      buscarClientes(
    String query,
    includeDeleted,
  ) async {
    final QuerySnapshot<
            Map<String, dynamic>>
        snapshot;

    if (includeDeleted) {
      snapshot =
          await _clientsCollection.get();
    } else {
      snapshot =
          await _clientsCollection
              .where(
                'isDeleted',
                isEqualTo: false,
              )
              .get();
    }

    final clientes =
        snapshot.docs.map(
      (doc) {
        return ClientDTO.desdeMapa(
          doc.data(),
          doc.id,
        );
      },
    ).toList();

    final queryNormalizado =
        ClientValidators.normalizarRut(
      query,
    );

    return clientes.where(
      (cliente) {
        final clienteRutNormalizado =
            ClientValidators
                .normalizarRut(
          cliente.rut,
        );

        if (clienteRutNormalizado ==
            queryNormalizado) {
          return true;
        }

        final queryLower =
            query.toLowerCase();

        return cliente.nombre
                .toLowerCase()
                .contains(
                  queryLower,
                ) ||
            cliente.rut
                .toLowerCase()
                .contains(
                  queryLower,
                ) ||
            cliente.correo
                .toLowerCase()
                .contains(
                  queryLower,
                ) ||
            cliente.telefono
                .toLowerCase()
                .contains(
                  queryLower,
                );
      },
    ).toList();
  }

  @override
  Future<ClientEntity?>
      buscarPorRut(
    String rut,
  ) async {
    final rutNormalizado =
        ClientValidators.normalizarRut(
      rut,
    );

    final snapshot =
        await _clientsCollection
            .where(
              'rutNormalizado',
              isEqualTo:
                  rutNormalizado,
            )
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc =
        snapshot.docs.first;

    return ClientDTO.desdeMapa(
      doc.data(),
      doc.id,
    );
  }

  @override
  Future<PaginatedClientsResult>
      obtenerClientesPaginados({
    int limit = 20,
    DocumentSnapshot<
            Map<String, dynamic>>?
        lastDocument,
  }) {
    return remoteDatasource
        .obtenerClientesPaginados(
      limit: limit,
      lastDocument: lastDocument,
    );
  }
}