import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/util/navegacao.dart';
import 'package:organizese/view/tela_inicial.dart';
import 'package:organizese/view/tela_inicial_funcionario.dart';
import 'package:email_validator/email_validator.dart';


class ControleLogin {
  final controlador_login = TextEditingController();
  final controlador_senha = TextEditingController();

  final formkey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;


  CollectionReference<Map<String, dynamic>> get _collection_funcionario =>
      FirebaseFirestore.instance.collection('Funcionario');

  void _mostrarSnack(BuildContext context, String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void logar(BuildContext context) async {
    if (formkey.currentState!.validate()) {
      String login = controlador_login.text.trim();
      String senha = controlador_senha.text.trim();

      if (EmailValidator.validate(login)) {
        try {
          UserCredential userCredential = await _auth
              .signInWithEmailAndPassword(email: login, password: senha);
          _irParaTelaPrincipal(userCredential.user, context);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'invalid-credential') {
            _mostrarSnack(
                context, "Dados inválidos, caso não tenha login faça o cadastro!", erro: true);
          } else if (e.code == 'wrong-password') {
            _mostrarSnack(context, "Senha inválida!", erro: true);
          } else if (e.code == 'user-not-found') {
            _mostrarSnack(context, "Usuário não encontrado!", erro: true);
          } else if (e.code == 'too-many-requests') {
            _mostrarSnack(context, "Muitas tentativas. Tente novamente mais tarde.", erro: true);
          } else {
            _mostrarSnack(context, "Erro ao fazer login: ${e.message ?? e.code}", erro: true);
          }
          print('FirebaseAuthException: ${e.code}');
        } catch (e) {
          _mostrarSnack(context, "Erro inesperado ao fazer login: $e", erro: true);
          print('Erro inesperado: $e');
        }
      } else {
        _mostrarSnack(context, "Email informado com formato inválido", erro: true);
      }
    }
  }

  void _irParaTelaPrincipal(User? user, BuildContext context) {
    _collection_funcionario
        .where("email", isEqualTo: "${user!.email}")
        .snapshots()
        .listen((data) {
      
      if (data.docs.isEmpty) {
        _mostrarSnack(context, "Funcionário não encontrado no sistema", erro: true);
        return;
      }
      
      Funcionario funcionario = Funcionario.fromMap(data.docs[0].data());
      funcionario.id = data.docs[0].id;
      
      if (funcionario.admin == true) {
        push(context, TelaInicial01(funcionario), replace: true);
      } else {
        push(context, TelaInicialFuncionario(funcionario), replace: true);
      }
    });
  }
}