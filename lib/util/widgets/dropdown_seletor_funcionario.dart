import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/util/formatadores.dart';

/// Widget reutilizável para seleção de funcionário
/// Usado em Cadastro de Falta, Cadastro de Contracheque, etc.
class DropdownSeletorFuncionario extends StatelessWidget {
  final List<Funcionario> funcionarios;
  final String? funcionarioSelecionadoId;
  final Function(String?) onChanged;
  final bool mostrarSalario;
  final Color? corIcone;
  final String? Function(String?)? validator;

  const DropdownSeletorFuncionario({
    Key? key,
    required this.funcionarios,
    required this.funcionarioSelecionadoId,
    required this.onChanged,
    this.mostrarSalario = false,
    this.corIcone,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Funcionário *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person, color: corIcone ?? Colors.black),
      ),
      value: funcionarioSelecionadoId,
      items: funcionarios.map((funcionario) {
        String textoExibido = funcionario.nome ?? 'Sem nome';
        
        if (mostrarSalario && funcionario.salario != null) {
          textoExibido += ' - ${Formatadores.formatarMoeda(funcionario.salario)}';
        }
        
        return DropdownMenuItem<String>(
          value: funcionario.id,
          child: Text(textoExibido),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um funcionário';
        }
        return null;
      },
    );
  }
}
