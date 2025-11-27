import 'package:intl/intl.dart';

class Formatadores {

  static String formatarMoeda(double? valor) {
    if (valor == null) return 'R\$ 0,00';
    
    final formatador = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    
    return formatador.format(valor);
  }

  static String formatarNumero(double? valor) {
    if (valor == null) return '0,00';
    
    final formatador = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    
    return formatador.format(valor).trim();
  }

  static String formatarData(DateTime? data) {
    if (data == null) return '';
    
    final formatador = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatador.format(data);
  }

  static String formatarDataHora(DateTime? data) {
    if (data == null) return '';
    
    final formatador = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return formatador.format(data);
  }

  static double? parseValorMoeda(String? texto) {
    if (texto == null || texto.isEmpty) return null;
    String valorLimpo = texto
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    return double.tryParse(valorLimpo);
  }
}
