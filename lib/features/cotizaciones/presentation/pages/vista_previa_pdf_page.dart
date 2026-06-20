import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/entidad_cotizacion.dart';
import '../../services/pdf_service.dart';

class VistaPreviaPdfPage extends StatefulWidget {
  final EntidadCotizacion cotizacion;

  const VistaPreviaPdfPage({super.key, required this.cotizacion});

  @override
  State<VistaPreviaPdfPage> createState() => _VistaPreviaPdfPageState();
}

class _VistaPreviaPdfPageState extends State<VistaPreviaPdfPage> {
  // Caché en RAM: Almacenará el PDF crudo para no recalcularlo nunca más
  Uint8List? _pdfBytes;
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _generarYCachearPdf();
  }

  Future<void> _generarYCachearPdf() async {
    // 1. Precalculamos los datos y generamos el documento una sola vez (Evita UI congelada)
    final bytes = await PdfService.generarCotizacionPdf(widget.cotizacion);
    
    if (mounted) {
      setState(() {
        _pdfBytes = bytes; // Guardamos en memoria
        _isGenerating = false;
      });
    }
  }

  Future<void> _compartirPdf(BuildContext context) async {
    if (_pdfBytes == null) return;

    try {
      // 2. Usamos path_provider para obtener una ruta segura de almacenamiento
      final dir = await getTemporaryDirectory();
      final String safeId = widget.cotizacion.id.length >= 6 
          ? widget.cotizacion.id.substring(0, 6) 
          : widget.cotizacion.id;
      final fileName = 'Cotizacion_$safeId.pdf';
      
      // 3. Guardado persistente del documento en el dispositivo
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(_pdfBytes!);

      // 4. Compartir usando share_plus (Abre menú de WhatsApp, Email, etc.)
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Adjunto la cotización $fileName',
          subject: 'Cotización de Servicios',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir el archivo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String safeId = widget.cotizacion.id.length >= 6 
        ? widget.cotizacion.id.substring(0, 6) 
        : widget.cotizacion.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documento Cotización'),
        centerTitle: true,
        actions: [
          // Botón optimizado para compartir (solo aparece cuando el PDF ya está en caché)
          if (!_isGenerating)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _compartirPdf(context),
              tooltip: 'Compartir (WhatsApp, Email, Almacenamiento)',
            ),
        ],
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Renderizando documento...'),
                ],
              ),
            )
          : PdfPreview(
              // Inyectamos directamente los bytes en caché. Tiempo de render < 2 segundos.
              build: (format) async => _pdfBytes!,
              allowPrinting: true,
              // Desactivamos el compartir nativo de PdfPreview para usar nuestro método con share_plus
              allowSharing: false, 
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: 'Cotizacion_$safeId.pdf',
            ),
    );
  }
}