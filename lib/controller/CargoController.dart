import 'package:organizese/domain/Cargo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CargoController {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final List<Cargo> _cargosPredefinidos = [
    Cargo(id: '1', nome: 'Estagiário', salario: 1000.0),
    Cargo(id: '2', nome: 'Assistente', salario: 1800.0),
    Cargo(id: '3', nome: 'Analista Júnior', salario: 3000.0),
    Cargo(id: '4', nome: 'Analista Pleno', salario: 5000.0),
    Cargo(id: '5', nome: 'Analista Sênior', salario: 8000.0),
    Cargo(id: '6', nome: 'Coordenador', salario: 10000.0),
    Cargo(id: '7', nome: 'Gerente', salario: 15000.0),
  ];

  // Inicializa os cargos no Firestore (chame uma vez para popular o banco)
  static Future<void> inicializarCargosNoBanco() async {
    try {
      final batch = _db.batch();
      
      for (final cargo in _cargosPredefinidos) {
        final docRef = _db.collection('Cargo').doc(cargo.id);
        batch.set(docRef, cargo.toMap());
      }
      
      await batch.commit();
      print('Cargos inicializados com sucesso no Firestore');
    } catch (e) {
      print('Erro ao inicializar cargos: $e');
    }
  }

  static Future<List<Cargo>> obterTodosCargos() async {
    try {
      final querySnapshot = await _db.collection('Cargo').orderBy('salario').get();
      return querySnapshot.docs.map((doc) {
        return Cargo.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Erro ao buscar cargos: $e');
      // Retorna cargos locais como fallback
      return List.from(_cargosPredefinidos);
    }
  }

  // Busca um cargo pelo ID no Firestore
  static Future<Cargo?> obterCargoPorId(String id) async {
    try {
      final docSnapshot = await _db.collection('Cargo').doc(id).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return Cargo.fromMap(docSnapshot.id, docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar cargo por ID: $e');
      try {
        return _cargosPredefinidos.firstWhere((cargo) => cargo.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  static Future<Cargo?> obterCargoPorNome(String nome) async {
    try {
      final querySnapshot = await _db.collection('Cargo')
          .where('nome', isEqualTo: nome)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Cargo.fromMap(doc.id, doc.data());
      }
      return null;
    } catch (e) {
      print('Erro ao buscar cargo por nome: $e');
      try {
        return _cargosPredefinidos.firstWhere((cargo) => cargo.nome == nome);
      } catch (e) {
        return null;
      }
    }
  }

  static Future<double> obterSalarioPorCargoId(String cargoId) async {
    final cargo = await obterCargoPorId(cargoId);
    return cargo?.salario ?? 0.0;
  }

  static Future<String?> adicionarCargo(String nome, double salario) async {
    try {
      final docRef = await _db.collection('Cargo').add({
        'nome': nome,
        'salario': salario,
      });
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar cargo: $e');
      return null;
    }
  }

  static Future<bool> atualizarCargo(String id, String nome, double salario) async {
    try {
      await _db.collection('Cargo').doc(id).update({
        'nome': nome,
        'salario': salario,
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar cargo: $e');
      return false;
    }
  }

  static Future<bool> removerCargo(String id) async {
    try {
      await _db.collection('Cargo').doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao remover cargo: $e');
      return false;
    }
  }

  static Stream<List<Cargo>> streamCargos() {
    return _db.collection('Cargo').orderBy('salario').snapshots().map(
      (querySnapshot) => querySnapshot.docs.map((doc) {
        return Cargo.fromMap(doc.id, doc.data());
      }).toList(),
    );
  }
}
