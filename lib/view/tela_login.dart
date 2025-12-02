import 'package:flutter/material.dart';
import 'package:organizese/util/navegacao.dart';
import 'package:organizese/util/widgets/campo_botao.dart';
import 'package:organizese/util/widgets/campo_input.dart';
import 'package:organizese/view/controle_interacao/controlador_login.dart';
import 'package:organizese/view/tela_cadastrar.dart';


class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  late ControleLogin _controle;

  @override
  void initState() {
    super.initState();
    _controle = ControleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Form(
      key: _controle.formkey,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", fit: BoxFit.contain),
            CampoInput(
              "Login",
              texto_placehoader: "Digite seu Usuario",
              controlador: _controle.controlador_login,
            ),
            const SizedBox(height: 18),
            CampoInput(
              "Senha",
              passaword: true,
              controlador: _controle.controlador_senha,
            ),
            const SizedBox(height: 18),
            Botao(
              texto: "Logar",
              cor: Colors.black,
              aoClicar: () {
                _controle.logar(context);
              },
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("Ainda não está cadastrado? "),
                Text(
                  style: TextStyle(fontWeight: FontWeight.bold),
                    "Contate o seu administrador")
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
