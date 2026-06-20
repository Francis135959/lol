import 'material_item_entity.dart';
import 'labor_item_entity.dart';

class EntidadCotizacion {
  final String id;
  final String clienteId;
  final String nombreCliente;
  
  final List<MaterialItemEntity> materials;
  final List<LaborItemEntity> labor; 
  
  final double metrosCuadrados;
  final String direccion;
  final List<String> tipoTrabajo;

  final double transport; 
  final double utility; 
  final double iva; 
  final double total;
  final String status;
  final int version;
  final DateTime createdAt;

  const EntidadCotizacion({
    required this.id,
    required this.clienteId,
    required this.nombreCliente,
    required this.materials,
    required this.labor,
    required this.metrosCuadrados,
    required this.direccion,
    required this.tipoTrabajo,
    required this.transport,
    required this.utility,
    required this.iva,
    required this.total,
    required this.status,
    required this.version,
    required this.createdAt,
  });
}