import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/domain/Beneficio.dart';
import 'package:organizese/domain/Falta.dart';
import 'package:organizese/controller/ContrachequeController.dart';
import 'package:organizese/controller/Controller_funcionario.dart';
import 'package:organizese/controller/BeneficioController.dart';
import 'package:organizese/controller/FuncionarioBeneficioController.dart';
import 'package:organizese/controller/FaltaController.dart';

class ControladorCadastroContracheque {
  final formKey = GlobalKey<FormState>();
  final TextEditingController acrescimosController = TextEditingController(text: '0.00');
  final ControladorTelaInicial controladorFuncionario = ControladorTelaInicial();

  // Variáveis de estado
  List<Funcionario> funcionariosDisponiveis = [];
  Funcionario? funcionarioSelecionado;
  List<Beneficio> beneficiosDoFuncionario = [];
  List<Falta> faltasDoFuncionario = [];

  // Estado de carregamento
  bool isLoadingFuncionarios = true;
  bool isLoadingBeneficios = false;
  bool isLoadingFaltas = false;
  bool isSaving = false;

  // Mês e Ano
  int mesSelecionado = DateTime.now().month;
  int anoSelecionado = DateTime.now().year;

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
    acrescimosController.dispose();
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

  /// Carregar benefícios de um funcionário específico
  Future<void> carregarBeneficiosFuncionario(String funcionarioId) async {
    isLoadingBeneficios = true;
    try {
      // Buscar IDs dos benefícios do funcionário
      final beneficiosIds = await FuncionarioBeneficioController
          .buscarBeneficiosPorFuncionario(funcionarioId);

      // Buscar detalhes de cada benefício
      List<Beneficio> beneficios = [];
      for (String beneficioId in beneficiosIds) {
        final beneficio = await BeneficioController.buscarBeneficioPorId(beneficioId);
        if (beneficio != null) {
          beneficios.add(beneficio);
        }
      }

      beneficiosDoFuncionario = beneficios;
      isLoadingBeneficios = false;
    } catch (e) {
      isLoadingBeneficios = false;
      throw Exception('Erro ao carregar benefícios: $e');
    }
  }

  /// Carregar faltas de um funcionário no período selecionado
  Future<void> carregarFaltasFuncionario(String funcionarioId) async {
    isLoadingFaltas = true;
    try {
      // Buscar faltas do funcionário no mês/ano selecionado
      final faltas = await FaltaController.buscarFaltasPorMesAno(
        funcionarioId: funcionarioId,
        mes: mesSelecionado,
        ano: anoSelecionado,
      );

      faltasDoFuncionario = faltas;
      isLoadingFaltas = false;
    } catch (e) {
      isLoadingFaltas = false;
      throw Exception('Erro ao carregar faltas: $e');
    }
  }

  /// Calcular valor do desconto de faltas
  double calcularDescontoFaltas() {
    if (funcionarioSelecionado == null || faltasDoFuncionario.isEmpty) {
      return 0.0;
    }
    
    // Filtrar apenas faltas NÃO justificadas
    final faltasNaoJustificadas = faltasDoFuncionario.where((falta) => !falta.faltaJustificada).toList();
    
    if (faltasNaoJustificadas.isEmpty) {
      return 0.0;
    }
    
    final salario = funcionarioSelecionado!.salario ?? 0.0;
    final diasUteis = 22; // Média de dias úteis no mês
    final valorDia = salario / diasUteis;
    
    return valorDia * faltasNaoJustificadas.length;
  }

  /// Obter número de faltas não justificadas
  int obterNumeroFaltasNaoJustificadas() {
    return faltasDoFuncionario.where((falta) => !falta.faltaJustificada).length;
  }

  /// Obter número de faltas justificadas
  int obterNumeroFaltasJustificadas() {
    return faltasDoFuncionario.where((falta) => falta.faltaJustificada).length;
  }

  /// Verificar se já existe contracheque para o funcionário no período
  Future<bool> verificarContrachequeExistente() async {
    if (funcionarioSelecionado == null) return false;

    final contrachequeExistente =
    await ContrachequeController.buscarContraquechequePorMesAno(
      funcionarioId: funcionarioSelecionado!.id!,
      mes: mesSelecionado,
      ano: anoSelecionado,
    );

    return contrachequeExistente != null;
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

  /// Salvar contracheque
  Future<String?> salvarContracheque() async {
    if (!validarFormulario()) {
      return null;
    }

    isSaving = true;

    try {
      final acrescimos = double.tryParse(
        acrescimosController.text.replaceAll(',', '.'),
      ) ??
          0.0;

      // Buscar IDs dos benefícios do funcionário
      final beneficiosIds = await FuncionarioBeneficioController
          .buscarBeneficiosPorFuncionario(funcionarioSelecionado!.id!);

      final contrachequeId = await ContrachequeController.criarContracheque(
        funcionario: funcionarioSelecionado!,
        mes: mesSelecionado,
        ano: anoSelecionado,
        beneficiosIds: beneficiosIds,
        descontosCustomizadosIds: [], // Vazio - descontos calculados automaticamente
        acrescimos: acrescimos,
      );

      isSaving = false;
      return contrachequeId;
    } catch (e) {
      isSaving = false;
      throw Exception('Erro ao cadastrar contracheque: $e');
    }
  }

  /// Limpar formulário após cadastro bem-sucedido
  void limparFormulario() {
    funcionarioSelecionado = null;
    beneficiosDoFuncionario = [];
    faltasDoFuncionario = [];
    acrescimosController.text = '0.00';
    mesSelecionado = DateTime.now().month;
    anoSelecionado = DateTime.now().year;
    formKey.currentState?.reset();
  }

  /// Selecionar funcionário
  void selecionarFuncionario(Funcionario funcionario) {
    funcionarioSelecionado = funcionario;
    beneficiosDoFuncionario = []; // Limpar benefícios anteriores
    faltasDoFuncionario = []; // Limpar faltas anteriores
  }

  /// Atualizar mês
  void atualizarMes(int mes) {
    mesSelecionado = mes;
  }

  /// Atualizar ano
  void atualizarAno(int ano) {
    anoSelecionado = ano;
  }

  /// Obter nome do mês formatado
  String obterNomeMes() {
    return meses[mesSelecionado - 1];
  }

  /// Validar ano
  String? validarAno(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o ano';
    }
    final ano = int.tryParse(value);
    if (ano == null || ano < 2000 || ano > 2100) {
      return 'Ano inválido';
    }
    return null;
  }

  /// Validar acréscimos
  String? validarAcrescimos(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Acréscimos são opcionais
    }
    final numero = double.tryParse(value.replaceAll(',', '.'));
    if (numero == null || numero < 0) {
      return 'Informe um valor válido';
    }
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

  /// Mostrar diálogo de confirmação quando contracheque já existe
  Future<bool> mostrarDialogoContrachequeExistente(BuildContext context) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contracheque Existente'),
        content: Text(
          'Já existe um contracheque para ${funcionarioSelecionado!.nome} '
              'em ${obterNomeMes()} de $anoSelecionado.\n\n'
              'Deseja criar um novo? O anterior será mantido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Continuar'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }
}
