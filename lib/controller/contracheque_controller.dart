import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/contracheque.dart';
import '../domain/funcionario.dart';
import 'desconto_controller.dart';
import 'falta_controller.dart';

class ContrachequeController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _contrachequeCollection =
      _firestore.collection('Contracheque');

  // Criar contracheque para um funcionário
  static Future<String?> criarContracheque({
    required Funcionario funcionario,
    required int mes,
    required int ano,
    List<String> beneficiosIds = const [],
    List<String> descontosCustomizadosIds = const [],
    double acrescimos = 0.0,
  }) async {
    try {
      double salarioBruto = funcionario.salario ?? 0.0;
      
      // Calcular descontos obrigatórios
      List<String> todosDescontosIds = List.from(descontosCustomizadosIds);
      
      // 1. Calcular INSS primeiro
      final descontoINSS = DescontoController.calcularINSS(salarioBruto);
      final inssId = await DescontoController.adicionarDesconto(descontoINSS);
      if (inssId != null) todosDescontosIds.add(inssId);
      
      // 2. Calcular IRRF (usando salário - INSS como base)
      final descontoIRRF = DescontoController.calcularIRRF(salarioBruto, descontoINSS.valor);
      final irrfId = await DescontoController.adicionarDesconto(descontoIRRF);
      if (irrfId != null) todosDescontosIds.add(irrfId);
      
      // NOTA: FGTS não é descontado do funcionário, é pago pelo empregador
      // Por isso foi removido do cálculo do salário líquido
      
      // Buscar faltas do funcionário no mês/ano do contracheque
      final faltas = await FaltaController.buscarFaltasPorMesAno(
        funcionarioId: funcionario.id!,
        mes: mes,
        ano: ano,
      );
      
      // Filtrar apenas faltas NÃO justificadas
      final faltasNaoJustificadas = faltas.where((falta) => !falta.faltaJustificada).toList();
      
      // Calcular desconto de faltas não justificadas se houver
      double descontoFaltasValor = 0.0;
      if (faltasNaoJustificadas.isNotEmpty) {
        final descontoFaltas = DescontoController.calcularDescontoFaltas(
          salario: salarioBruto,
          numeroFaltas: faltasNaoJustificadas.length,
        );
        final faltasId = await DescontoController.adicionarDesconto(descontoFaltas);
        if (faltasId != null) {
          todosDescontosIds.add(faltasId);
          descontoFaltasValor = descontoFaltas.valor;
        }
      }
      
      // Buscar valores dos descontos customizados
      double totalDescontos = descontoINSS.valor + descontoIRRF.valor + descontoFaltasValor;
      for (var descontoId in descontosCustomizadosIds) {
        final desconto = await DescontoController.buscarDescontoPorId(descontoId);
        if (desconto != null) {
          totalDescontos += desconto.valor;
        }
      }
      
      // Calcular salário líquido
      double salarioLiquido = salarioBruto + acrescimos - totalDescontos;
      
      // Criar contracheque
      final contracheque = Contracheque(
        funcionarioId: funcionario.id,
        valorSalarioBruto: salarioBruto,
        valorSalarioLiquido: salarioLiquido,
        mes: mes,
        ano: ano,
        acrescimos: acrescimos,
        beneficiosIds: beneficiosIds,
        descontosIds: todosDescontosIds,
      );
      
      final docRef = await _contrachequeCollection.add(contracheque.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar contracheque: $e');
      return null;
    }
  }

  // Buscar contracheques de um funcionário
  static Future<List<Contracheque>> buscarContrachequesPorFuncionario(String funcionarioId) async {
    try {
      final snapshot = await _contrachequeCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .get();
      
      // Ordenar localmente para evitar necessidade de índice composto
      final contracheques = snapshot.docs
          .map((doc) => Contracheque.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      // Ordenar por ano e mês decrescente
      contracheques.sort((a, b) {
        if (a.ano != b.ano) {
          return b.ano.compareTo(a.ano); // Ano mais recente primeiro
        }
        return b.mes.compareTo(a.mes); // Mês mais recente primeiro
      });
      
      return contracheques;
    } catch (e) {
      print('Erro ao buscar contracheques: $e');
      return [];
    }
  }

  // Buscar contracheque por ID
  static Future<Contracheque?> buscarContraquechequePorId(String id) async {
    try {
      final doc = await _contrachequeCollection.doc(id).get();
      if (doc.exists) {
        return Contracheque.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar contracheque: $e');
      return null;
    }
  }

  // Buscar contracheque de um funcionário em um mês/ano específico
  static Future<Contracheque?> buscarContraquechequePorMesAno({
    required String funcionarioId,
    required int mes,
    required int ano,
  }) async {
    try {
      final snapshot = await _contrachequeCollection
          .where('funcionarioId', isEqualTo: funcionarioId)
          .where('mes', isEqualTo: mes)
          .where('ano', isEqualTo: ano)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Contracheque.fromMap(
          snapshot.docs.first.id,
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      print('Erro ao buscar contracheque: $e');
      return null;
    }
  }

  // Atualizar contracheque
  static Future<bool> atualizarContracheque(String id, Contracheque contracheque) async {
    try {
      await _contrachequeCollection.doc(id).update(contracheque.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar contracheque: $e');
      return false;
    }
  }

  // Remover contracheque
  static Future<bool> removerContracheque(String id) async {
    try {
      await _contrachequeCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Erro ao remover contracheque: $e');
      return false;
    }
  }

  // Stream de contracheques de um funcionário
  static Stream<List<Contracheque>> streamContrachequesPorFuncionario(String funcionarioId) {
    return _contrachequeCollection
        .where('funcionarioId', isEqualTo: funcionarioId)
        .orderBy('ano', descending: true)
        .orderBy('mes', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Contracheque.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Buscar todos os contracheques de um determinado mês/ano
  static Future<List<Contracheque>> buscarContrachequesPorMesAno({
    required int mes,
    required int ano,
  }) async {
    try {
      final snapshot = await _contrachequeCollection
          .where('mes', isEqualTo: mes)
          .where('ano', isEqualTo: ano)
          .get();
      
      return snapshot.docs
          .map((doc) => Contracheque.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar contracheques: $e');
      return [];
    }
  }
}
