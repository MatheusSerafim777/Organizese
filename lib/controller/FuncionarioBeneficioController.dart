import 'package:cloud_firestore/cloud_firestore.dart';

class FuncionarioBeneficioController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _funcionarioBeneficioCollection =
      _firestore.collection('Funcionario_Beneficio');

  /// Adicionar benefício a um funcionário
  static Future<String?> adicionarBeneficioAoFuncionario({
    required String funcionarioId,
    required String beneficioId,
  }) async {
    try {
      // Verificar se já existe essa associação
      final existente = await _funcionarioBeneficioCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .where('beneficioId', isEqualTo: beneficioId)
          .limit(1)
          .get();

      if (existente.docs.isNotEmpty) {
        return existente.docs.first.id; // Já existe
      }

      // Criar nova associação
      final docRef = await _funcionarioBeneficioCollection.add({
        'funcionarioId': funcionarioId,
        'beneficioId': beneficioId,
        'dataConcessao': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar benefício ao funcionário: $e');
      return null;
    }
  }

  /// Adicionar múltiplos benefícios a um funcionário de uma vez
  static Future<bool> adicionarBeneficiosAoFuncionario({
    required String funcionarioId,
    required List<String> beneficiosIds,
  }) async {
    try {
      // Usar batch para operação atômica
      final batch = _firestore.batch();

      for (String beneficioId in beneficiosIds) {
        // Verificar se já existe
        final existente = await _funcionarioBeneficioCollection
            .where('funcionarioId', isEqualTo: funcionarioId)
            .where('beneficioId', isEqualTo: beneficioId)
            .limit(1)
            .get();

        if (existente.docs.isEmpty) {
          // Criar novo documento
          final docRef = _funcionarioBeneficioCollection.doc();
          batch.set(docRef, {
            'funcionarioId': funcionarioId,
            'beneficioId': beneficioId,
            'dataConcessao': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Erro ao adicionar benefícios ao funcionário: $e');
      return false;
    }
  }

  /// Buscar todos os benefícios de um funcionário (retorna IDs)
  static Future<List<String>> buscarBeneficiosPorFuncionario(String funcionarioId) async {
    try {
      final snapshot = await _funcionarioBeneficioCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['beneficioId'] as String)
          .toList();
    } catch (e) {
      print('Erro ao buscar benefícios do funcionário: $e');
      return [];
    }
  }

  /// Buscar todos os funcionários que têm um determinado benefício (retorna IDs)
  static Future<List<String>> buscarFuncionariosPorBeneficio(String beneficioId) async {
    try {
      final snapshot = await _funcionarioBeneficioCollection
          .where('beneficioId', isEqualTo: beneficioId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['funcionarioId'] as String)
          .toList();
    } catch (e) {
      print('Erro ao buscar funcionários com benefício: $e');
      return [];
    }
  }

  /// Remover benefício de um funcionário
  static Future<bool> removerBeneficioDoFuncionario({
    required String funcionarioId,
    required String beneficioId,
  }) async {
    try {
      final snapshot = await _funcionarioBeneficioCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .where('beneficioId', isEqualTo: beneficioId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      return true;
    } catch (e) {
      print('Erro ao remover benefício do funcionário: $e');
      return false;
    }
  }

  /// Remover todos os benefícios de um funcionário
  static Future<bool> removerTodosBeneficiosDoFuncionario(String funcionarioId) async {
    try {
      final snapshot = await _funcionarioBeneficioCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return true;
    } catch (e) {
      print('Erro ao remover benefícios do funcionário: $e');
      return false;
    }
  }

  /// Stream de benefícios de um funcionário (para UI reativa)
  static Stream<List<String>> streamBeneficiosPorFuncionario(String funcionarioId) {
    return _funcionarioBeneficioCollection
        .where('funcionarioId', isEqualTo: funcionarioId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['beneficioId'] as String)
          .toList();
    });
  }

  /// Verificar se funcionário tem um benefício específico
  static Future<bool> funcionarioTemBeneficio({
    required String funcionarioId,
    required String beneficioId,
  }) async {
    try {
      final snapshot = await _funcionarioBeneficioCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .where('beneficioId', isEqualTo: beneficioId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar benefício: $e');
      return false;
    }
  }
}
