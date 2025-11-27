import 'package:flutter/material.dart';
import 'package:organizese/controller/Controller_funcionario.dart';
import 'package:organizese/util/formatadores.dart';

class FolhaSalarialCard extends StatelessWidget {
  final ControladorTelaInicial _controlador;

  FolhaSalarialCard(this._controlador);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<double>(
        future: _controlador.obterValordaFolha(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao calcular folha',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            );
          }

          final total = snapshot.data ?? 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "VALOR DA FOLHA SALARIAL DESSE MES:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                Formatadores.formatarMoeda(total),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
