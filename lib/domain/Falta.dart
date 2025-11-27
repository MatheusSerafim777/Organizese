class Falta {
  String? id;
  String motivo;
  DateTime data;
  String? funcionarioId;
  bool faltaJustificada;

  Falta({
    this.id,
    required this.motivo,
    required this.data,
    this.funcionarioId,
    this.faltaJustificada = false, // Padrão: falta não justificada
  });

  factory Falta.fromMap(String id, Map<String, dynamic> map) {
    return Falta(
      id: id,
      motivo: map['motivo'] as String,
      data: (map['data'] is DateTime)
          ? map['data'] as DateTime
          : (map['data']).toDate(),
      funcionarioId: map['funcionarioId'] as String?,
      faltaJustificada: map['faltaJustificada'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'motivo': motivo,
      'data': data,
      'funcionarioId': funcionarioId,
      'faltaJustificada': faltaJustificada,
    };
  }

  @override
  String toString() {
    return 'Falta{id: $id, motivo: $motivo, data: $data, funcionarioId: $funcionarioId, faltaJustificada: $faltaJustificada}';
  }
}
