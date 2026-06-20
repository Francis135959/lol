import 'package:flutter/services.dart';

class RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text
        .replaceAll('.', '')
        .replaceAll('-', '')
        .toUpperCase();

    if (text.isEmpty) {
      return newValue;
    }

    if (text.length > 9) {
      text = text.substring(0, 9);
    }

    String cuerpo = text.substring(
      0,
      text.length - 1,
    );

    String dv = text.substring(
      text.length - 1,
    );

    final buffer = StringBuffer();

    int contador = 0;

    for (int i = cuerpo.length - 1; i >= 0; i--) {
      buffer.write(cuerpo[i]);
      contador++;

      if (contador == 3 && i != 0) {
        buffer.write('.');
        contador = 0;
      }
    }

    final rutFormateado = '${buffer
            .toString()
            .split('')
            .reversed
            .join('')}-$dv';

    return TextEditingValue(
      text: rutFormateado,
      selection: TextSelection.collapsed(
        offset: rutFormateado.length,
      ),
    );
  }
}