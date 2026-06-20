import '../models/client_dto.dart';
import '../../domain/entities/client_entity.dart';

class ClientMapper {
  static ClientEntity aEntidad(ClientDTO dto) {
    return ClientEntity(
      id: dto.id,
      nombre: dto.nombre,
      rut: dto.rut,
      telefono: dto.telefono,
      correo: dto.correo,
      isDeleted: dto.isDeleted,
      createdAt: dto.createdAt
    );
  }

  static ClientDTO aDTO(ClientEntity entidad) {
    return ClientDTO(
      id: entidad.id,
      nombre: entidad.nombre,
      rut: entidad.rut,
      telefono: entidad.telefono,
      correo: entidad.correo,
      isDeleted: entidad.isDeleted,
      createdAt: entidad.createdAt
    );
  }
}