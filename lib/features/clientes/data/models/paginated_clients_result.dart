import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client_entity.dart';

class PaginatedClientsResult {
  final List<ClientEntity> clientes;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;

  const PaginatedClientsResult({
    required this.clientes,
    required this.lastDocument,
    required this.hasMore,
  });
}