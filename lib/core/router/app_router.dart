import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/pin_page.dart';
import '../../features/auth/presentation/pages/recover_pin_page.dart';

import '../../features/dashboard/dashboard.dart';

import '../../features/clientes/clientes.dart';
import '../../features/clientes/domain/entities/client_entity.dart';

import '../../features/cotizaciones/cotizaciones.dart';
import '../../features/cotizaciones/presentation/pages/cotizacion_form_page.dart';
import '../../features/cotizaciones/presentation/pages/vista_previa_pdf_page.dart';
import '../../features/cotizaciones/presentation/pages/historial_cotizaciones_page.dart';
import '../../features/cotizaciones/domain/entities/entidad_cotizacion.dart';
import '../../shared/widgets/app_scaffold.dart';

// 1. Mantenemos tu importación original y sumamos la de BackupPage
import '../../features/configuracion/presentation/pages/settings_screen.dart';
import '../../features/configuracion/presentation/backup_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/pin',
  routes: [
    GoRoute(
      path: '/pin',
      builder: (context, state) => const PinPage(),
    ),
    GoRoute(
      path: '/recover',
      builder: (context, state) => const RecoverPinPage(),
    ),
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return AppScaffold(
          currentLocation: state.uri.toString(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/clients',
          builder: (context, state) => const ClientsScreen(),
        ),
        GoRoute(
          path: '/quotes',
          builder: (context, state) => const QuotesScreen(),
        ),
        // 2. Restauramos tu pantalla original de settings en el menú principal
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/nueva-cotizacion',
      builder: (context, state) {
        if (state.extra is Map) {
          final extra = state.extra as Map;
          final cotizacion = extra['cotizacion'] as EntidadCotizacion?;
          final isRapida = extra['rapida'] as bool? ?? false;
          if (isRapida) {
            return QuotesScreen(cotizacion: cotizacion);
          } else {
            return CotizacionFormPage(conCliente: true, cotizacion: cotizacion);
          }
        }
        final conCliente = state.extra as bool? ?? false;
        return CotizacionFormPage(conCliente: conCliente);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/nuevo-cliente',
      name: 'nuevo-cliente',
      builder: (context, state) => const ClientFormPage(),
    ),
    
    // Editar cliente
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/editar-cliente',
      name: 'editar-cliente',
      builder: (context, state) {
        final cliente = state.extra as ClientEntity;
        return ClientFormPage(cliente: cliente);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/pdf_preview',
      builder: (context, state) {
        final cotizacion = state.extra as EntidadCotizacion;
        return VistaPreviaPdfPage(cotizacion: cotizacion);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/historial-cotizaciones',
      builder: (context, state) => const HistorialCotizacionesPage(),
    ),
    // 3. Añadimos la pantalla de respaldos como una ruta extra independiente
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/backup',
      builder: (context, state) => const BackupPage(),
    ),
  ],
);