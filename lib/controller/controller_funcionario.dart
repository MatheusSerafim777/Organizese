import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/domain/cargo.dart';
import 'package:organizese/controller/cargo_controller.dart';

class ControladorTelaInicial {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FuncionarioComCargo>> obterFuncionarios() {
    return _db
        .collection('Funcionario')
        .where('dataDemissao', isNull: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<FuncionarioComCargo> funcionarios = [];

      for (var doc in snapshot.docs) {
        final funcionario = Funcionario.fromMap(doc.data(), id: doc.id);

        if (funcionario.admin == true) {
          continue;
        }

        Cargo? cargo;
        if (funcionario.cargoId != null) {
          cargo = await CargoController.obterCargoPorId(funcionario.cargoId!);
        }

        funcionarios.add(FuncionarioComCargo(
          funcionario: funcionario,
          cargo: cargo,
        ));
      }

      funcionarios.sort((a, b) =>
        (a.funcionario.nome ?? '').compareTo(b.funcionario.nome ?? ''));

      return funcionarios;
    });
  }

  Stream<List<Funcionario>> obterFuncionariosSimples() {
    return _db
        .collection('Funcionario')
        .where('dataDemissao', isNull: true)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Funcionario.fromMap(doc.data(), id: doc.id))
        .where((funcionario) => funcionario.admin != true)
        .toList());
  }

  Future<double> obterValordaFolha() async {
    final snapshot = await _db
        .collection('Funcionario')
        .where('dataDemissao', isNull: true)
        .get();

    double total = 0.0;

    for (var doc in snapshot.docs) {
      final funcionario = Funcionario.fromMap(doc.data(), id: doc.id);

      if (funcionario.salario != null) {
        total += funcionario.salario!;
      }
    }

    return total;
  }
}


class FuncionarioComCargo {
  final Funcionario funcionario;
  final Cargo? cargo;

  FuncionarioComCargo({
    required this.funcionario,
    this.cargo,
  });

  String get nomeCargo => cargo?.nome ?? 'Cargo não definido';
  String get nomeCompleto => funcionario.nome ?? 'Nome não informado';
}
