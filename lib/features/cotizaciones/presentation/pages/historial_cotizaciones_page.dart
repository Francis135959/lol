import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../configuracion/presentation/viewmodels/settings_viewmodel.dart';

import '../../domain/repositories/cotizacion_repository.dart';
import '../../domain/entities/entidad_cotizacion.dart';
import '../../filters/cotizacion_filters_widget.dart';
import '../viewmodels/historial_cotizaciones_viewmodel.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HistorialCotizacionesPage extends StatefulWidget {
  const HistorialCotizacionesPage({super.key});

  @override
  State<HistorialCotizacionesPage> createState() =>
      _HistorialCotizacionesPageState();
}

class _HistorialCotizacionesPageState extends State<HistorialCotizacionesPage> {
  late final HistorialCotizacionesViewModel viewModel;
  late final Stream<List<EntidadCotizacion>> _cotizacionesStream;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);

  String? _activeMenuId;

  bool get _isSelectionMode => viewModel.seleccionadas.isNotEmpty;

  @override
  void initState() {
    super.initState();
    viewModel = sl<HistorialCotizacionesViewModel>();

    _cotizacionesStream = sl<CotizacionRepository>().watchCotizaciones();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery.value = _searchController.text.trim().toLowerCase();
    });
  }

  void _toggleSelection(String id) {
    viewModel.toggleSeleccion(id);
  }

  void _clearSelection() {
    viewModel.limpiarSeleccion();
  }

  void _seleccionarTodasVisibles(List<EntidadCotizacion> itemsVisibles) {
    viewModel.seleccionarMultiples(itemsVisibles.map((c) => c.id).toList());
  }

  Future<void> _deleteSelected() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cotizaciones'),
        content: Text('¿Eliminar ${viewModel.seleccionadas.length} cotizaciones seleccionadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await viewModel.eliminarSeleccionadas();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cotizaciones eliminadas')),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchQuery.dispose();
    _selectedDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: AppDrawer(
            selectedIndex: 2,
            onItemTapped: (index) {
              final routes = ['/dashboard', '/clients', '/quotes', '/settings'];
              if (index >= 0 && index < routes.length) {
                context.go(routes[index]);
              }
            },
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: _isSelectionMode
                ? null
                : Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            title: Text(
              _isSelectionMode
                  ? '${viewModel.seleccionadas.length} seleccionadas'
                  : 'Historial de Cotizaciones',
            ),
            centerTitle: true,
            actions: _isSelectionMode
                ? [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteSelected,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
            ]
                : null,
          ),
          body: Column(
            children: [
              CotizacionFiltersWidget(
                searchController: _searchController,
                searchQueryNotifier: _searchQuery,
                selectedDateNotifier: _selectedDate,
              ),
              Divider(
                height: 1,
                color: theme.outlineVariant.withValues(alpha: 0.2),
              ),
              Expanded(
                child: StreamBuilder<List<EntidadCotizacion>>(
                  stream: _cotizacionesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final cotizaciones = List<EntidadCotizacion>.from(snapshot.data ?? []);

                    cotizaciones.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (cotizaciones.isEmpty) {
                      return _buildEmptyState(
                        context,
                        'No hay cotizaciones registradas.',
                        Icons.history_edu,
                      );
                    }

                    return AnimatedBuilder(
                      animation: Listenable.merge([_searchQuery, _selectedDate]),
                      builder: (context, child) {
                        final filtradas = cotizaciones.where((c) {
                          final matchSearch =
                              c.nombreCliente.toLowerCase().contains(_searchQuery.value) ||
                                  c.id.toLowerCase().contains(_searchQuery.value);
                          bool matchDate = true;
                          if (_selectedDate.value != null) {
                            final dateDoc = DateFormat('yyyy-MM-dd').format(c.createdAt);
                            final dateFilter = DateFormat('yyyy-MM-dd').format(_selectedDate.value!);
                            matchDate = dateDoc == dateFilter;
                          }
                          return matchSearch && matchDate;
                        }).toList();

                        if (filtradas.isEmpty) {
                          return _buildEmptyState(
                            context,
                            'No se encontraron resultados.',
                            Icons.search_off,
                          );
                        }

                        return Column(
                          children: [
                            if (!_isSelectionMode)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.select_all, size: 18),
                                  label: const Text('Seleccionar todas'),
                                  onPressed: () => _seleccionarTodasVisibles(filtradas),
                                ),
                              ),
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: filtradas.length,
                                itemBuilder: (context, index) {
                                  final cotizacion = filtradas[index];
                                  final selected = viewModel.estaSeleccionada(cotizacion.id);

                                  return GestureDetector(
                                    onLongPress: () => _toggleSelection(cotizacion.id),
                                    onTap: () {
                                      if (_activeMenuId != null) {
                                        setState(() => _activeMenuId = null);
                                        return;
                                      }
                                      if (_isSelectionMode) {
                                        _toggleSelection(cotizacion.id);
                                      } else {
                                        context.push('/pdf_preview', extra: cotizacion);
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        _buildCotizacionCard(context, cotizacion, ValueKey('cot_${cotizacion.id}')),
                                        if (selected)
                                          Positioned.fill(
                                            child: AbsorbPointer(
                                              child: Container(
                                                margin: const EdgeInsets.only(bottom: 16),
                                                decoration: BoxDecoration(
                                                  color: theme.primary.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: theme.primary, width: 2),
                                                ),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Icon(Icons.check_circle, color: theme.primary),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String mensaje, IconData icon) {
    final theme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(mensaje, style: TextStyle(color: theme.onSurfaceVariant.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildCotizacionCard(
      BuildContext context,
      EntidadCotizacion cotizacion,
      Key key,
      ) {
    final theme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fechaFormat = DateFormat('dd MMM yyyy').format(cotizacion.createdAt);
    final moneda = sl<SettingsViewModel>().state.data?.moneda ?? 'CLP';
    final String precioFormateado = CurrencyFormatter.format(cotizacion.total, moneda);

    final bool isMenuOpen = _activeMenuId == cotizacion.id;

    return Card(
      key: key,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isDarkMode
              ? theme.outline.withValues(alpha: 0.18)
              : theme.outline.withValues(alpha: 0.2),
          width: 1.1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente',
                        style: TextStyle(fontSize: 12, color: theme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cotizacion.nombreCliente.isEmpty ? 'Sin Nombre' : cotizacion.nombreCliente,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isMenuOpen)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Editar',
                        onPressed: () async {
                          setState(() => _activeMenuId = null);
                          final isRapida =
                              cotizacion.clienteId.startsWith('rapida-') ||
                                  cotizacion.clienteId == '12345678-9';
                          await context.push('/nueva-cotizacion', extra: {
                            'cotizacion': cotizacion,
                            'rapida': isRapida,
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20, color: theme.error),
                        tooltip: 'Eliminar',
                        onPressed: () async {
                          setState(() => _activeMenuId = null);

                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Eliminar cotización'),
                              content: const Text('¿Está seguro de que desea eliminar esta cotización de forma permanente?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            await viewModel.eliminarCotizacion(cotizacion.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cotización eliminada con éxito')),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Cerrar',
                        onPressed: () => setState(() => _activeMenuId = null),
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: Icon(Icons.more_vert, color: theme.primary),
                    onPressed: () => setState(
                          () => _activeMenuId = (_activeMenuId == cotizacion.id) ? null : cotizacion.id,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: isDarkMode
                    ? theme.outline.withValues(alpha: 0.15)
                    : theme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: theme.onSurfaceVariant),
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
                  precioFormateado,
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
    );
  }


}