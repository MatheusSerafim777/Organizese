class Funcionario {
  String? id;                // uid do Firebase Auth
  String? nome;
  int? idade;
  String? cpf;
  double? salario;
  bool? admin;
  DateTime? dataAdmissao;
  DateTime? dataDemissao;
  String? email;
  String? cargoId;

  Funcionario({
    this.id,
    this.nome,
    this.idade,
    this.cpf,
    this.salario,
    this.admin,
    this.dataAdmissao,
    this.dataDemissao,
    this.email,
    this.cargoId,
  });

  @override
  String toString() {
    return 'Funcionario{id: $id, nome: $nome, email: $email, idade: $idade, cpf: $cpf, '
        'salario: $salario, admin: $admin, dataAdmissao: $dataAdmissao, dataDemissao: $dataDemissao, cargoId: $cargoId}';
  }

  factory Funcionario.fromMap(Map<String, dynamic> map, {String? id}) {
    return Funcionario(
      id: id,
      nome: map['nome'] as String?,
      idade: (map['idade'] is int) ? map['idade'] as int? : (map['idade'] as num?)?.toInt(),
      cpf: map['cpf'] as String?,
      salario: (map['salario'] as num?)?.toDouble(),
      admin: map['admin'] as bool?,
      dataAdmissao: (map['dataAdmissao'] is DateTime)
          ? map['dataAdmissao'] as DateTime
          : (map['dataAdmissao'] != null ? (map['dataAdmissao']).toDate() : null),
      dataDemissao: (map['dataDemissao'] is DateTime)
          ? map['dataDemissao'] as DateTime
          : (map['dataDemissao'] != null ? (map['dataDemissao']).toDate() : null),
      email: map['email'] as String?,
      cargoId: map['cargoId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nome': nome,
      'idade': idade,
      'cpf': cpf,
      'salario': salario,
      'admin': admin,
      'dataAdmissao': dataAdmissao,   // pode ser DateTime; Firestore converte
      'dataDemissao': dataDemissao,   // null se ainda ativo
      'email': email,
      'cargoId': cargoId,
    };
  }
}
