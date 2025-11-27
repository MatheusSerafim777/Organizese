import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/view/controle_interacao/ControladorCadastroFalta.dart';
import 'package:organizese/util/widgets/card_secao_titulo.dart';
import 'package:organizese/util/widgets/dropdown_seletor_funcionario.dart';
import 'package:organizese/util/widgets/seletor_data.dart';
import 'package:organizese/util/widgets/opcao_tipo_falta.dart';
import 'package:organizese/util/widgets/botao_acao_principal.dart';

class TelaCadastroFalta extends StatefulWidget {
  final Funcionario? funcionarioSelecionado;

  const TelaCadastroFalta({
    Key? key,
    this.funcionarioSelecionado,
  }) : super(key: key);

  @override
  _TelaCadastroFaltaState createState() => _TelaCadastroFaltaState();
}

class _TelaCadastroFaltaState extends State<TelaCadastroFalta> {
  late ControladorCadastroFalta _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorCadastroFalta();
    _controlador.inicializar(widget.funcionarioSelecionado);
    _carregarDados();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {});
    try {
      await _controlador.carregarFuncionarios();
    } catch (e) {
      _controlador.mostrarErro(context, e.toString());
    }
    setState(() {});
  }

  Future<void> _salvarFalta() async {
    setState(() {});
    try {
      final faltaId = await _controlador.salvarFalta();

      if (faltaId != null) {
        if (mounted) {
          _controlador.mostrarSucesso(context, 'Falta cadastrada com sucesso!');
          setState(() {
            _controlador.limparFormulario();
          });
        }
      } else {
        _controlador.mostrarErro(context, 'Erro ao cadastrar falta');
      }
    } catch (e) {
      _controlador.mostrarErro(context, e.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controlador.isLoadingFuncionarios
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _controlador.formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildCardInformacoesBasicas(),
            SizedBox(height: 20),
            _buildCardTipoFalta(),
            SizedBox(height: 20),
            _buildCardMotivo(),
            SizedBox(height: 30),
            _buildBotaoSalvar(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInformacoesBasicas() {
    return CardSecaoTitulo(
      titulo: 'Informações Básicas',
      children: [
        DropdownSeletorFuncionario(
          funcionarios: _controlador.funcionariosDisponiveis,
          funcionarioSelecionadoId: _controlador.funcionarioSelecionado?.id,
          onChanged: (String? funcionarioId) {
            if (funcionarioId != null) {
              final funcionario = _controlador.funcionariosDisponiveis.firstWhere(
                (f) => f.id == funcionarioId,
              );
              setState(() {
                _controlador.selecionarFuncionario(funcionario);
              });
            }
          },
        ),
        SizedBox(height: 16),
        SeletorData(
          label: 'Data da Falta *',
          dataFormatada: _controlador.obterDataFormatada(),
          onTap: () async {
            await _controlador.selecionarData(context);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildCardTipoFalta() {
    return CardSecaoTitulo(
      titulo: 'Tipo de Falta',
      subtitulo: 'Defina se a falta possui justificativa',
      children: [
        OpcaoTipoFalta(
          titulo: 'Falta NÃO Justificada',
          descricao: 'Será aplicado desconto no contracheque',
          selecionada: !_controlador.faltaJustificada,
          onTap: () {
            setState(() {
              _controlador.alternarTipoFalta(false);
            });
          },
          icone: Icons.money_off,
          faltaJustificada: false,
        ),
        SizedBox(height: 12),
        OpcaoTipoFalta(
          titulo: 'Falta Justificada',
          descricao: 'Sem desconto no contracheque',
          selecionada: _controlador.faltaJustificada,
          onTap: () {
            setState(() {
              _controlador.alternarTipoFalta(true);
            });
          },
          icone: Icons.check_circle,
          faltaJustificada: true,
        ),
      ],
    );
  }

  Widget _buildCardMotivo() {
    return CardSecaoTitulo(
      titulo: 'Motivo da Falta',
      children: [
        TextFormField(
          controller: _controlador.motivoController,
          decoration: InputDecoration(
            labelText: 'Motivo',
            border: OutlineInputBorder(),
            hintText: 'Ex: Atestado médico, Consulta, etc.',
            helperText: 'Se não informar, será salvo como "Falta sem motivo informado"',
            helperStyle: TextStyle(fontSize: 11),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          validator: _controlador.validarMotivo,
        ),
      ],
    );
  }

  Widget _buildBotaoSalvar() {
    return BotaoAcaoPrincipal(
      texto: 'Cadastrar Falta',
      onPressed: _salvarFalta,
      isLoading: _controlador.isSaving,
      corFundo: Colors.green,
    );
  }
}
