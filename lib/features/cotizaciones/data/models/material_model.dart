class MaterialModel {
  String id;
  String nombre;
  int cantidad;
  int precioUnitario;

  MaterialModel({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
  });

  int get subtotal => cantidad * precioUnitario;

  MaterialModel copyWith({
    String? id,
    String? nombre,
    int? cantidad,
    int? precioUnitario,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
    );
  }
}