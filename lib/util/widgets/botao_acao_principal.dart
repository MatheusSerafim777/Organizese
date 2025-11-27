import 'package:flutter/material.dart';

/// Widget reutilizável para botão de ação principal com estado de loading
/// Usado em várias telas de cadastro
class BotaoAcaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? corFundo;
  final Color? corTexto;
  final IconData? icone;

  const BotaoAcaoPrincipal({
    Key? key,
    required this.texto,
    required this.onPressed,
    this.isLoading = false,
    this.corFundo,
    this.corTexto,
    this.icone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: corFundo ?? Colors.black,
        foregroundColor: corTexto ?? Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  corTexto ?? Colors.white,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icone != null) ...[
                  Icon(icone),
                  SizedBox(width: 8),
                ],
                Text(texto),
              ],
            ),
    );
  }
}
