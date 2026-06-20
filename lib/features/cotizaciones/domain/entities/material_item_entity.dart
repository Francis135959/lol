class MaterialItemEntity {
  final String nombre;
  final double cantidad;
  final double precioUnitario;

  MaterialItemEntity({
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
  });

  // Getter para calcular el total rápido sin gastar CPU extra después
  double get total => cantidad * precioUnitario;
  int get subtotal => cantidad.toInt() * precioUnitario.toInt();
}