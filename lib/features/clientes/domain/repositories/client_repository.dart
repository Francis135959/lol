import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/client_entity.dart';
import '../../data/models/paginated_clients_result.dart';

abstract class ClientRepository {
  Future<void> guardarCliente(
    ClientEntity cliente,
  );

  Future<void> actualizarCliente(
    ClientEntity cliente,
  );

  Future<void> eliminarCliente(
    String id,
  );

  Future<ClientEntity?> obtenerCliente(
    String id,
  );

  Future<List<ClientEntity>> obtenerClientes();

  Stream<List<ClientEntity>> watchClientes();

  Future<List<ClientEntity>> buscarClientes(
    String query,
    bool includeDeleted,
  );

  Future<ClientEntity?> buscarPorRut(
    String rut,
  );

  Future<PaginatedClientsResult> obtenerClientesPaginados({
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  });
}