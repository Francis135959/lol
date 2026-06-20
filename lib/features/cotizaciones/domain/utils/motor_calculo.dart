class ResultadoCotizacion {
  final double subtotalMateriales;
  final double subtotalManoObra;
  final double transporte;
  final double subtotalBase;
  final double montoUtilidad;
  final double subtotalConUtilidad;
  final double montoIva;
  final double totalFinal;
  final bool advertenciaUtilidadBaja;

  ResultadoCotizacion({
    required this.subtotalMateriales,
    required this.subtotalManoObra,
    required this.transporte,
    required this.subtotalBase,
    required this.montoUtilidad,
    required this.subtotalConUtilidad,
    required this.montoIva,
    required this.totalFinal,
    required this.advertenciaUtilidadBaja,
  });
}

class MotorCalculo {
  static ResultadoCotizacion calcular({
    required double totalMateriales,
    required double totalManoObra,
    required double transporte,
    required double porcentajeUtilidad,
    required double porcentajeIva,
  }) {
    // 1. Subtotal base (sin utilidad ni IVA)
    final double base = totalMateriales + totalManoObra + transporte;
    
    // 2. Monto de utilidad
    final double utilidad = base * porcentajeUtilidad;
    
    // 3. Subtotal con utilidad
    final double baseConUtilidad = base + utilidad;
    
    // 4. Monto de IVA
    final double iva = baseConUtilidad * porcentajeIva;
    
    // 5. Total final
    final double total = baseConUtilidad + iva;

    // Redondeo (CLP: entero, USD: 2 decimales)
    double redondear(double valor) => valor.roundToDouble();

    return ResultadoCotizacion(
      subtotalMateriales: redondear(totalMateriales),
      subtotalManoObra: redondear(totalManoObra),
      transporte: redondear(transporte),
      subtotalBase: redondear(base),
      montoUtilidad: redondear(utilidad),
      subtotalConUtilidad: redondear(baseConUtilidad),
      montoIva: redondear(iva),
      totalFinal: redondear(total),
      advertenciaUtilidadBaja: porcentajeUtilidad < 0.10, // Menos de 10%
    );
  }
}