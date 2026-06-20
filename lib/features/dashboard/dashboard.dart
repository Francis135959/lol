import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../clientes/domain/repositories/client_repository.dart';
import '../cotizaciones/domain/repositories/cotizacion_repository.dart';

import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../configuracion/presentation/viewmodels/settings_viewmodel.dart';
import '../cotizaciones/domain/entities/entidad_cotizacion.dart';
import '../clientes/domain/entities/client_entity.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final clientRepo = sl<ClientRepository>();
    final quoteRepo = sl<CotizacionRepository>();
    final settings = sl<SettingsViewModel>().state.data;
    final moneda = settings?.moneda ?? 'CLP';

    return StreamBuilder<List<ClientEntity>>(
      stream: clientRepo.watchClientes(),
      builder: (context, clientSnapshot) {
        return StreamBuilder<List<EntidadCotizacion>>(
          stream: quoteRepo.watchCotizaciones(),
          builder: (context, quoteSnapshot) {
            final clientes = clientSnapshot.data ?? [];
            final cotizaciones = quoteSnapshot.data ?? [];

            final now = DateTime.now();
            final cotizacionesMes = cotizaciones
                .where((c) =>
            c.createdAt.month == now.month &&
                c.createdAt.year == now.year)
                .toList();
            final totalEstimadoMes =
            cotizacionesMes.fold(0.0, (sum, c) => sum + c.total);

            final promedioPorCliente = clientes.isEmpty
                ? 0.0
                : (cotizaciones.length / clientes.length);

            final ultimasCotizaciones =
            List<EntidadCotizacion>.from(cotizaciones)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final top3 = ultimasCotizaciones.take(3).toList();

            String totalFormateado =
            CurrencyFormatter.format(totalEstimadoMes, moneda);
            totalFormateado =
                totalFormateado.replaceAll(RegExp(r'\s*\$\s*'), '').trim();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: _ResumenCard(
                          titulo: 'Clientes',
                          amount: clientes.length.toString(),
                          icon: Icons.people,
                          color: colors.primaryContainer,
                          onColor: colors.onPrimaryContainer,
                          onTap: () => context.push('/clients'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ResumenCard(
                          titulo: 'Cotizaciones',
                          amount: cotizaciones.length.toString(),
                          icon: Icons.request_quote,
                          color: colors.primaryContainer,
                          onColor: colors.onPrimaryContainer,
                          onTap: () =>
                              context.push('/historial-cotizaciones'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _ResumenCard(
                          titulo: 'Monto del Mes',
                          amount: totalFormateado,
                          icon: Icons.attach_money,
                          color: colors.primaryContainer,
                          onColor: colors.onPrimaryContainer,
                          isMonedaCard: true,
                          onTap: null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ResumenCard(
                          titulo: 'Prom. x Cliente',
                          amount: promedioPorCliente.toStringAsFixed(1),
                          icon: Icons.analytics,
                          color: colors.primaryContainer,
                          onColor: colors.onPrimaryContainer,
                          onTap: null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _DashboardCard(
                      icon: Icons.bolt_rounded,
                      label: 'Nueva Cotización Rápida',
                      color: colors.primary,
                      iconColor: colors.onPrimary,
                      textColor: colors.onPrimary,
                      onTap: () =>
                          context.push('/nueva-cotizacion', extra: false),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _DashboardCard(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Crear Nuevo\nCliente',
                          color: colors.primaryContainer,
                          iconColor: colors.onPrimaryContainer,
                          textColor: colors.onPrimaryContainer,
                          onTap: () => context.push('/nuevo-cliente'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DashboardCard(
                          icon: Icons.add_chart_rounded,
                          label: 'Crear\nCotización',
                          color: colors.primaryContainer,
                          iconColor: colors.onPrimaryContainer,
                          textColor: colors.onPrimaryContainer,
                          onTap: () =>
                              context.push('/nueva-cotizacion', extra: true),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Últimas Cotizaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            context.push('/historial-cotizaciones'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryContainer,
                          foregroundColor: colors.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (top3.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No hay cotizaciones recientes',
                          style:
                          TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ...top3.map((cotizacion) =>
                        _buildCotizacionCard(context, cotizacion, moneda)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCotizacionCard(
      BuildContext context,
      EntidadCotizacion cotizacion,
      String moneda,
      ) {
    final theme = Theme.of(context).colorScheme;
    final fechaFormat =
    DateFormat('dd MMM yyyy').format(cotizacion.createdAt);

    return GestureDetector(
      onTap: () => context.push('/pdf_preview', extra: cotizacion),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.outlineVariant.withValues(alpha: 0.3),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cliente',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cotizacion.nombreCliente.isEmpty
                              ? 'Sin Nombre'
                              : cotizacion.nombreCliente,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: theme.primary),
                    onSelected: (value) {
                      if (value == 'edit') {
                        final isRapida =
                            cotizacion.clienteId.startsWith('rapida-') ||
                                cotizacion.clienteId == '12345678-9';
                        context.push('/nueva-cotizacion',
                            extra: {
                              'cotizacion': cotizacion,
                              'rapida': isRapida,
                            });
                      } else if (value == 'pdf') {
                        context.push('/pdf_preview', extra: cotizacion);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 18, color: theme.onSurface),
                            const SizedBox(width: 8),
                            const Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf_outlined,
                                size: 18, color: theme.onSurface),
                            const SizedBox(width: 8),
                            const Text('Ver PDF'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                    height: 1,
                    color: theme.outlineVariant.withValues(alpha: 0.3)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        fechaFormat,
                        style: TextStyle(
                          color: theme.onSurfaceVariant.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(cotizacion.total, moneda),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String titulo;
  final String amount;
  final IconData icon;
  final Color color;
  final Color onColor;
  final VoidCallback? onTap;
  final bool isMonedaCard;

  const _ResumenCard({
    required this.titulo,
    required this.amount,
    required this.icon,
    required this.color,
    required this.onColor,
    this.onTap,
    this.isMonedaCard = false,
  });

  void _mostrarMontoCompleto(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icon(icon, size: 40, color: theme.primary),
          title: Text(titulo,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Valor completo:',
                  style: TextStyle(
                      fontSize: 14,
                      color: theme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Text(
                isMonedaCard ? '\$ $amount' : amount,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.primary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color colorIconoYTitulo = onColor.withValues(alpha: 0.85);

    return Card(
      color: color,
      elevation: 0,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: (isMonedaCard || onTap == null)
            ? () => _mostrarMontoCompleto(context)
            : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: colorIconoYTitulo, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorIconoYTitulo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 32,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: isMonedaCard ? 20 : 26,
                      fontWeight: FontWeight.bold,
                      color: onColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 44, color: iconColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}