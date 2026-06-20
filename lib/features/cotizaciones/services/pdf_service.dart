import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../domain/entities/entidad_cotizacion.dart';
import '../domain/entities/material_item_entity.dart';
import '../domain/entities/labor_item_entity.dart';
import 'pdf_styles.dart';

import '../../../core/di/injection.dart';
import '../../configuracion/presentation/viewmodels/settings_viewmodel.dart';
import '../../../core/utils/currency_formatter.dart';

class PdfService {
  static Future<Uint8List> generarCotizacionPdf(EntidadCotizacion cotizacion) async {
    final pdf = pw.Document();

    final settings = sl<SettingsViewModel>().state.data;
    final moneda = settings?.moneda ?? 'CLP';
    final NumberFormat formatoMoneda = CurrencyFormatter.getFormatter(moneda);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(cotizacion, moneda),
            pw.SizedBox(height: 20),
            _buildTablaMateriales(cotizacion.materials, formatoMoneda, moneda),
            pw.SizedBox(height: 20),
            _buildTablaManoObra(cotizacion.labor, formatoMoneda, moneda),
            pw.SizedBox(height: 20),
            _buildDesglose(cotizacion, formatoMoneda, moneda),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(EntidadCotizacion cotizacion, String moneda) {
    final String idMostrado = cotizacion.id.length >= 6
        ? cotizacion.id.substring(0, 6).toUpperCase()
        : cotizacion.id.toUpperCase();

    final String fechaMostrada = DateFormat('dd/MM/yyyy').format(cotizacion.createdAt);

    final bool isUsd = moneda == 'USD';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Pedro Quezada Valeria S.A.', style: PdfStyles.titulo),
            pw.Text(isUsd ? 'Services and Construction' : 'Servicios y Construcciones', style: PdfStyles.normal),
            pw.SizedBox(height: 10),
            pw.Text((isUsd ? 'Client: ' : 'Cliente: ') + cotizacion.nombreCliente, style: PdfStyles.normal.copyWith(fontWeight: pw.FontWeight.bold)),
            pw.Text((isUsd ? 'Client ID: ' : 'RUT/ID Cliente: ') + cotizacion.clienteId, style: PdfStyles.normal),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text((isUsd ? 'QUOTE N° ' : 'COTIZACIÓN N° ') + idMostrado, style: PdfStyles.subtitulo),
            pw.Text((isUsd ? 'Date: ' : 'Fecha: ') + fechaMostrada, style: PdfStyles.normal),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTablaMateriales(List<MaterialItemEntity> materiales, NumberFormat format, String moneda) {
    final bool isUsd = moneda == 'USD';
    final datosTabla = materiales.isEmpty
        ? [
      [isUsd ? 'No materials added' : 'Sin materiales agregados', '', '', format.format(0)]
    ]
        : List<List<String>>.generate(
      materiales.length,
          (index) {
        final material = materiales[index];
        return [
          material.nombre,
          material.cantidad.toInt().toString(),
          format.format(material.precioUnitario),
          format.format(material.total),
        ];
      },
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(isUsd ? 'Materials and Supplies' : 'Materiales y Suministros', style: PdfStyles.subtitulo.copyWith(fontSize: 14)),
        pw.SizedBox(height: 5),
        pw.TableHelper.fromTextArray(
          headers: [
            isUsd ? 'Description' : 'Descripción',
            isUsd ? 'Qty' : 'Cantidad',
            isUsd ? 'Unit Price' : 'Precio Unitario',
            isUsd ? 'Subtotal' : 'Subtotal',
          ],
          data: datosTabla,
          border: null,
          headerStyle: PdfStyles.headerTabla,
          headerDecoration: PdfStyles.fondoHeaderTabla,
          cellStyle: PdfStyles.normal,
          cellHeight: 25,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }

  static pw.Widget _buildDesglose(EntidadCotizacion cotizacion, NumberFormat format, String moneda) {
    final double costoManoObra = cotizacion.labor.fold(
        0.0,
            (sum, item) => sum + item.total
    );

    final bool isUsd = moneda == 'USD';

    final double costoMateriales = cotizacion.materials.fold(0.0, (sum, item) => sum + item.total);
    final double subtotalBase = costoMateriales + costoManoObra + cotizacion.transport;

    String porcentajeUtilidadStr = '';
    if (subtotalBase > 0 && cotizacion.utility > 0) {
      final double utilPct = cotizacion.utility / subtotalBase * 100;
      porcentajeUtilidadStr = ' (${utilPct.toStringAsFixed(1)}%)';
    }

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 5),
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildFilaResumen(isUsd ? 'Transport:' : 'Transporte:', format.format(cotizacion.transport)),
                pw.Divider(),
                _buildFilaResumen(isUsd ? 'Subtotal:' : 'Subtotal:', format.format(subtotalBase), isBold: true),
                _buildFilaResumen(isUsd ? 'Profit$porcentajeUtilidadStr:' : 'Utilidad$porcentajeUtilidadStr:', format.format(cotizacion.utility)),
                _buildFilaResumen(isUsd ? 'Tax:' : 'IVA:', format.format(cotizacion.iva)),
                pw.Divider(thickness: 2),
                _buildFilaResumen('TOTAL $moneda:', format.format(cotizacion.total), isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Row _buildFilaResumen(String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: isBold ? PdfStyles.normal.copyWith(fontWeight: pw.FontWeight.bold) : PdfStyles.normal),
        pw.Text(value, style: isBold ? PdfStyles.normal.copyWith(fontWeight: pw.FontWeight.bold) : PdfStyles.normal),
      ],
    );
  }

  static pw.Widget _buildTablaManoObra(List<LaborItemEntity> labor, NumberFormat format, String moneda) {
    final bool isUsd = moneda == 'USD';
    final datosTabla = labor.isEmpty
        ? [
      [isUsd ? 'No labor added' : 'Sin personal agregado', '', '', format.format(0)]
    ]
        : List<List<String>>.generate(
      labor.length,
          (index) {
        final l = labor[index];
        return [
          l.cargo,
          isUsd ? '${l.dias} days' : '${l.dias} días',
          format.format(l.valorJornada.toDouble()),
          format.format(l.total),
        ];
      },
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(isUsd ? 'Labor' : 'Mano de Obra y Personal', style: PdfStyles.subtitulo.copyWith(fontSize: 14)),
        pw.SizedBox(height: 5),
        pw.TableHelper.fromTextArray(
          headers: [
            isUsd ? 'Role' : 'Cargo',
            isUsd ? 'Days' : 'Días',
            isUsd ? 'Day Rate' : 'Valor Jornada',
            isUsd ? 'Subtotal' : 'Subtotal',
          ],
          data: datosTabla,
          border: null,
          headerStyle: PdfStyles.headerTabla,
          headerDecoration: PdfStyles.fondoHeaderTabla,
          cellStyle: PdfStyles.normal,
          cellHeight: 25,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }
}