import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/domain/Cargo.dart';
import 'package:organizese/controller/CargoController.dart';

class ControladorTelaInicial {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream para obter funcionários em tempo real
  Stream<List<FuncionarioComCargo>> obterFuncionarios() {
    return _db
        .collection('Funcionario')
        .where('dataDemissao', isNull: true) // Apenas funcionários ativos
        .snapshots()
        .asyncMap((snapshot) async {
      List<FuncionarioComCargo> funcionarios = [];
      
      for (var doc in snapshot.docs) {
        final funcionario = Funcionario.fromMap(doc.data(), id: doc.id);
        
        // Busca o cargo do funcionário
        Cargo? cargo;
        if (funcionario.cargoId != null) {
          cargo = await CargoController.obterCargoPorId(funcionario.cargoId!);
        }
        
        funcionarios.add(FuncionarioComCargo(
          funcionario: funcionario,
          cargo: cargo,
        ));
      }
      
      // Ordena por nome
      funcionarios.sort((a, b) => 
        (a.funcionario.nome ?? '').compareTo(b.funcionario.nome ?? ''));
      
      return funcionarios;
    });
  }

  // Obtém funcionários de forma simples (sem cargo)
  Stream<List<Funcionario>> obterFuncionariosSimples() {
    return _db
        .collection('Funcionario')
        .where('dataDemissao', isNull: true)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Funcionario.fromMap(doc.data(), id: doc.id))
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


// Classe auxiliar para funcionário com cargo
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
