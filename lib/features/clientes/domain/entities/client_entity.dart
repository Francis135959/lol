class ClientEntity {
  final String id;
  final String nombre;
  final String rut;
  final String telefono;
  final String correo;
  final bool isDeleted;
  final DateTime createdAt;

  ClientEntity({
    required this.id,
    required this.nombre,
    required this.rut,
    required this.telefono,
    required this.correo,
    this.isDeleted = false,
    required this.createdAt
  });
}