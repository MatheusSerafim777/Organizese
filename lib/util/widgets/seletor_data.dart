import 'package:flutter/material.dart';

/// Widget reutilizável para seleção de data com DatePicker
/// Usado em várias telas de cadastro
class SeletorData extends StatelessWidget {
  final String label;
  final String dataFormatada;
  final VoidCallback onTap;
  final Color? corIcone;

  const SeletorData({
    Key? key,
    required this.label,
    required this.dataFormatada,
    required this.onTap,
    this.corIcone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today, color: corIcone ?? Colors.black),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          dataFormatada,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
