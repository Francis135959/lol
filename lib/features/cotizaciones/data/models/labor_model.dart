class LaborModel {
  String id;
  String cargo;
  int valorJornada;
  int dias;

  LaborModel({
    required this.id,
    required this.cargo,
    required this.valorJornada,
    required this.dias,
  });

  int get subtotal => valorJornada * dias;

  LaborModel copyWith({
    String? id,
    String? cargo,
    int? valorJornada,
    int? dias,
  }) {
    return LaborModel(
      id: id ?? this.id,
      cargo: cargo ?? this.cargo,
      valorJornada: valorJornada ?? this.valorJornada,
      dias: dias ?? this.dias,
    );
  }
}