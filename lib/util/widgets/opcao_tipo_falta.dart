import 'package:flutter/material.dart';

/// Widget para opção de tipo de falta (justificada ou não)
/// Estilo de radio button customizado com feedback visual
class OpcaoTipoFalta extends StatelessWidget {
  final String titulo;
  final String descricao;
  final bool selecionada;
  final VoidCallback onTap;
  final IconData? icone;
  final bool faltaJustificada;

  const OpcaoTipoFalta({
    Key? key,
    required this.titulo,
    required this.descricao,
    required this.selecionada,
    required this.onTap,
    this.icone,
    required this.faltaJustificada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selecionada ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selecionada
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selecionada ? Colors.white : Colors.black,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: selecionada ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: 12,
                      color: selecionada ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (selecionada && icone != null)
              Icon(icone, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
