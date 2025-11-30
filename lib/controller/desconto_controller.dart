import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/desconto.dart';

class DescontoController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _descontosCollection =
      _firestore.collection('Desconto');

  static final List<Map<String, dynamic>> descontosPadroes = [
    {'motivo': 'INSS', 'valor': 0.0}, // valor será calculado (%)
    {'motivo': 'IRRF', 'valor': 0.0}, // valor será calculado (%)
    {'motivo': 'FGTS', 'valor': 0.0}, // valor será calculado (%)
    {'motivo': 'Falta não Justificada', 'valor': 0.0},
    {'motivo': 'Atraso', 'valor': 0.0},
    {'motivo': 'Adiantamento Salarial', 'valor': 0.0},
  ];

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

  static Future<String?> adicionarDesconto(Desconto desconto) async {
    try {
      final docRef = await _descontosCollection.add(desconto.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar desconto: $e');
      return null;
    }
  }

  static Future<bool> atualizarDesconto(String id, Desconto desconto) async {
    try {
      await _descontosCollection.doc(id).update(desconto.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar desconto: $e');
      return false;
    }
  }

  static Future<bool> removerDesconto(String id) async {
    try {
      await _descontosCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao remover desconto: $e');
      return false;
    }
  }

  static Stream<List<Desconto>> streamDescontos() {
    return _descontosCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Desconto.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  static Desconto calcularINSS(double salario) {
    double valorDesconto = 0.0;

    if (salario <= 1518.00) {
      valorDesconto = salario * 0.075; // 7.5%
    } else if (salario <= 2793.88) {
      valorDesconto = (1518.00 * 0.075) + ((salario - 1518.00) * 0.09); // 7.5% + 9%
    } else if (salario <= 4190.83) {
      valorDesconto = (1518.00 * 0.075) + ((2793.88 - 1518.00) * 0.09) + ((salario - 2793.88) * 0.12); // 7.5% + 9% + 12%
    } else if (salario <= 8157.41) {
      valorDesconto = (1518.00 * 0.075) + ((2793.88 - 1518.00) * 0.09) + ((4190.83 - 2793.88) * 0.12) + ((salario - 4190.83) * 0.14); // 7.5% + 9% + 12% + 14%
    } else {
      // Teto máximo do INSS em 2025
      valorDesconto = (1518.00 * 0.075) + ((2793.88 - 1518.00) * 0.09) + ((4190.83 - 2793.88) * 0.12) + ((8157.41 - 4190.83) * 0.14);
    }
    
    return Desconto(motivo: 'INSS', valor: valorDesconto);
  }

  static Desconto calcularIRRF(double salario, double descontoINSS) {
    double baseCalculo = salario - descontoINSS;
    double valorDesconto = 0.0;
    
    if (baseCalculo <= 2259.20) {
      valorDesconto = 0.0;
    } else if (baseCalculo <= 2826.65) {
      valorDesconto = (baseCalculo * 0.075) - 169.44;
    } else if (baseCalculo <= 3751.05) {
      valorDesconto = (baseCalculo * 0.15) - 381.44;
    } else if (baseCalculo <= 4664.68) {
      valorDesconto = (baseCalculo * 0.225) - 662.77;
    } else {
      valorDesconto = (baseCalculo * 0.275) - 896.00;
    }
    
    return Desconto(motivo: 'IRRF', valor: valorDesconto > 0 ? valorDesconto : 0.0);
  }

  static Desconto calcularFGTS(double salario) {
    double valorDesconto = salario * 0.08;
    return Desconto(motivo: 'FGTS', valor: valorDesconto);
  }

  static Desconto calcularDescontoFaltas({
    required double salario,
    required int numeroFaltas,
    int diasUteisMes = 30,
  }) {
    if (numeroFaltas <= 0) {
      return Desconto(motivo: 'Falta não Justificada', valor: 0.0);
    }

    double valorDia = salario / diasUteisMes;

    double valorDesconto = valorDia * numeroFaltas;

    return Desconto(
      motivo: 'Falta não Justificada (${numeroFaltas} dia${numeroFaltas > 1 ? 's' : ''})',
      valor: valorDesconto,
    );
  }
}
