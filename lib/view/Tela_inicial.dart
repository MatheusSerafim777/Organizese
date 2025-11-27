import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/controller/Controller_funcionario.dart';
import 'package:organizese/util/formatadores.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaInicial extends StatefulWidget {
  final Funcionario usuario;
  TelaInicial(this.usuario);

  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final ControladorTelaInicial _controlador = ControladorTelaInicial();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organize-se'),
        backgroundColor: Colors.green[200],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.green[50],
        child: Column(
          children: [
            // Header com informações do usuário logado
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo, ${widget.usuario.nome ?? 'Usuário'}!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.usuario.admin == true)
                    Text(
                      'Administrador',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),

            // Título da lista
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.people, color: Colors.green[700]),
                  SizedBox(width: 8),
                  Text(
                    'Funcionários Cadastrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            // Lista de funcionários
            Expanded(
              child: StreamBuilder<List<FuncionarioComCargo>>(
                stream: _controlador.obterFuncionarios(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Erro ao carregar funcionários',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final funcionarios = snapshot.data ?? [];

                  if (funcionarios.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum funcionário encontrado',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: funcionarios.length,
                    itemBuilder: (context, index) {
                      final funcionarioComCargo = funcionarios[index];
                      final funcionario = funcionarioComCargo.funcionario;
                      final cargo = funcionarioComCargo.cargo;

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[300],
                            child: Text(
                              (funcionario.nome?.isNotEmpty == true)
                                ? funcionario.nome!.substring(0, 1).toUpperCase()
                                : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            funcionario.nome ?? 'Nome não informado',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cargo: ${cargo?.nome ?? 'Não definido'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (cargo?.salario != null)
                                Text(
                                  'Salário: ${Formatadores.formatarMoeda(cargo!.salario)}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (funcionario.email != null)
                                Text(
                                  funcionario.email!,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            // Aqui você pode adicionar navegação para detalhes do funcionário
                            _mostrarDetalhesFuncionario(context, funcionarioComCargo);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _mostrarDetalhesFuncionario(BuildContext context, FuncionarioComCargo funcionarioComCargo) {
    final funcionario = funcionarioComCargo.funcionario;
    final cargo = funcionarioComCargo.cargo;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(funcionario.nome ?? 'Funcionário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetalheItem('Email:', funcionario.email ?? 'Não informado'),
            _buildDetalheItem('Idade:', funcionario.idade?.toString() ?? 'Não informado'),
            _buildDetalheItem('CPF:', funcionario.cpf ?? 'Não informado'),
            _buildDetalheItem('Cargo:', cargo?.nome ?? 'Não definido'),
            _buildDetalheItem('Salário:', cargo != null ? Formatadores.formatarMoeda(cargo.salario) : 'Não definido'),
            _buildDetalheItem('Administrador:', funcionario.admin == true ? 'Sim' : 'Não'),
            if (funcionario.dataAdmissao != null)
              _buildDetalheItem('Data de Admissão:', '${funcionario.dataAdmissao!.day}/${funcionario.dataAdmissao!.month}/${funcionario.dataAdmissao!.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetalheItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}