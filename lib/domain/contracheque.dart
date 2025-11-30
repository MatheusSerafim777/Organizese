class Contracheque {
  String? id;
  String? funcionarioId;
  double valorSalarioBruto;
  double valorSalarioLiquido;
  int mes;
  int ano;
  double acrescimos;
  
  // Listas de IDs de benefícios e descontos
  List<String> beneficiosIds;
  List<String> descontosIds;

  Contracheque({
    this.id,
    this.funcionarioId,
    required this.valorSalarioBruto,
    required this.valorSalarioLiquido,
    required this.mes,
    required this.ano,
    this.acrescimos = 0.0,
    this.beneficiosIds = const [],
    this.descontosIds = const [],
  });

  factory Contracheque.fromMap(String id, Map<String, dynamic> map) {
    return Contracheque(
      id: id,
      funcionarioId: map['funcionarioId'] as String?,
      valorSalarioBruto: (map['valorSalarioBruto'] as num).toDouble(),
      valorSalarioLiquido: (map['valorSalarioLiquido'] as num).toDouble(),
      mes: map['mes'] as int,
      ano: map['ano'] as int,
      acrescimos: (map['acrescimos'] as num?)?.toDouble() ?? 0.0,
      beneficiosIds: (map['beneficiosIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      descontosIds: (map['descontosIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'funcionarioId': funcionarioId,
      'valorSalarioBruto': valorSalarioBruto,
      'valorSalarioLiquido': valorSalarioLiquido,
      'mes': mes,
      'ano': ano,
      'acrescimos': acrescimos,
      'beneficiosIds': beneficiosIds,
      'descontosIds': descontosIds,
    };
  }

  @override
  String toString() {
    return 'Contracheque{id: $id, funcionarioId: $funcionarioId, '
        'mes: $mes, ano: $ano, bruto: $valorSalarioBruto, liquido: $valorSalarioLiquido}';
  }
}
