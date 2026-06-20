import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfStyles {
  // Colores principales
  static const PdfColor colorPrincipal = PdfColors.blueGrey800;
  static const PdfColor colorTexto = PdfColors.black;
  static const PdfColor colorBlanco = PdfColors.white;

  // Estilos de texto precalculados
  static final pw.TextStyle titulo = pw.TextStyle(
    fontSize: 24, 
    fontWeight: pw.FontWeight.bold,
    color: colorPrincipal,
  );
  
  static final pw.TextStyle subtitulo = pw.TextStyle(
    fontSize: 18, 
    fontWeight: pw.FontWeight.bold,
  );
  
  static final pw.TextStyle normal = const pw.TextStyle(
    fontSize: 12,
    color: colorTexto,
  );

  static final pw.TextStyle headerTabla = pw.TextStyle(
    fontSize: 12,
    fontWeight: pw.FontWeight.bold,
    color: colorBlanco,
  );

  // Decoraciones
  static const pw.BoxDecoration fondoHeaderTabla = pw.BoxDecoration(
    color: colorPrincipal,
  );
}