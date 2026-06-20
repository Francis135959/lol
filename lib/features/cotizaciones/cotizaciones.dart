import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../configuracion/presentation/viewmodels/settings_viewmodel.dart';
import 'domain/entities/entidad_cotizacion.dart';
import 'domain/repositories/cotizacion_repository.dart';
import 'domain/utils/motor_calculo.dart';

import 'presentation/widgets/previsualizacion_cotizacion.dart';
import 'domain/entities/material_item_entity.dart';
import 'domain/entities/labor_item_entity.dart';

class QuotesScreen extends StatefulWidget {
  final EntidadCotizacion? cotizacion;

  const QuotesScreen({super.key, this.cotizacion});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  late final CotizacionRepository repository;

  final TextEditingController _materialesController = TextEditingController();
  final TextEditingController _manoObraController = TextEditingController();
  final TextEditingController _transporteController = TextEditingController();
  final TextEditingController _utilidadController = TextEditingController(text: '10');
  final TextEditingController _ivaController = TextEditingController();

  late final ValueNotifier<ResultadoCotizacion> _resultadoNotifier;

  @override
  void initState() {
    super.initState();
    repository = sl<CotizacionRepository>();

    final ivaGlobal = sl<SettingsViewModel>().state.data?.iva ?? 19.0;
    _ivaController.text = ivaGlobal.toString();

    if (widget.cotizacion != null) {
      _materialesController.text = (widget.cotizacion!.materials.isNotEmpty ? widget.cotizacion!.materials.first.precioUnitario : 0.0).toStringAsFixed(0);
      _manoObraController.text = (widget.cotizacion!.labor.isNotEmpty ? widget.cotizacion!.labor.first.valorJornada : 0.0).toStringAsFixed(0);
      _transporteController.text = widget.cotizacion!.transport.toStringAsFixed(0);
      final utilBase = (widget.cotizacion!.materials.fold(0.0, (s, m) => s + m.total) + widget.cotizacion!.labor.fold(0.0, (s, l) => s + l.total) + widget.cotizacion!.transport);
      _utilidadController.text = utilBase > 0 ? ((widget.cotizacion!.utility / utilBase) * 100).toStringAsFixed(0) : '10';
      _ivaController.text = widget.cotizacion!.iva > 0 && utilBase > 0 ? ((widget.cotizacion!.iva / ((utilBase + widget.cotizacion!.utility) * (ivaGlobal / 100.0) > 0 ? (utilBase + widget.cotizacion!.utility) : 1)) * 100).toStringAsFixed(0) : ivaGlobal.toStringAsFixed(0);
    }

    _resultadoNotifier = ValueNotifier(MotorCalculo.calcular(
      totalMateriales: double.tryParse(_materialesController.text) ?? 0.0,
      totalManoObra: double.tryParse(_manoObraController.text) ?? 0.0,
      transporte: double.tryParse(_transporteController.text) ?? 0.0,
      porcentajeUtilidad: (double.tryParse(_utilidadController.text) ?? 0.0) / 100.0,
      porcentajeIva: (double.tryParse(_ivaController.text) ?? ivaGlobal) / 100.0,
    ));

    _materialesController.addListener(_actualizarCalculos);
    _manoObraController.addListener(_actualizarCalculos);
    _transporteController.addListener(_actualizarCalculos);
    _utilidadController.addListener(_actualizarCalculos);
    _ivaController.addListener(_actualizarCalculos);
  }

  @override
  void dispose() {
    _materialesController.dispose();
    _manoObraController.dispose();
    _transporteController.dispose();
    _utilidadController.dispose();
    _ivaController.dispose();
    _resultadoNotifier.dispose();
    super.dispose();
  }

