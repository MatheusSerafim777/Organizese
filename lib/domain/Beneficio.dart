class Beneficio {
  String? id;
  String nome;

  Beneficio({
    this.id,
    required this.nome,
  });

  factory Beneficio.fromMap(String id, Map<String, dynamic> map) {
    return Beneficio(
      id: id,
      nome: map['nome'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
    };
  }

  @override
  String toString() {
    return 'Beneficio{id: $id, nome: $nome}';
  }
}
