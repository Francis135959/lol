import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/connectivity_banner.dart';

class NavigationItem {
  final String location;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationItem({
    required this.location,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

const List<NavigationItem> _navItems = [
  NavigationItem(
    location: '/dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    label: 'Dashboard',
  ),
  NavigationItem(
    location: '/clients',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    label: 'Clientes',
  ),
  NavigationItem(
    location: '/quotes',
    icon: Icons.request_quote_outlined,
    selectedIcon: Icons.request_quote,
    label: 'Cotizaciones',
  ),
  NavigationItem(
    location: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Configuración',
  ),
];

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  int _calculateSelectedIndex(String location) {
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].location)) {
        return i;
      }
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    context.go(_navItems[index].location);
  }

  String _getAppBarTitle(String location) {
    if (location.startsWith('/dashboard')) return 'Dashboard';
    if (location.startsWith('/clients')) return 'Listado de clientes';
    if (location.startsWith('/quotes')) return 'Cotización Rápida';
    if (location.startsWith('/settings')) return 'Configuración';
    return 'Gestión de cotizaciones';
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(currentLocation);
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isMobile && !currentLocation.startsWith('/clients')
          ? AppBar(
        title: Text(_getAppBarTitle(currentLocation)),
      )
          : null,
      drawer: isMobile
          ? AppDrawer(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => _onItemTapped(index, context),
      )
          : null,
      body: SafeArea(
        top: !(isMobile && currentLocation.startsWith('/clients')),
        child: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(
              child: Row(
                children: [
                  if (!isMobile)
                    _AppNavigationRail(
                      selectedIndex: selectedIndex,
                      onItemTapped: (index) => _onItemTapped(index, context),
                    ),
                  if (!isMobile)
                    const VerticalDivider(
                      thickness: 1,
                      width: 1,
                    ),
                  Expanded(
                    child: child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colors.primary,
            ),
            child: Text(
              'Menú Principal',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ...List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final bool isSelected = index == selectedIndex;

            if (index == 1) {
              return ExpansionTile(
                iconColor: colors.secondary,
                textColor: colors.secondary,
                collapsedIconColor: isSelected ? colors.secondary : null,
                collapsedTextColor: isSelected ? colors.secondary : null,
                leading: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected ? colors.secondary : null,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? colors.secondary : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                childrenPadding: const EdgeInsets.only(left: 16),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add_outlined),
                    title: const Text('Crear Cliente'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/nuevo-cliente');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Ver Clientes'),
                    onTap: () {
                      Navigator.pop(context);
                      onItemTapped(index);
                    },
                  ),
                ],
              );
            }

            if (index == 2) {
              return ExpansionTile(
                iconColor: colors.secondary,
                textColor: colors.secondary,
                collapsedIconColor: isSelected ? colors.secondary : null,
                collapsedTextColor: isSelected ? colors.secondary : null,
                leading: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected ? colors.secondary : null,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? colors.secondary : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                childrenPadding: const EdgeInsets.only(left: 16),
                children: [
                  ListTile(
                    leading: const Icon(Icons.flash_on_outlined),
                    title: const Text('Cotización Rápida'),
                    onTap: () {
                      Navigator.pop(context);
                      onItemTapped(index);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Crear Cotización'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/nueva-cotizacion', extra: true);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Ver Cotizaciones'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/historial-cotizaciones');
                    },
                  ),
                ],
              );
            }

            return ListTile(
              leading: Icon(isSelected ? item.selectedIcon : item.icon),
              title: Text(item.label),
              selected: isSelected,
              selectedColor: colors.secondary,
              onTap: () {
                Navigator.pop(context);
                onItemTapped(index);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _AppNavigationRail({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  void _mostrarSubmenu(BuildContext context, GlobalKey key, List<PopupMenuEntry<String>> items, void Function(String) onSelected) {
    final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width,
        offset.dy,
        offset.dx + size.width + 200,
        offset.dy + size.height,
      ),
      items: items,
    ).then((value) {
      if (value != null) onSelected(value);
    });
  }

  void _mostrarSubmenuClientes(BuildContext context, GlobalKey key) {
    _mostrarSubmenu(context, key, [
      const PopupMenuItem(
        value: 'crear',
        child: ListTile(
          leading: Icon(Icons.person_add_outlined),
          title: Text('Crear Cliente'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'ver',
        child: ListTile(
          leading: Icon(Icons.people_outline),
          title: Text('Ver Clientes'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ], (value) {
      switch (value) {
        case 'ver':
          onItemTapped(1);
          break;
        case 'crear':
          context.push('/nuevo-cliente');
          break;
      }
    });
  }

  void _mostrarSubmenuCotizaciones(BuildContext context, GlobalKey key) {
    _mostrarSubmenu(context, key, [
      const PopupMenuItem(
        value: 'rapida',
        child: ListTile(
          leading: Icon(Icons.flash_on_outlined),
          title: Text('Cotización Rápida'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'nueva',
        child: ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text('Crear Cotización'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'historial',
        child: ListTile(
          leading: Icon(Icons.history),
          title: Text('Ver Cotizaciones'),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ], (value) {
      switch (value) {
        case 'nueva':
          context.push('/nueva-cotizacion', extra: true);
          break;
        case 'rapida':
          onItemTapped(2);
          break;
        case 'historial':
          context.push('/historial-cotizaciones');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey clientesKey = GlobalKey();
    final GlobalKey cotizacionesKey = GlobalKey();

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == 1) {
          _mostrarSubmenuClientes(context, clientesKey);
        } else if (index == 2) {
          _mostrarSubmenuCotizaciones(context, cotizacionesKey);
        } else {
          onItemTapped(index);
        }
      },
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.secondary,
      ),
      selectedLabelTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      destinations: _navItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        if (index == 1 || index == 2) {
          final key = index == 1 ? clientesKey : cotizacionesKey;
          return NavigationRailDestination(
            icon: Icon(item.icon, key: key),
            selectedIcon: Icon(item.selectedIcon),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.label),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_right, size: 16),
              ],
            ),
          );
        }

        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: Text(item.label),
        );
      }).toList(),
    );
  }
}