class LaborItemEntity {
  final String cargo;
  final int valorJornada;
  final int dias;

  LaborItemEntity({
    required this.cargo,
    required this.valorJornada,
    required this.dias,
  });

  // Getter para calcular el total
  int get subtotal => valorJornada * dias;
  // Agregamos total (doble) para mantener la compatibilidad con el PDF
  double get total => subtotal.toDouble(); 
}