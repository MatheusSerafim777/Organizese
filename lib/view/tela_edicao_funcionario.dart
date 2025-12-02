import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/domain/cargo.dart';
import 'package:organizese/util/formatadores.dart';
import 'package:organizese/view/controle_interacao/controller_edicao_funcionario.dart';

class TelaEdicaoFuncionario extends StatefulWidget {
  final Funcionario funcionario;
  final Cargo? cargo;

  const TelaEdicaoFuncionario({
    Key? key,
    required this.funcionario,
    this.cargo,
  }) : super(key: key);

  @override
  _TelaEdicaoFuncionarioState createState() => _TelaEdicaoFuncionarioState();
}

class _TelaEdicaoFuncionarioState extends State<TelaEdicaoFuncionario> {
  final _formKey = GlobalKey<FormState>();
  final ControladorEdicaoFuncionario _controlador = ControladorEdicaoFuncionario();

  late TextEditingController _nomeController;
  late TextEditingController _idadeController;
  late TextEditingController _cpfController;
  late TextEditingController _emailController;

  List<Cargo> _cargosDisponiveis = [];
  Cargo? _cargoSelecionado;
  bool _isLoading = false;
  bool _isLoadingCargos = true;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.funcionario.nome);
    _idadeController = TextEditingController(
      text: widget.funcionario.idade?.toString() ?? '',
    );
    _cpfController = TextEditingController(text: widget.funcionario.cpf);
    _emailController = TextEditingController(text: widget.funcionario.email);
    // Não atribui o cargo ainda, será atribuído após carregar a lista
    _carregarCargos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _carregarCargos() async {
    setState(() => _isLoadingCargos = true);
    try {
      final resultado = await _controlador.carregarCargosESelecionar(
        widget.funcionario.cargoId,
      );
      
      setState(() {
        _cargosDisponiveis = resultado['cargos'] as List<Cargo>;
        _cargoSelecionado = resultado['cargoSelecionado'] as Cargo?;
        _isLoadingCargos = false;
      });
    } catch (e) {
      setState(() => _isLoadingCargos = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _controlador.atualizarFuncionario(
        funcionarioId: widget.funcionario.id!,
        nome: _nomeController.text,
        email: _emailController.text,
        cpf: _cpfController.text,
        idade: int.parse(_idadeController.text.trim()),
        cargoId: _cargoSelecionado?.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Funcionário atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _demitirFuncionario() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Demissão'),
        content: Text(
          'Tem certeza que deseja demitir ${widget.funcionario.nome}?\n\n'
              'Esta ação registrará a data de demissão e o funcionário não aparecerá mais na lista de ativos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Demitir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      await _controlador.demitirFuncionario(widget.funcionario.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Funcionário demitido com sucesso'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Funcionário'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.delete_outline),
              tooltip: 'Demitir funcionário',
              onPressed: _demitirFuncionario,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar e nome
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[300],
                      child: Text(
                        (widget.funcionario.nome?.isNotEmpty == true)
                            ? widget.funcionario.nome!
                            .substring(0, 1)
                            .toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              SizedBox(height: 32),


              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) => _controlador.validarNome(value),
              ),
              SizedBox(height: 16),


              // Campo CPF
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '000.000.000-00',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (value) {
                  final formatted = _controlador.formatarCPF(value);
                  if (formatted != value) {
                    _cpfController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }
                },
                validator: (value) => _controlador.validarCPF(value),
              ),
              SizedBox(height: 16),

              // Campo Idade
              TextFormField(
                controller: _idadeController,
                decoration: InputDecoration(
                  labelText: 'Idade',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) => _controlador.validarIdade(value),
              ),
              SizedBox(height: 16),

              // Dropdown Cargo
              _isLoadingCargos
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<Cargo>(
                      isExpanded: true,
                      value: _cargosDisponiveis.contains(_cargoSelecionado) 
                          ? _cargoSelecionado 
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _cargosDisponiveis.map((cargo) {
                        return DropdownMenuItem<Cargo>(
                          value: cargo,
                          child: Text(
                            '${cargo.nome} - ${Formatadores.formatarMoeda(cargo.salario)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (Cargo? novoCargo) {
                        setState(() {
                          _cargoSelecionado = novoCargo;
                        });
                      },
                      validator: (value) => _controlador.validarCargo(value),
                    ),
              SizedBox(height: 24),

              SizedBox(height: 24),

              // Botões de ação
              Row(
                children: [Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context),
                    icon: Icon(Icons.cancel),
                    label: Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _salvarAlteracoes,
                      icon: Icon(Icons.save),
                      label: Text('Salvar Alterações'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Botão de demissão destacado
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _demitirFuncionario,
                icon: Icon(Icons.person_remove),
                label: Text('Demitir Funcionário'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
