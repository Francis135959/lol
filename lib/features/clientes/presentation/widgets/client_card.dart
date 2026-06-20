import 'package:flutter/material.dart';

import '../../domain/entities/client_entity.dart';

class ClientCard extends StatelessWidget {
  final ClientEntity cliente;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final bool isMenuOpen;
  final VoidCallback onToggleMenu;

  const ClientCard({
    super.key,
    required this.cliente,
    required this.onEdit,
    required this.onDelete,
    this.isMenuOpen = false,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? colors.outline.withValues(alpha: 0.18) : colors.outline.withValues(alpha: 0.2),
          width: 1.1,
        ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        cliente.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isMenuOpen)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 22),
                        onPressed: onEdit,
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 22, color: colors.error),
                        onPressed: onDelete,
                        tooltip: 'Eliminar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 22),
                        onPressed: onToggleMenu,
                        tooltip: 'Cerrar',
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onToggleMenu,
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: isDarkMode ? colors.outline.withValues(alpha: 0.15) : colors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),

            Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 22,
                  color: colors.onSurface,
                ),
                const SizedBox(width: 8),
                Text(cliente.rut, style: TextStyle(color: colors.onSurface, fontSize: 15)),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 22,
                  color: colors.onSurface,
                ),
                const SizedBox(width: 8),
                Text(cliente.telefono, style: TextStyle(color: colors.onSurface, fontSize: 15)),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 22,
                  color: colors.onSurface,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(cliente.correo, style: TextStyle(color: colors.onSurface, fontSize: 15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}