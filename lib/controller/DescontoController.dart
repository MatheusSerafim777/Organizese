import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/Desconto.dart';

class DescontoController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _descontosCollection =
      _firestore.collection('Desconto');

  // Descontos padrões do sistema
  static final List<Map<String, dynamic>> descontosPadroes = [
    {'motivo': 'INSS', 'valor': 0.0}, // valor será calculado (%)
    {'motivo': 'IRRF', 'valor': 0.0}, // valor será calculado (%)
    {'motivo': 'FGTS', 'valor': 0.0}, // valor será calculado (%)
    {'motivo': 'Vale Transporte', 'valor': 0.0}, // desconto opcional
    {'motivo': 'Plano de Saúde', 'valor': 0.0}, // desconto opcional
    {'motivo': 'Falta não Justificada', 'valor': 0.0},
    {'motivo': 'Atraso', 'valor': 0.0},
    {'motivo': 'Adiantamento Salarial', 'valor': 0.0},
  ];

  // Inicializar descontos padrões no Firestore
  static Future<void> inicializarDescontosPadroes() async {
    try {
      final snapshot = await _descontosCollection.limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        print('Inicializando descontos padrões...');
        
        for (var desconto in descontosPadroes) {
          await _descontosCollection.add(desconto);
        }
        
        print('Descontos padrões criados com sucesso!');
      } else {
        print('Descontos já existem no Firestore.');
      }
    } catch (e) {
      print('Erro ao inicializar descontos: $e');
    }
  }

  // Buscar todos os descontos
  static Future<List<Desconto>> buscarTodosDescontos() async {
    try {
      final snapshot = await _descontosCollection.get();
      return snapshot.docs
          .map((doc) => Desconto.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar descontos: $e');
      return [];
    }
  }

  // Buscar desconto por ID
  static Future<Desconto?> buscarDescontoPorId(String id) async {
    try {
      final doc = await _descontosCollection.doc(id).get();
      if (doc.exists) {
        return Desconto.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar desconto: $e');
      return null;
    }
  }

  // Adicionar novo desconto
  static Future<String?> adicionarDesconto(Desconto desconto) async {
    try {
      final docRef = await _descontosCollection.add(desconto.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar desconto: $e');
      return null;
    }
  }

  // Atualizar desconto
  static Future<bool> atualizarDesconto(String id, Desconto desconto) async {
    try {
      await _descontosCollection.doc(id).update(desconto.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar desconto: $e');
      return false;
    }
  }

  // Remover desconto
  static Future<bool> removerDesconto(String id) async {
    try {
      await _descontosCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao remover desconto: $e');
      return false;
    }
  }

  // Stream de descontos (para uso em UI reativa)
  static Stream<List<Desconto>> streamDescontos() {
    return _descontosCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Desconto.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Criar desconto de INSS baseado no salário
  static Desconto calcularINSS(double salario) {
    double valorDesconto = 0.0;
    
    // Tabela simplificada do INSS 2025
    if (salario <= 1518.00) {
      valorDesconto = salario * 0.075; // 7.5%
    } else if (salario <= 2666.68) {
      valorDesconto = salario * 0.09; // 9%
    } else if (salario <= 4000.03) {
      valorDesconto = salario * 0.12; // 12%
    } else {
      valorDesconto = salario * 0.14; // 14%
    }
    
    return Desconto(motivo: 'INSS', valor: valorDesconto);
  }

  // Criar desconto de IRRF baseado no salário
  static Desconto calcularIRRF(double salario) {
    double valorDesconto = 0.0;
    
    // Tabela simplificada do IRRF 2025
    if (salario <= 2259.20) {
      valorDesconto = 0.0; // Isento
    } else if (salario <= 2826.65) {
      valorDesconto = (salario * 0.075) - 169.44;
    } else if (salario <= 3751.05) {
      valorDesconto = (salario * 0.15) - 381.44;
    } else if (salario <= 4664.68) {
      valorDesconto = (salario * 0.225) - 662.77;
    } else {
      valorDesconto = (salario * 0.275) - 896.00;
    }
    
    return Desconto(motivo: 'IRRF', valor: valorDesconto > 0 ? valorDesconto : 0.0);
  }

  // Criar desconto de FGTS baseado no salário
  static Desconto calcularFGTS(double salario) {
    // FGTS é 8% do salário bruto
    double valorDesconto = salario * 0.08;
    return Desconto(motivo: 'FGTS', valor: valorDesconto);
  }

  // Calcular desconto de faltas não justificadas
  // Considera que o mês tem em média 22 dias úteis
  static Desconto calcularDescontoFaltas({
    required double salario,
    required int numeroFaltas,
    int diasUteisMes = 30,
  }) {
    if (numeroFaltas <= 0) {
      return Desconto(motivo: 'Falta não Justificada', valor: 0.0);
    }
    
    // Calcula o valor do dia de trabalho
    double valorDia = salario / diasUteisMes;
    
    // Multiplica pelo número de faltas
    double valorDesconto = valorDia * numeroFaltas;
    
    return Desconto(
      motivo: 'Falta não Justificada (${numeroFaltas} dia${numeroFaltas > 1 ? 's' : ''})',
      valor: valorDesconto,
    );
  }
}
