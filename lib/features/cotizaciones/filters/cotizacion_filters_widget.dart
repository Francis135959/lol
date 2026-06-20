import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CotizacionFiltersWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ValueNotifier<String> searchQueryNotifier;
  final ValueNotifier<DateTime?> selectedDateNotifier;

  const CotizacionFiltersWidget({
    super.key,
    required this.searchController,
    required this.searchQueryNotifier,
    required this.selectedDateNotifier,
  });

  Future<void> _seleccionarFecha(BuildContext context) async {
    // Si ya hay una fecha seleccionada, un toque la limpia (actúa como interruptor)
    if (selectedDateNotifier.value != null) {
      selectedDateNotifier.value = null;
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDateNotifier.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12), // Ajustado el padding derecho para el icono
      child: Row(
        children: [
          // Barra de búsqueda expandida
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente o N° cotización...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                suffixIcon: ValueListenableBuilder<String>(
                  valueListenable: searchQueryNotifier,
                  builder: (context, query, child) {
                    if (query.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchController.clear();
                        searchQueryNotifier.value = '';
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // ÚNICO ICONO: Justo al lado de la barra de búsqueda (Arreglado con iconos estándar)
          ValueListenableBuilder<DateTime?>(
            valueListenable: selectedDateNotifier,
            builder: (context, date, child) {
              final hasDate = date != null;

              return IconButton(
                icon: Icon(
                  hasDate ? Icons.calendar_today : Icons.calendar_month,
                  color: hasDate
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 26, // Tamaño ideal para alinearse con el buscador
                ),
                tooltip: hasDate
                    ? 'Fecha: ${DateFormat('dd/MM/yyyy').format(date)} (Click para limpiar)'
                    : 'Filtrar por fecha',
                onPressed: () => _seleccionarFecha(context),
              );
            },
          ),
        ],
      ),
    );
  }
}