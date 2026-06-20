import 'package:flutter/material.dart';

/// Fábrica centralizada de [InputDecoration].
///
/// Todas las pantallas de formulario (clientes, cotizaciones, configuración,
/// PIN, diálogos) **deben** usar esta clase para mantener un estilo visual
/// consistente con [OutlineInputBorder].
class AppInputDecoration {
  AppInputDecoration._(); // No instanciable

  /// Decoración estándar para campos de texto de formulario.
  ///
  /// Usa [OutlineInputBorder] con bordes redondeados de 8px, fondo relleno
  /// y colores que se adaptan al tema claro/oscuro.
  static InputDecoration field({
    required String label,
    String? errorText,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    String? counterText,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      errorText: errorText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      counterText: counterText,
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    );
  }

  /// Decoración para barras de búsqueda (bordes más redondeados).
  static InputDecoration search({
    String hintText = 'Buscar...',
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      filled: true,
    );
  }

  /// Decoración compacta para campos dentro de diálogos.
  static InputDecoration dialog({
    required String label,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
    );
  }

  /// Decoración mínima sin label (ej: campo de PIN centrado).
  static InputDecoration pin({
    String? hintText,
    String? errorText,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      counterText: counterText ?? '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    );
  }
}
