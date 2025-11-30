import 'package:flutter/material.dart';
import 'package:organizese/util/navegacao.dart';
import 'package:organizese/util/widgets/card_folha_salarial.dart';
import 'package:organizese/util/formatadores.dart';
import 'package:organizese/controller/controller_funcionario.dart';
import 'package:organizese/view/tela_edicao_funcionario.dart';

class HomePage extends StatelessWidget {
  final ControladorTelaInicial _controlador = ControladorTelaInicial();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FolhaSalarialCard(_controlador),

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
                      Text('Erro ao carregar funcionários'),
                      Text('${snapshot.error}', style: TextStyle(color: Colors.grey)),
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
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        await push(
                          context,
                          TelaEdicaoFuncionario(
                            funcionario: funcionario,
                            cargo: cargo,
                          ),
                        );

                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
