import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/util/formatadores.dart';
import 'package:organizese/view/controle_interacao/controlador_cadastro_contracheque.dart';

class TelaCadastroContracheque extends StatefulWidget {
  final Funcionario? funcionarioSelecionado;

  const TelaCadastroContracheque({
    Key? key,
    this.funcionarioSelecionado,
  }) : super(key: key);

  @override
  _TelaCadastroContrachequeState createState() =>
      _TelaCadastroContrachequeState();
}

class _TelaCadastroContrachequeState extends State<TelaCadastroContracheque> {
  late ControladorCadastroContracheque _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorCadastroContracheque();
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
      if (_controlador.funcionarioSelecionado != null) {
        await _controlador.carregarBeneficiosFuncionario(
          _controlador.funcionarioSelecionado!.id!,
        );
        await _controlador.carregarFaltasFuncionario(
          _controlador.funcionarioSelecionado!.id!,
        );
      }
    } catch (e) {
      _controlador.mostrarErro(context, e.toString());
    }
    setState(() {});
  }

  Future<void> _recarregarFaltas() async {
    if (_controlador.funcionarioSelecionado != null) {
      setState(() {});
      try {
        await _controlador.carregarFaltasFuncionario(
          _controlador.funcionarioSelecionado!.id!,
        );
      } catch (e) {
        _controlador.mostrarErro(context, e.toString());
      }
      setState(() {});
    }
  }

  Future<void> _verificarContrachequeExistente() async {
    if (_controlador.funcionarioSelecionado == null) return;

    final existe = await _controlador.verificarContrachequeExistente();

    if (existe) {
      if (mounted) {
        final continuar = await _controlador.mostrarDialogoContrachequeExistente(context);
        if (!continuar) return;
      }
    }

    await _salvarContracheque();
  }

  Future<void> _salvarContracheque() async {
    setState(() {});
    try {
      final contrachequeId = await _controlador.salvarContracheque();

      if (contrachequeId != null) {
        if (mounted) {
          _controlador.mostrarSucesso(context, 'Contracheque cadastrado com sucesso!');
          setState(() {
            _controlador.limparFormulario();
          });
        }
      } else {
        _controlador.mostrarErro(context, 'Erro ao cadastrar contracheque');
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
          ? Center(child: CircularProgressIndicator())
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
            // Informações básicas
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Básicas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildFuncionarioDropdown(),
                    SizedBox(height: 16),
                    _buildPeriodoSection(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Acréscimos
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valores Adicionais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _controlador.acrescimosController,
                      decoration: InputDecoration(
                        labelText: 'Acréscimos (Horas extras, bônus, etc.)',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        hintText: '0.00',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: _controlador.validarAcrescimos,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Os descontos obrigatórios (INSS, IRRF, FGTS) serão calculados automaticamente com base no salário do funcionário.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (_controlador.funcionarioSelecionado != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'Salário base: ${Formatadores.formatarMoeda(_controlador.funcionarioSelecionado!.salario)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Faltas do Funcionário no período
            if (_controlador.funcionarioSelecionado != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Faltas no Período',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Faltas registradas em ${_controlador.obterNomeMes()} de ${_controlador.anoSelecionado}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12),
                      if (_controlador.isLoadingFaltas)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_controlador.faltasDoFuncionario.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Nenhuma falta registrada neste período',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_controlador.obterNumeroFaltasNaoJustificadas() > 0)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.cancel, color: Colors.red[700], size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Faltas NÃO Justificadas',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[900],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Quantidade:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${_controlador.obterNumeroFaltasNaoJustificadas()} dia${_controlador.obterNumeroFaltasNaoJustificadas() > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Desconto:',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          Formatadores.formatarMoeda(_controlador.calcularDescontoFaltas()),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            
                            SizedBox(height: 16),
                            Text(
                              'Detalhamento das faltas:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            ...(_controlador.faltasDoFuncionario.map((falta) {
                              final isJustificada = falta.faltaJustificada;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      isJustificada ? Icons.check_circle_outline : Icons.cancel_outlined,
                                      size: 16,
                                      color: isJustificada ? Colors.blue[600] : Colors.red[400],
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${falta.data.day.toString().padLeft(2, '0')}/${falta.data.month.toString().padLeft(2, '0')}/${falta.data.year} - ${falta.motivo}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isJustificada ? Colors.blue[50] : Colors.red[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isJustificada ? Colors.blue[200]! : Colors.red[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        isJustificada ? 'Justificada' : 'Não justificada',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isJustificada ? Colors.blue[700] : Colors.red[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()),
                          ],
                        ),
                      SizedBox(height: 8),
                      if (_controlador.obterNumeroFaltasNaoJustificadas() > 0)
                        Text(
                          'Apenas as faltas NÃO justificadas terão desconto aplicado automaticamente no contracheque.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[600],
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (_controlador.obterNumeroFaltasJustificadas() > 0)
                        Text(
                          'Todas as faltas são justificadas. Nenhum desconto será aplicado.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[600],
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 30),

            // Botão Salvar
            ElevatedButton(
              onPressed: _controlador.isSaving ? null : _verificarContrachequeExistente,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: _controlador.isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Cadastrar Contracheque'),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFuncionarioDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Funcionário *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      value: _controlador.funcionarioSelecionado?.id,
      items: _controlador.funcionariosDisponiveis.map((funcionario) {
        return DropdownMenuItem<String>(
          value: funcionario.id,
          child: Text(
            '${funcionario.nome ?? 'Sem nome'} - ${Formatadores.formatarMoeda(funcionario.salario)}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (String? funcionarioId) async {
        if (funcionarioId != null) {
          final funcionario = _controlador.funcionariosDisponiveis.firstWhere(
            (f) => f.id == funcionarioId,
          );
          setState(() {
            _controlador.selecionarFuncionario(funcionario);
          });
          // Carregar benefícios e faltas do novo funcionário selecionado
          try {
            await _controlador.carregarBeneficiosFuncionario(funcionario.id!);
            await _controlador.carregarFaltasFuncionario(funcionario.id!);
            setState(() {});
          } catch (e) {
            _controlador.mostrarErro(context, e.toString());
          }
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um funcionário';
        }
        return null;
      },
    );
  }

  Widget _buildPeriodoSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Mês *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            value: _controlador.mesSelecionado,
            items: List.generate(12, (index) {
              final mes = index + 1;
              return DropdownMenuItem<int>(
                value: mes,
                child: Text(_controlador.meses[index]),
              );
            }),
            onChanged: (int? mes) {
              if (mes != null) {
                setState(() {
                  _controlador.atualizarMes(mes);
                });
                _recarregarFaltas(); // Recarregar faltas ao mudar o mês
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Selecione o mês';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Ano *',
              border: OutlineInputBorder(),
            ),
            initialValue: _controlador.anoSelecionado.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (value) {
              final ano = int.tryParse(value);
              if (ano != null) {
                setState(() {
                  _controlador.atualizarAno(ano);
                });
                _recarregarFaltas(); // Recarregar faltas ao mudar o ano
              }
            },
            validator: _controlador.validarAno,
          ),
        ),
      ],
    );
  }
}
