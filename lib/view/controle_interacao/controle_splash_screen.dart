import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/util/navegacao.dart';
import 'package:organizese/view/tela_login.dart';
import 'package:organizese/view/tela_inicial01.dart';
import 'package:organizese/controller/cargo_controller.dart';
import 'package:organizese/controller/beneficio_controller.dart';
import 'package:organizese/controller/desconto_controller.dart';
import 'package:organizese/view/tela_inicial_funcionario.dart';


class Controlesplashscreen {

  Future<void> inicializarAplicacao(BuildContext context) async {
    try {
      // Inicializar cargos, benefícios e descontos padrões
      await CargoController.inicializarCargosNoBanco();
      await BeneficioController.inicializarBeneficiosPadroes();
      await DescontoController.inicializarDescontosPadroes();
    } catch (e) {
      print('Erro ao inicializar dados padrões: $e');
    }

    await Future.delayed(Duration(seconds: 2));

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!context.mounted) return;
      
      if (user == null) {
        push(context, Telalogin(), replace: true);

      } else {
        FirebaseFirestore.instance
            .collection('Funcionario')
            .where("email", isEqualTo: "${user.email}")
            .snapshots()
            .listen((data) {
          
            if (!context.mounted) return;
            
            if (data.docs.isEmpty) {
              push(context, Telalogin(), replace: true);
              return;
            }

            Funcionario usuario = Funcionario.fromMap(data.docs[0].data());
            usuario.id = data.docs[0].id;

            if (usuario.admin == true) {
              push(context, TelaInicial01(usuario), replace: true);
            } else {
              push(context, TelaInicialFuncionario(usuario), replace: true);
            }
        });
      }
    });
  }
}
