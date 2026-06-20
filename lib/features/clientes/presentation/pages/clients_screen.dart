import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/base_state.dart';
import '../../../../core/di/injection.dart';

import '../viewmodels/clientes_paginados_viewmodel.dart';
import '../widgets/client_card.dart';
import '../widgets/empty_clients.dart';
import '../widgets/client_search_bar.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../utils/client_validators.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late final ClientesPaginadosViewModel viewModel;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';
  final Set<String> clientesSeleccionados = {};
  String? activeMenuId;

  bool get modoSeleccion => clientesSeleccionados.isNotEmpty;

  @override
  void initState() {
    super.initState();
    viewModel = sl<ClientesPaginadosViewModel>();
    searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    viewModel.addListener(_onViewModelChanged);
    viewModel.cargarInicial();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (activeMenuId != null) {
      setState(() => activeMenuId = null);
    }
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!viewModel.isLoading && viewModel.hasMore && position.pixels >= position.maxScrollExtent - 300) {
      viewModel.cargarMas();
    }
  }

  void _onSearchChanged() {
    setState(() => searchQuery = searchController.text.trim().toLowerCase());
  }

  void _toggleSeleccion(String id) {
    setState(() {
      if (clientesSeleccionados.contains(id)) {
        clientesSeleccionados.remove(id);
      } else {
        clientesSeleccionados.add(id);
      }
      activeMenuId = null;
    });
  }

  void _limpiarSeleccion() {
    setState(() => clientesSeleccionados.clear());
  }

  void _seleccionarTodos(List<dynamic> clientesMostrados) {
    setState(() {
      for (final cliente in clientesMostrados) {
        clientesSeleccionados.add(cliente.id);
      }
    });
  }

  Future<void> _eliminarSeleccionados() async {
    final cantidad = clientesSeleccionados.length;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar clientes'),
        content: Text('¿Eliminar $cantidad cliente${cantidad == 1 ? '' : 's'} seleccionado${cantidad == 1 ? '' : 's'}?\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final idsAEliminar = Set<String>.from(clientesSeleccionados);
    int eliminados = 0;
    final List<String> fallidos = [];

    for (final id in idsAEliminar) {
      try {
        await viewModel.eliminarCliente(id);
        eliminados++;
      } catch (_) {
        fallidos.add(id);
      }
    }

    _limpiarSeleccion();
    await viewModel.refrescar();

    if (!mounted) return;

    if (fallidos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$eliminados cliente${eliminados == 1 ? '' : 's'} eliminado${eliminados == 1 ? '' : 's'} correctamente.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$eliminados eliminado${eliminados == 1 ? '' : 's'}. ${fallidos.length} no pudo${fallidos.length == 1 ? '' : 'n'} eliminarse.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = viewModel.state;
    final clientes = state.data ?? [];

    final queryNormalizado = ClientValidators.normalizarRut(searchQuery);
    final clientesMostrar = searchQuery.isEmpty
        ? clientes
        : clientes.where((c) {
            final nombreCoincide = c.nombre.toLowerCase().contains(searchQuery);
            final rutNormalizado = ClientValidators.normalizarRut(c.rut);
            final rutCoincide = rutNormalizado.contains(queryNormalizado) ||
                c.rut.toLowerCase().contains(searchQuery);
            return nombreCoincide || rutCoincide;
          }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (modoSeleccion) {
          _limpiarSeleccion();
        } else {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: AppDrawer(
          selectedIndex: 1,
          onItemTapped: (index) {
            final routes = ['/dashboard', '/clients', '/quotes', '/settings'];
            if (index >= 0 && index < routes.length) {
              context.go(routes[index]);
            }
          },
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: modoSeleccion
              ? null
              : Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
          title: Text(
            modoSeleccion
                ? '${clientesSeleccionados.length} seleccionados'
                : 'Listado de Clientes',
          ),
          centerTitle: true,
          actions: modoSeleccion
              ? [
            IconButton(icon: const Icon(Icons.delete), onPressed: _eliminarSeleccionados),
            IconButton(icon: const Icon(Icons.close), onPressed: _limpiarSeleccion),
          ]
              : null,
        ),
        floatingActionButton: modoSeleccion ? null : FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/nuevo-cliente');
            if (mounted) await viewModel.refrescar();
          },
          label: const Text('Nuevo cliente'),
          icon: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            ClientSearchBar(controller: searchController, onChanged: (v) => setState(() => searchQuery = v)),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.status == ViewState.loading && clientes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == ViewState.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                            const SizedBox(height: 16),
                            Text(
                              'Ocurrió un problema:\n${state.message}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonal(
                              onPressed: viewModel.refrescar,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (clientesMostrar.isEmpty) {
                    return const EmptyClients();
                  }

                  return Column(
                    children: [
                      if (!modoSeleccion)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: TextButton.icon(
                              icon: const Icon(Icons.select_all, size: 18),
                              label: const Text('Seleccionar todos'),
                              onPressed: () => _seleccionarTodos(clientesMostrar),
                            ),
                          ),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: viewModel.refrescar,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: clientesMostrar.length + (viewModel.hasMore && viewModel.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= clientesMostrar.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final cliente = clientesMostrar[index];
                        final selected = clientesSeleccionados.contains(cliente.id);

                        return GestureDetector(
                          onLongPress: () => _toggleSeleccion(cliente.id),
                          onTap: () {
                            if (activeMenuId != null) {
                              setState(() => activeMenuId = null);
                              return;
                            }
                            if (modoSeleccion) _toggleSeleccion(cliente.id);
                          },
                          child: Stack(
                            children: [
                              Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ClientCard(
                                  cliente: cliente,
                                  isMenuOpen: activeMenuId == cliente.id,
                                  onToggleMenu: () => setState(() => activeMenuId = (activeMenuId == cliente.id) ? null : cliente.id),
                                  onEdit: () async {
                                    setState(() => activeMenuId = null);
                                    await context.push('/editar-cliente', extra: cliente);
                                    if (mounted) await viewModel.refrescar();
                                  },
                                  onDelete: () async {
                                    setState(() => activeMenuId = null);

                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Eliminar cliente'),
                                        content: Text('¿Está seguro que desea eliminar a ${cliente.nombre} de forma permanente?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogContext, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: colorScheme.error,
                                              foregroundColor: colorScheme.onError,
                                            ),
                                            onPressed: () => Navigator.pop(dialogContext, true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmar == true) {
                                      await viewModel.eliminarCliente(cliente.id);
                                    }
                                  },
                                ),
                              ),
                              if (selected)
                                Positioned.fill(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: colorScheme.primary, width: 2),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(Icons.check_circle, color: colorScheme.primary),
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
                ),
              ],
            );
          },
          ),
        ),
          ],
        ),
      ),
    );
  }
}