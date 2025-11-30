class Cargo {
  String id;
  String nome;
  double salario;

  Cargo({required this.id, required this.nome, required this.salario});

  factory Cargo.fromMap(String id, Map<String, dynamic> map) => Cargo(
    id: id,
    nome: map['nome'] as String,
    salario: (map['salario'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'salario': salario,
  };

}
