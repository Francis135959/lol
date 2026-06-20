import 'package:flutter/material.dart';

class EmptyClients extends StatelessWidget {
  const EmptyClients({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: theme.onSurfaceVariant.withOpacity(0.4),
          ),

          const SizedBox(height: 16),

          const Text(
            'Aún no tienes clientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Presiona el botón + para crear uno',
            style: TextStyle(
              color: theme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}