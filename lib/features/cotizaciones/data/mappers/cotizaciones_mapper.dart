import '../models/model_cotizacion.dart';
import '../../domain/entities/entidad_cotizacion.dart';

class CotizacionMapper {
  static EntidadCotizacion aEntidad(ModelCotizacion model) {
    return EntidadCotizacion(
      id: model.id,
      clienteId: model.clienteId,
      nombreCliente: model.nombreCliente,
      materials: model.materials,
      labor: model.labor,
      metrosCuadrados: model.metrosCuadrados,
      direccion: model.direccion,
      tipoTrabajo: model.tipoTrabajo,
      transport: model.transport,
      utility: model.utility,
      iva: model.iva,
      total: model.total,
      status: model.status,
      version: model.version,
      createdAt: model.createdAt,
    );
  }
  static ModelCotizacion aModel(EntidadCotizacion entidad) {
    return ModelCotizacion(
      id: entidad.id,
      clienteId: entidad.clienteId,
      nombreCliente: entidad.nombreCliente,
      materials: entidad.materials,
      labor: entidad.labor,
      metrosCuadrados: entidad.metrosCuadrados,
      direccion: entidad.direccion,
      tipoTrabajo: entidad.tipoTrabajo,
      transport: entidad.transport,
      utility: entidad.utility,
      iva: entidad.iva,
      total: entidad.total,
      status: entidad.status,
      version: entidad.version,
      createdAt: entidad.createdAt,
    );
  }
}