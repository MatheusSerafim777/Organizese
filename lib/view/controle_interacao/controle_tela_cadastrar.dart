import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizese/controller/beneficio_controller.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/domain/cargo.dart';
import 'package:organizese/controller/cargo_controller.dart';
import 'package:organizese/controller/funcionario_beneficio_controller.dart';

class ControladorTelaCadastro {
  final formKey = GlobalKey<FormState>();

  final TextEditingController controladorNome = TextEditingController();
  final TextEditingController controladorEmail = TextEditingController();
  final TextEditingController controladorSenha = TextEditingController();
  final TextEditingController controladorConfirmarSenha = TextEditingController();
  final TextEditingController controladorIdade = TextEditingController();
  final TextEditingController controladorCpf = TextEditingController();

  // Cargo selecionado
  Cargo? cargoSelecionado;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtém lista de cargos disponíveis do Firestore
  Future<List<Cargo>> get cargosDisponiveis => CargoController.obterTodosCargos();

  // Método para selecionar cargo
  void selecionarCargo(Cargo? cargo) {
    cargoSelecionado = cargo;
  }

  void _mostrarSnack(BuildContext context, String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: erro ? Colors.red : Colors.green),
    );
  }

  Future<void> _salvarFuncionario({
    required String uid,
    required String nome,
    required String email,
    int? idade,
    String? cpf,
    String? cargoId,
    double? salario,
  }) async {
    final func = Funcionario(
      id: uid,
      nome: nome,
      email: email,
      idade: idade,
      cpf: (cpf == null || cpf.isEmpty)
          ? null
          : cpf.replaceAll(RegExp(r'[^0-9]'), ''), // guarda apenas dígitos
      admin: false,
      salario: salario ?? 0.0,
      cargoId: cargoId,
      dataAdmissao: DateTime.now(),
      dataDemissao: null,
    );

    final data = func.toMap();
    data['dataAdmissao'] = FieldValue.serverTimestamp();

    await _db.collection('Funcionario').doc(uid).set(
      data,
      SetOptions(merge: true),
    );
  }

  Future<void> _adicionarBeneficiosPadroes(String funcionarioId) async {
    try {
      final beneficios = await BeneficioController.buscarTodosBeneficios();
      
      if (beneficios.isEmpty) {
        print('Nenhum benefício encontrado no sistema');
        return;
      }

      final beneficiosIds = beneficios
          .where((b) => b.id != null)
          .map((b) => b.id!)
          .toList();

      final sucesso = await FuncionarioBeneficioController.adicionarBeneficiosAoFuncionario(
        funcionarioId: funcionarioId,
        beneficiosIds: beneficiosIds,
      );

      if (sucesso) {
        print(' benefícios padrões adicionados ao funcionário $funcionarioId');
      } else {
        print('Erro ao adicionar benefícios ao funcionário');
      }
    } catch (e) {
      print('Erro ao adicionar benefícios padrões: $e');
    }
  }

  Future<void> cadastrar(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (cargoSelecionado == null) {
      _mostrarSnack(context, "Selecione um cargo", erro: true);
      return;
    }

    final email = controladorEmail.text.trim();
    final senha = controladorSenha.text.trim();
    final nomeInformado = controladorNome.text.trim();
    final idadeInformada = controladorIdade.text.trim();
    final cpfInformado = controladorCpf.text.trim();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: senha);

      if (nomeInformado.isNotEmpty && _auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(nomeInformado);
      }

      final uid = cred.user!.uid;
      await _salvarFuncionario(
        uid: uid,
        nome: nomeInformado.isNotEmpty ? nomeInformado : (cred.user!.displayName ?? ''),
        email: email,
        idade: idadeInformada.isEmpty ? null : int.tryParse(idadeInformada),
        cpf: cpfInformado,
        cargoId: cargoSelecionado!.id,
        salario: cargoSelecionado!.salario,
      );

      await _adicionarBeneficiosPadroes(uid);

      await _auth.signOut();

      _mostrarSnack(context, "Cadastro realizado com sucesso! Faça login para acessar.");
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String msg = "Erro ao cadastrar";
      if (e.code == 'email-already-in-use') msg = "Email já está em uso";
      else if (e.code == 'invalid-email') msg = "Email inválido";
      else if (e.code == 'weak-password') msg = "Senha fraca";
      else if (e.message != null) msg = e.message!;
      _mostrarSnack(context, msg, erro: true);
    } catch (e) {
      _mostrarSnack(context, "Erro inesperado: $e", erro: true);
    }
  }


  void dispose() {
    controladorNome.dispose();
    controladorEmail.dispose();
    controladorSenha.dispose();
    controladorConfirmarSenha.dispose();
    controladorIdade.dispose();
    controladorCpf.dispose();
  }
}
