
import '../domain/entities/client_entity.dart';

class ClientValidators {
  static String normalizarRut(String rutIngresado) {
    if (rutIngresado.isEmpty) return '';

    return rutIngresado
        .replaceAll('.', '')
        .replaceAll('-', '')
        .toUpperCase()
        .trim();
  }

  static bool esRutValido(String rut) {
    final rutLimpio = normalizarRut(rut);

    if (rutLimpio.length < 2) {
      return false;
    }

    final cuerpo = rutLimpio.substring(
      0,
      rutLimpio.length - 1,
    );

    final dv = rutLimpio.substring(
      rutLimpio.length - 1,
    );

    if (!RegExp(r'^\d+$').hasMatch(cuerpo)) {
      return false;
    }

    int suma = 0;
    int multiplicador = 2;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      suma += int.parse(cuerpo[i]) * multiplicador;

      multiplicador++;

      if (multiplicador > 7) {
        multiplicador = 2;
      }
    }

    final resto = suma % 11;
    final dvCalculado = 11 - resto;

    String dvFinal;

    if (dvCalculado == 11) {
      dvFinal = '0';
    } else if (dvCalculado == 10) {
      dvFinal = 'K';
    } else {
      dvFinal = dvCalculado.toString();
    }

    return dv == dvFinal;
  }

  static bool esRutUnico(
    String rutAValidar,
    List<ClientEntity> clientesExistentes,
  ) {
    final entradaNormalizada =
        normalizarRut(rutAValidar);

    final estaDuplicado =
        clientesExistentes.any(
      (cliente) {
        return normalizarRut(cliente.rut) ==
            entradaNormalizada;
      },
    );

    return !estaDuplicado;
  }

  static bool esCorreoValido(String correo) {
    return RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    ).hasMatch(correo);
  }

  static bool esTelefonoValido(String telefono) {
    final limpio = telefono.replaceAll(' ', '').replaceAll('+56', '');
    return RegExp(r'^\d{9}$').hasMatch(limpio);
  }

  static bool esNombreValido(String nombre) {
    final limpio = nombre.trim();
    if (limpio.length < 3) return false;
    return RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(limpio);
  }
}