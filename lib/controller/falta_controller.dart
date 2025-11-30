import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/falta.dart';

class FaltaController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _faltasCollection =
      _firestore.collection('Falta');


  static Future<String?> adicionarFalta(Falta falta) async {
    try {
      final docRef = await _faltasCollection.add(falta.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar falta: $e');
      return null;
    }
  }


  static Future<Falta?> buscarFaltaPorId(String id) async {
    try {
      final doc = await _faltasCollection.doc(id).get();
      if (doc.exists) {
        return Falta.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar falta: $e');
      return null;
    }
  }

  static Future<List<Falta>> buscarFaltasPorFuncionario(String funcionarioId) async {
    try {
      final snapshot = await _faltasCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .get();


      final faltas = snapshot.docs
          .map((doc) => Falta.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      // Ordenar por data decrescente
      faltas.sort((a, b) => b.data.compareTo(a.data));
      
      return faltas;
    } catch (e) {
      print('Erro ao buscar faltas do funcionário: $e');
      return [];
    }
  }

  static Future<List<Falta>> buscarFaltasPorPeriodo({
    required String funcionarioId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final snapshot = await _faltasCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .get();
      
      final faltas = snapshot.docs
          .map((doc) => Falta.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((falta) {
            return falta.data.isAfter(dataInicio.subtract(Duration(seconds: 1))) &&
                   falta.data.isBefore(dataFim.add(Duration(seconds: 1)));
          })
          .toList();
      
      faltas.sort((a, b) => b.data.compareTo(a.data));
      
      return faltas;
    } catch (e) {
      print('Erro ao buscar faltas por período: $e');
      return [];
    }
  }

  static Future<List<Falta>> buscarFaltasPorMesAno({
    required String funcionarioId,
    required int mes,
    required int ano,
  }) async {
    try {
      final dataInicio = DateTime(ano, mes, 1);
      final dataFim = DateTime(ano, mes + 1, 0, 23, 59, 59);
      
      return await buscarFaltasPorPeriodo(
        funcionarioId: funcionarioId,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
    } catch (e) {
      print('Erro ao buscar faltas por mês/ano: $e');
      return [];
    }
  }

  static Future<int> contarFaltasPorFuncionario(String funcionarioId) async {
    try {
      final snapshot = await _faltasCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao contar faltas: $e');
      return 0;
    }
  }

  static Future<int> contarFaltasPorMesAno({
    required String funcionarioId,
    required int mes,
    required int ano,
  }) async {
    try {
      final faltas = await buscarFaltasPorMesAno(
        funcionarioId: funcionarioId,
        mes: mes,
        ano: ano,
      );
      return faltas.length;
    } catch (e) {
      print('Erro ao contar faltas por mês/ano: $e');
      return 0;
    }
  }

  static Future<bool> atualizarFalta(String id, Falta falta) async {
    try {
      await _faltasCollection.doc(id).update(falta.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar falta: $e');
      return false;
    }
  }

  static Future<bool> removerFalta(String id) async {
    try {
      await _faltasCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao remover falta: $e');
      return false;
    }
  }

  static Stream<List<Falta>> streamFaltasPorFuncionario(String funcionarioId) {
    return _faltasCollection
        .where('funcionarioId', isEqualTo: funcionarioId)
        .snapshots()
        .map((snapshot) {
      final faltas = snapshot.docs
          .map((doc) => Falta.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      faltas.sort((a, b) => b.data.compareTo(a.data));
      
      return faltas;
    });
  }

  static Future<List<Falta>> buscarTodasFaltas() async {
    try {
      final snapshot = await _faltasCollection.get();
      
      final faltas = snapshot.docs
          .map((doc) => Falta.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      faltas.sort((a, b) => b.data.compareTo(a.data));
      
      return faltas;
    } catch (e) {
      print('Erro ao buscar todas as faltas: $e');
      return [];
    }
  }

  static Stream<List<Falta>> streamTodasFaltas() {
    return _faltasCollection
        .snapshots()
        .map((snapshot) {
      final faltas = snapshot.docs
          .map((doc) => Falta.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      faltas.sort((a, b) => b.data.compareTo(a.data));
      
      return faltas;
    });
  }
}
