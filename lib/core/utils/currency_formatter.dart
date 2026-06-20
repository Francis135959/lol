import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Patrón Singleton
  static final CurrencyFormatter _instance = CurrencyFormatter._internal();
  factory CurrencyFormatter() => _instance;
  CurrencyFormatter._internal();

  // Obtiene el formateador exacto dependiendo de la moneda
  static NumberFormat getFormatter(String currencyCode) {
    if (currencyCode == 'USD') {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: r'$US ',
        decimalDigits: 2, 
      );
    }
    if (currencyCode == 'EUR') {
      return NumberFormat.currency(
        locale: 'es_ES',
        symbol: '€',
        decimalDigits: 2, 
      );
    }
    if (currencyCode == 'BRL') {
      return NumberFormat.currency(
        locale: 'pt_BR',
        symbol: r'R$ ',
        decimalDigits: 2, 
      );
    }
    if (currencyCode == 'ARS') {
      return NumberFormat.currency(
        locale: 'es_AR',
        symbol: r'$ ',
        decimalDigits: 2, 
      );
    }
    if (currencyCode == 'PEN') {
      return NumberFormat.currency(
        locale: 'es_PE',
        symbol: r'S/ ',
        decimalDigits: 2, 
      );
    }
    // Por defecto CLP
    return NumberFormat.currency(
      locale: 'es_CL',
      symbol: r'$',
      decimalDigits: 0,
      customPattern: '\$#,##0',
    );
  }

  // Método rápido para usar en la UI
  static String format(num value, String currencyCode) {
    return getFormatter(currencyCode).format(value);
  }
}
