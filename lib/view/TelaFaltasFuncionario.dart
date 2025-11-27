import 'package:flutter/material.dart';
import 'package:organizese/domain/Funcionario.dart';
import 'package:organizese/domain/Falta.dart';
import 'package:organizese/view/controle_interacao/ControladorFaltasFuncionario.dart';
import 'package:organizese/util/formatadores.dart';
import 'package:intl/intl.dart';

class TelaFaltasFuncionario extends StatefulWidget {
  final Funcionario funcionario;

  const TelaFaltasFuncionario({
    Key? key,
    required this.funcionario,
  }) : super(key: key);

  @override
  _TelaFaltasFuncionarioState createState() => _TelaFaltasFuncionarioState();
}

class _TelaFaltasFuncionarioState extends State<TelaFaltasFuncionario> {
  late ControladorFaltasFuncionario _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ControladorFaltasFuncionario(widget.funcionario);
    _carregarFaltas();
  }

  Future<void> _carregarFaltas() async {
    setState(() {});
    try {
      await _controlador.carregarFaltas();
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
                color: _controlador.faltas.isEmpty
                    ? Colors.green.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _controlador.faltas.isEmpty
                      ? Colors.green.shade200
                      : Colors.green.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _controlador.faltas.isEmpty 
                        ? Icons.check_circle 
                        : Icons.event_busy,
                    size: 18,
                    color: _controlador.faltas.isEmpty
                        ? Colors.green.shade700
                        : Colors.green.shade700,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _controlador.faltas.isEmpty
                        ? 'Sem faltas registradas'
                        : '${_controlador.faltas.length} ${_controlador.faltas.length == 1 ? 'falta' : 'faltas'} registrada${_controlador.faltas.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _controlador.faltas.isEmpty
                          ? Colors.green.shade700
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
                onPressed: _carregarFaltas,
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

    if (_controlador.faltas.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green.shade300,
              ),
              SizedBox(height: 16),
              Text(
                'Nenhuma falta registrada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Este funcionário não possui faltas cadastradas no sistema.',
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
      onRefresh: _carregarFaltas,
      color: Colors.green.shade600,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _controlador.faltas.length,
        itemBuilder: (context, index) {
          return _buildCardFalta(_controlador.faltas[index], index);
        },
      ),
    );
  }

  Widget _buildCardFalta(Falta falta, int index) {
    final mesAno = DateFormat('MMMM/yyyy', 'pt_BR').format(falta.data);
    bool mostrarMesAno = _controlador.deveExibirMesAno(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostrarMesAno) ...[
          Padding(
            padding: EdgeInsets.only(
              left: 4,
              top: index == 0 ? 0 : 24,
              bottom: 12,
            ),
            child: Text(
              mesAno.toUpperCase(),
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
              color: falta.faltaJustificada
                  ? Colors.blue.shade200
                  : Colors.red.shade200,
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone e data
                Container(
                  width: 60,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: falta.faltaJustificada
                              ? Colors.blue.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          falta.faltaJustificada
                              ? Icons.event_available
                              : Icons.event_busy,
                          color: falta.faltaJustificada
                              ? Colors.blue.shade600
                              : Colors.red.shade600,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        DateFormat('dd', 'pt_BR').format(falta.data),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('MMM', 'pt_BR')
                            .format(falta.data)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              Formatadores.formatarData(falta.data),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: falta.faltaJustificada
                                  ? Colors.blue.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              falta.faltaJustificada
                                  ? 'JUSTIFICADA'
                                  : 'NÃO JUSTIFICADA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: falta.faltaJustificada
                                    ? Colors.blue.shade800
                                    : Colors.red.shade800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              falta.motivo.isNotEmpty
                                  ? falta.motivo
                                  : 'Sem motivo informado',
                              style: TextStyle(
                                fontSize: 14,
                                color: falta.motivo.isNotEmpty
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                                fontStyle: falta.motivo.isNotEmpty
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!falta.faltaJustificada) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.green.shade600,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Desconto aplicado no contracheque',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
