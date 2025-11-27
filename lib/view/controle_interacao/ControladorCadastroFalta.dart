import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/domain/Falta.dart';
import 'package:organizese/controller/FaltaController.dart';
import 'package:organizese/controller/Controller_funcionario.dart';

class ControladorCadastroFalta {
  final formKey = GlobalKey<FormState>();
  final TextEditingController motivoController = TextEditingController();
  final ControladorTelaInicial controladorFuncionario = ControladorTelaInicial();

  // Variáveis de estado
  List<Funcionario> funcionariosDisponiveis = [];
  Funcionario? funcionarioSelecionado;
  DateTime dataSelecionada = DateTime.now();
  bool faltaJustificada = false;

  // Estado de carregamento
  bool isLoadingFuncionarios = true;
  bool isSaving = false;

  // Lista de meses
  final List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  // Inicializar com funcionário pré-selecionado
  void inicializar(Funcionario? funcionario) {
    funcionarioSelecionado = funcionario;
  }

  // Dispose dos controllers
  void dispose() {
    motivoController.dispose();
  }

  /// Carregar lista de funcionários disponíveis
  Future<void> carregarFuncionarios() async {
    isLoadingFuncionarios = true;
    try {
      funcionariosDisponiveis = await controladorFuncionario
          .obterFuncionariosSimples()
          .first;
      isLoadingFuncionarios = false;
    } catch (e) {
      isLoadingFuncionarios = false;
      throw Exception('Erro ao carregar funcionários: $e');
    }
  }

  /// Validar formulário
  bool validarFormulario() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (funcionarioSelecionado == null) {
      throw Exception('Selecione um funcionário');
    }

    return true;
  }

  /// Salvar falta
  Future<String?> salvarFalta() async {
    if (!validarFormulario()) {
      return null;
    }

    isSaving = true;

    try {
      final motivo = motivoController.text.trim().isEmpty
          ? 'Falta sem motivo informado'
          : motivoController.text.trim();

      final falta = Falta(
        motivo: motivo,
        data: dataSelecionada,
        funcionarioId: funcionarioSelecionado!.id,
        faltaJustificada: faltaJustificada,
      );

      final faltaId = await FaltaController.adicionarFalta(falta);

      isSaving = false;
      return faltaId;
    } catch (e) {
      isSaving = false;
      throw Exception('Erro ao cadastrar falta: $e');
    }
  }

  /// Limpar formulário após cadastro bem-sucedido
  void limparFormulario() {
    funcionarioSelecionado = null;
    motivoController.clear();
    dataSelecionada = DateTime.now();
    faltaJustificada = false;
    formKey.currentState?.reset();
  }

  /// Selecionar funcionário
  void selecionarFuncionario(Funcionario funcionario) {
    funcionarioSelecionado = funcionario;
  }

  /// Atualizar data selecionada
  void atualizarData(DateTime data) {
    dataSelecionada = data;
  }

  /// Alternar tipo de falta (justificada ou não)
  void alternarTipoFalta(bool justificada) {
    faltaJustificada = justificada;
  }

  /// Obter data formatada
  String obterDataFormatada() {
    return '${dataSelecionada.day.toString().padLeft(2, '0')}/${dataSelecionada.month.toString().padLeft(2, '0')}/${dataSelecionada.year}';
  }

  /// Obter nome do mês
  String obterNomeMes(int mes) {
    return meses[mes - 1];
  }

  /// Validar motivo (opcional)
  String? validarMotivo(String? value) {
    // Motivo é opcional, então não retorna erro
    return null;
  }

  /// Mostrar mensagem de sucesso
  void mostrarSucesso(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar mensagem de erro
  void mostrarErro(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar seletor de data
  Future<void> selecionarData(BuildContext context) async {
    final DateTime? dataPicked = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (dataPicked != null) {
      dataSelecionada = dataPicked;
    }
  }
}
