import 'package:flutter/material.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/domain/falta.dart';
import 'package:organizese/controller/falta_controller.dart';

class ControladorFaltasFuncionario {
  final Funcionario funcionario;

  List<Falta> faltas = [];
  bool isLoading = true;
  String? erro;

  ControladorFaltasFuncionario(this.funcionario);

  Future<void> carregarFaltas() async {
    if (funcionario.id == null) {
      erro = 'Funcionário sem ID válido';
      isLoading = false;
      return;
    }

    isLoading = true;
    erro = null;

    try {
      faltas = await FaltaController.buscarFaltasPorFuncionario(funcionario.id!);
      isLoading = false;
    } catch (e) {
      erro = 'Erro ao carregar faltas: $e';
      isLoading = false;
      throw Exception(erro);
    }
  }

  bool deveExibirMesAno(int index) {
    if (faltas.isEmpty || index >= faltas.length) return false;
    if (index == 0) return true;

    final faltaAtual = faltas[index];
    final faltaAnterior = faltas[index - 1];

    return faltaAnterior.data.month != faltaAtual.data.month ||
        faltaAnterior.data.year != faltaAtual.data.year;
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
