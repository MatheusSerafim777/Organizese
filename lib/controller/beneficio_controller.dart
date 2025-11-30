import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/beneficio.dart';

class BeneficioController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _beneficiosCollection =
      _firestore.collection('Beneficio');

  // Benefícios padrões do sistema
  static final List<Map<String, String>> beneficiosPadroes = [
    {'nome': 'Vale Transporte'},
    {'nome': 'Vale Alimentação'},
    {'nome': 'Vale Refeição'},
    {'nome': 'Plano de Saúde'},
    {'nome': 'Plano Odontológico'},
    {'nome': 'Seguro de Vida'},
  ];

  // Inicializar benefícios padrões no Firestore
  static Future<void> inicializarBeneficiosPadroes() async {
    try {
      final snapshot = await _beneficiosCollection.limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        print('Inicializando benefícios padrões...');
        
        for (var beneficio in beneficiosPadroes) {
          await _beneficiosCollection.add(beneficio);
        }
        
        print('Benefícios padrões criados com sucesso!');
      } else {
        print('Benefícios já existem no Firestore.');
      }
    } catch (e) {
      print('Erro ao inicializar benefícios: $e');
    }
  }

  // Buscar todos os benefícios
  static Future<List<Beneficio>> buscarTodosBeneficios() async {
    try {
      final snapshot = await _beneficiosCollection.get();
      return snapshot.docs
          .map((doc) => Beneficio.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar benefícios: $e');
      return [];
    }
  }

  // Buscar benefício por ID
  static Future<Beneficio?> buscarBeneficioPorId(String id) async {
    try {
      final doc = await _beneficiosCollection.doc(id).get();
      if (doc.exists) {
        return Beneficio.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar benefício: $e');
      return null;
    }
  }

  // Adicionar novo benefício
  static Future<String?> adicionarBeneficio(Beneficio beneficio) async {
    try {
      final docRef = await _beneficiosCollection.add(beneficio.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar benefício: $e');
      return null;
    }
  }

  // Atualizar benefício
  static Future<bool> atualizarBeneficio(String id, Beneficio beneficio) async {
    try {
      await _beneficiosCollection.doc(id).update(beneficio.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar benefício: $e');
      return false;
    }
  }

  // Remover benefício
  static Future<bool> removerBeneficio(String id) async {
    try {
      await _beneficiosCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao remover benefício: $e');
      return false;
    }
  }

  // Stream de benefícios (para uso em UI reativa)
  static Stream<List<Beneficio>> streamBeneficios() {
    return _beneficiosCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Beneficio.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
