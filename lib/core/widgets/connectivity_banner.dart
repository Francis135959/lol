import 'package:flutter/material.dart';

import '../di/injection.dart';

import '../services/connectivity_service.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = sl<ConnectivityService>();
    final theme = Theme.of(context);
    
    return ValueListenableBuilder(
      valueListenable: connectivityService.statusNotifier,
      builder: (context, status, child) {
        if (status == EstadoConexion.online) {
          return const SizedBox.shrink();
        }
        Color color;
        Color contentColor;
        String text;
        IconData icon;

        switch (status) {
          case EstadoConexion.offline:
            color = theme.colorScheme.error;
            contentColor = theme.colorScheme.onError;
            text = 'Sin conexión';
            icon = Icons.wifi_off;
            break;
          case EstadoConexion.syncing:
            color = theme.colorScheme.primaryContainer;
            contentColor = theme.colorScheme.onPrimaryContainer;
            text = 'Sincronizando...';
            icon = Icons.sync;
            break;
          case EstadoConexion.online:
            return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: contentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(color: contentColor, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        );
      }
    );
  }
}