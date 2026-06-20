import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/utils/motor_calculo.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injection.dart';
import '../../../configuracion/presentation/viewmodels/settings_viewmodel.dart';


class PrevisualizacionCotizacion extends StatelessWidget {
  final ResultadoCotizacion resultado;

  const PrevisualizacionCotizacion({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    // Leemos la moneda actual
    final moneda = sl<SettingsViewModel>().state.data?.moneda ?? 'CLP';
    // Obtenemos el formateador dinámico global
    final NumberFormat formatoMoneda = CurrencyFormatter.getFormatter(moneda);
    final bool isUsd = moneda == 'USD';
    final colors = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isUsd ? 'Quotation Breakdown' : 'Desglose de Cotización', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface)),
            const SizedBox(height: 12),
            
            if (resultado.advertenciaUtilidadBaja)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.errorContainer.withValues(alpha: 0.3),
                  border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isUsd ? 'Warning: Profit margin is less than 10%.' : 'Advertencia: El margen de utilidad es menor al 10%.',
                        style: TextStyle(color: colors.error, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            _buildFila(context, isUsd ? 'Materials' : 'Materiales', formatoMoneda.format(resultado.subtotalMateriales)),
            _buildFila(context, isUsd ? 'Labor' : 'Mano de Obra', formatoMoneda.format(resultado.subtotalManoObra)),
            _buildFila(context, isUsd ? 'Transport' : 'Transporte', formatoMoneda.format(resultado.transporte)),
            const Divider(),
            _buildFila(context, isUsd ? 'Subtotal' : 'Subtotal Base', formatoMoneda.format(resultado.subtotalBase)),
            _buildFila(context, isUsd ? 'Profit' : 'Utilidad', formatoMoneda.format(resultado.montoUtilidad), color: colors.onSurface),
            _buildFila(context, isUsd ? 'Tax' : 'IVA', formatoMoneda.format(resultado.montoIva)),
            const Divider(thickness: 2),
            _buildFila(context, 'TOTAL', formatoMoneda.format(resultado.totalFinal), isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFila(BuildContext context, String label, String valor, {bool isTotal = false, Color? color}) {
    final colors = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? colors.onSurface : colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
              color: color ?? colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