  void _actualizarCalculos() {
    final materiales = double.tryParse(_materialesController.text) ?? 0.0;
    final manoObra = double.tryParse(_manoObraController.text) ?? 0.0;
    final transporte = double.tryParse(_transporteController.text) ?? 0.0;
    final utilidadPorcentaje = (double.tryParse(_utilidadController.text) ?? 0.0) / 100;
    final ivaPorcentaje = (double.tryParse(_ivaController.text) ?? 0.0) / 100;

    _resultadoNotifier.value = MotorCalculo.calcular(
      totalMateriales: materiales,
      totalManoObra: manoObra,
      transporte: transporte,
      porcentajeUtilidad: utilidadPorcentaje,
      porcentajeIva: ivaPorcentaje,
    );
  }

  Future<void> _irAVistaPreviaPdf() async {
    // --- VALIDACIÓN DE LÍMITES FINANCIEROS [0, 100] ---
    final utilidad = double.tryParse(_utilidadController.text) ?? 0.0;
    final iva = double.tryParse(_ivaController.text) ?? 0.0;

    if (utilidad > 100 || iva > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingresa porcentajes válidos entre 0% y 100%'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return; 
    }

    final materiales = double.tryParse(_materialesController.text) ?? 0.0;
    final manoObra = double.tryParse(_manoObraController.text) ?? 0.0;

    final cotizacion = EntidadCotizacion(
      id: 'COT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      clienteId: '12345678-9',
      nombreCliente: 'Cliente General',
      materials: [
        MaterialItemEntity(
          nombre: sl<SettingsViewModel>().state.data?.moneda == 'USD' ? 'Project base materials' : 'Materiales base del proyecto',
          cantidad: 1.0,
          precioUnitario: materiales,
        )
      ],
      labor: [
        LaborItemEntity(
          cargo: sl<SettingsViewModel>().state.data?.moneda == 'USD' ? 'Calculated labor' : 'Mano de obra calculada',
          valorJornada: manoObra.toInt(),
          dias: 1,
        )
      ],
      metrosCuadrados: 0.0,
      direccion: 'Sin Dirección',
      tipoTrabajo: const [],
      transport: _resultadoNotifier.value.transporte,
      utility: _resultadoNotifier.value.montoUtilidad,
      iva: _resultadoNotifier.value.montoIva,
      total: _resultadoNotifier.value.totalFinal,
      status: 'borrador',
      version: 1,
      createdAt: widget.cotizacion?.createdAt ?? DateTime.now(),
    );

    await repository.guardarCotizacion(cotizacion);

    if (!mounted) return;
    context.push('/pdf_preview', extra: cotizacion);
  }

  InputDecoration _construirDecoracionLimpia(BuildContext context, String label, {String? errorText}) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: colors.surface,
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Evaluadores numéricos instantáneos para actualizar los errorText de los inputs
    final currentUtility = double.tryParse(_utilidadController.text) ?? 0.0;
    final currentIva = double.tryParse(_ivaController.text) ?? 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Cotización Rápida',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _materialesController,
                decoration: _construirDecoracionLimpia(context, 'Costo Materiales (\$)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _manoObraController,
                decoration: _construirDecoracionLimpia(context, 'Costo Mano de Obra (\$)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _transporteController,
                decoration: _construirDecoracionLimpia(context, 'Costo Transporte (\$)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              
              // --- CAMPO UTILIDAD OPTIMIZADO ---
              TextField(
                controller: _utilidadController,
                decoration: _construirDecoracionLimpia(
                  context, 
                  'Porcentaje Utilidad (%)',
                  errorText: currentUtility > 100 ? 'La utilidad debe estar entre 0% y 100%' : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              
              // --- CAMPO IVA OPTIMIZADO ---
              TextField(
                controller: _ivaController,
                decoration: _construirDecoracionLimpia(
                  context, 
                  'Porcentaje IVA (%)',
                  errorText: currentIva > 100 ? 'El IVA debe estar entre 0% y 100%' : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<ResultadoCotizacion>(
                valueListenable: _resultadoNotifier,
                builder: (context, resultado, child) {
                  return PrevisualizacionCotizacion(resultado: resultado);
                },
              ),

              const SizedBox(height: 24),
              
              FilledButton.icon(
                onPressed: _irAVistaPreviaPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generar Vista Previa PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}