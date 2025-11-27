import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';

class TelaFuncionario extends StatefulWidget {
  final Funcionario usuario;

  const TelaFuncionario({Key? key, required this.usuario}) : super(key: key);

  @override
  _TelaFuncionarioState createState() => _TelaFuncionarioState();
}

class _TelaFuncionarioState extends State<TelaFuncionario> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade400,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade100,
                      child: Text(
                        (widget.usuario.nome?.isNotEmpty == true)
                            ? widget.usuario.nome!.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Text(
                    widget.usuario.nome ?? 'Usuário',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Funcionário',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações Pessoais',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),

                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    content: widget.usuario.email ?? 'Não informado',
                  ),

                  _buildInfoCard(
                    icon: Icons.cake_outlined,
                    title: 'Idade',
                    content: widget.usuario.idade?.toString() ?? 'Não informado',
                  ),

                  _buildInfoCard(
                    icon: Icons.badge_outlined,
                    title: 'CPF',
                    content: _formatCPF(widget.usuario.cpf) ?? 'Não informado',
                  ),

                  if (widget.usuario.dataAdmissao != null)
                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Data de Admissão',
                      content: '${widget.usuario.dataAdmissao!.day.toString().padLeft(2, '0')}/${widget.usuario.dataAdmissao!.month.toString().padLeft(2, '0')}/${widget.usuario.dataAdmissao!.year}',
                    ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone com fundo verde claro
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          SizedBox(width: 16),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _formatCPF(String? cpf) {
    if (cpf == null || cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }
}
