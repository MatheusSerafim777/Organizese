import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/util/toast.dart';
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
            MensagemErro(
                context, "Dados invalidos, caso nao tenha login faca o cadastro !");
          } else if (e.code == 'wrong-password') {
            MensagemAlerta(
              context,
              "Erro: Password inválido!!!",
            );
            print('Wrong password provided for that user.');
          }
          print(e.code);
        }
      } else {
        MensagemAlerta(context, "Erro: Email informado com formato inválido");
      }
    }
  }

  void _irParaTelaPrincipal(User? user, BuildContext context) {
    _collection_funcionario
        .where("email", isEqualTo: "${user!.email}")
        .snapshots()
        .listen((data) {
      
      if (data.docs.isEmpty) {
        MensagemAlerta(context, "Erro: Funcionário não encontrado no sistema");
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