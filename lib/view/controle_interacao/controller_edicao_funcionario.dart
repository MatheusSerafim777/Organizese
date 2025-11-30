import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizese/domain/cargo.dart';
import 'package:organizese/controller/cargo_controller.dart';

class ControladorEdicaoFuncionario {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> carregarCargosESelecionar(String? cargoIdFuncionario) async {
    try {
      final cargos = await CargoController.obterTodosCargos();
      
      Cargo? cargoSelecionado;
      
      if (cargoIdFuncionario != null && cargos.isNotEmpty) {
        try {
          cargoSelecionado = cargos.firstWhere(
            (cargo) => cargo.id == cargoIdFuncionario,
          );
        } catch (e) {
          cargoSelecionado = cargos.first;
        }
      }
      
      return {
        'cargos': cargos,
        'cargoSelecionado': cargoSelecionado,
      };
    } catch (e) {
      throw Exception('Erro ao carregar cargos: $e');
    }
  }

  Future<void> atualizarFuncionario({
    required String funcionarioId,
    required String nome,
    required String email,
    required String cpf,
    required int idade,
    required String? cargoId,
  }) async {
    try {
      // Remove formatação do CPF antes de salvar
      final cpfLimpo = cpf.replaceAll(RegExp(r'[.-]'), '');

      final dadosAtualizados = {
        'nome': nome.trim(),
        'idade': idade,
        'cpf': cpfLimpo,
        'email': email.trim(),
        'cargoId': cargoId,
      };

      await _db
          .collection('Funcionario')
          .doc(funcionarioId)
          .update(dadosAtualizados);
    } catch (e) {
      throw Exception('Erro ao atualizar funcionário: $e');
    }
  }

  Future<void> demitirFuncionario(String funcionarioId) async {
    try {
      await _db.collection('Funcionario').doc(funcionarioId).update({
        'dataDemissao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao demitir funcionário: $e');
    }
  }

  String? validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    return null;
  }

  String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!valor.contains('@')) {
      return 'Email inválido';
    }
    return null;
  }

  String? validarCPF(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'CPF é obrigatório';
    }
    final cpfNumeros = valor.replaceAll(RegExp(r'[^\d]'), '');
    if (cpfNumeros.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    return null;
  }

  String? validarIdade(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Idade é obrigatória';
    }
    final idade = int.tryParse(valor);
    if (idade == null || idade < 16 || idade > 120) {
      return 'Idade deve estar entre 16 e 120 anos';
    }
    return null;
  }

  String? validarCargo(Cargo? cargo) {
    if (cargo == null) {
      return 'Selecione um cargo';
    }
    return null;
  }

  String formatarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length > 11) cpf = cpf.substring(0, 11);

    if (cpf.length > 9) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
    } else if (cpf.length > 6) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    } else if (cpf.length > 3) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    }
    return cpf;
  }

  String formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}
