import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/domain/Contracheque.dart';
import 'package:organizese/controller/ContrachequeController.dart';

class ControladorContrachequesFuncionario {
  final Funcionario funcionario;

  List<Contracheque> contracheques = [];
  bool isLoading = true;
  String? erro;

  ControladorContrachequesFuncionario(this.funcionario);

  Future<void> carregarContracheques() async {
    if (funcionario.id == null) {
      erro = 'Funcionário sem ID válido';
      isLoading = false;
      return;
    }

    isLoading = true;
    erro = null;

    try {
      contracheques = await ContrachequeController.buscarContrachequesPorFuncionario(
        funcionario.id!,
      );
      isLoading = false;
    } catch (e) {
      erro = 'Erro ao carregar contracheques: $e';
      isLoading = false;
      throw Exception(erro);
    }
  }

  bool deveExibirAno(int index) {
    if (contracheques.isEmpty || index >= contracheques.length) return false;
    if (index == 0) return true;

    final contrachequeAtual = contracheques[index];
    final contrachequeAnterior = contracheques[index - 1];

    return contrachequeAnterior.ano != contrachequeAtual.ano;
  }

  void mostrarErro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
