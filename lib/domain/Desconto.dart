class Desconto {
  String? id;
  double valor;
  String motivo;

  Desconto({
    this.id,
    required this.valor,
    required this.motivo,
  });

  factory Desconto.fromMap(String id, Map<String, dynamic> map) {
    return Desconto(
      id: id,
      valor: (map['valor'] as num).toDouble(),
      motivo: map['motivo'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'valor': valor,
      'motivo': motivo,
    };
  }

  @override
  String toString() {
    return 'Desconto{id: $id, valor: $valor, motivo: $motivo}';
  }
}
