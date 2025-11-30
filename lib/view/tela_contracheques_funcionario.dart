import 'package:flutter/material.dart';
import 'package:organizese/domain/funcionario.dart';
import 'package:organizese/domain/contracheque.dart';
import 'package:organizese/view/controle_interacao/controlador_contracheques_funcionario.dart';
import 'package:organizese/util/formatadores.dart';

class TelaContrachequesFuncionario extends StatefulWidget {
  final Funcionario funcionario;

  const TelaContrachequesFuncionario({
    Key? key,
    required this.funcionario,
  }) : super(key: key);

  @override
  _TelaContrachequesFuncionarioState createState() =>
      _TelaContrachequesFuncionarioState();
}

class _TelaContrachequesFuncionarioState
    extends State<TelaContrachequesFuncionario> {
  late ControladorContrachequesFuncionario _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorContrachequesFuncionario(widget.funcionario);
    _carregarContracheques();
  }

  Future<void> _carregarContracheques() async {
    setState(() {});
    try {
      await _controlador.carregarContracheques();
    } catch (e) {
      _controlador.mostrarErro(context, e.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
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
                (widget.funcionario.nome?.isNotEmpty == true)
                    ? widget.funcionario.nome!.substring(0, 1).toUpperCase()
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
            widget.funcionario.nome ?? 'Nome não informado',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          if (!_controlador.isLoading)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _controlador.contracheques.isEmpty
                    ? Colors.grey.shade100
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _controlador.contracheques.isEmpty
                      ? Colors.grey.shade300
                      : Colors.green.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _controlador.contracheques.isEmpty
                        ? Icons.receipt_long
                        : Icons.assignment_outlined,
                    size: 18,
                    color: _controlador.contracheques.isEmpty
                        ? Colors.grey.shade600
                        : Colors.green.shade700,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _controlador.contracheques.isEmpty
                        ? 'Sem contracheques'
                        : '${_controlador.contracheques.length} ${_controlador.contracheques.length == 1 ? 'contracheque' : 'contracheques'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _controlador.contracheques.isEmpty
                          ? Colors.grey.shade600
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controlador.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.green.shade600,
        ),
      );
    }

    if (_controlador.erro != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              SizedBox(height: 16),
              Text(
                _controlador.erro!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _carregarContracheques,
                icon: Icon(Icons.refresh),
                label: Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_controlador.contracheques.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 80,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 16),
              Text(
                'Nenhum contracheque cadastrado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Este funcionário não possui contracheques cadastrados no sistema.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarContracheques,
      color: Colors.green.shade600,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _controlador.contracheques.length,
        itemBuilder: (context, index) {
          return _buildCardContracheque(_controlador.contracheques[index], index);
        },
      ),
    );
  }

  Widget _buildCardContracheque(Contracheque contracheque, int index) {
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    final nomeMes = meses[contracheque.mes - 1];
    bool mostrarAno = _controlador.deveExibirAno(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostrarAno) ...[
          Padding(
            padding: EdgeInsets.only(
              left: 4,
              top: index == 0 ? 0 : 24,
              bottom: 12,
            ),
            child: Text(
              'ANO ${contracheque.ano}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
        Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header do Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomeMes,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${contracheque.ano}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'PAGO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Corpo do Card
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildLinhaValor(
                      'Salário Bruto',
                      contracheque.valorSalarioBruto,
                      Colors.black87,
                      Icons.attach_money,
                    ),
                    SizedBox(height: 12),
                    _buildLinhaValor(
                      'Acréscimos',
                      contracheque.acrescimos,
                      Colors.green.shade700,
                      Icons.add_circle_outline,
                    ),
                    SizedBox(height: 12),
                    _buildLinhaValor(
                      'Descontos',
                      contracheque.valorSalarioBruto + contracheque.acrescimos - 
                          contracheque.valorSalarioLiquido,
                      Colors.red.shade700,
                      Icons.remove_circle_outline,
                    ),
                    Divider(height: 24, thickness: 1),
                    _buildLinhaValor(
                      'Salário Líquido',
                      contracheque.valorSalarioLiquido,
                      Colors.black,
                      Icons.account_balance_wallet,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              
              // Footer com ações
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Visualizar detalhes (em desenvolvimento)'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(Icons.visibility_outlined, size: 18),
                      label: Text('Ver Detalhes'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinhaValor(
    String label,
    double valor,
    Color cor,
    IconData icone, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icone, size: 20, color: cor),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: cor,
            ),
          ),
        ),
        Text(
          Formatadores.formatarMoeda(valor),
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: cor,
          ),
        ),
      ],
    );
  }
}
