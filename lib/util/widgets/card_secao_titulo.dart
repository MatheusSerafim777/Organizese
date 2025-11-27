import 'package:flutter/material.dart';

/// Widget reutilizável para criar um Card com título de seção
/// Usado em várias telas de cadastro
class CardSecaoTitulo extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Color? corTitulo;
  final List<Widget> children;
  final EdgeInsets? padding;

  const CardSecaoTitulo({
    Key? key,
    required this.titulo,
    this.subtitulo,
    this.corTitulo,
    required this.children,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: corTitulo ?? Colors.black,
              ),
            ),
            if (subtitulo != null) ...[
              SizedBox(height: 8),
              Text(
                subtitulo!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
