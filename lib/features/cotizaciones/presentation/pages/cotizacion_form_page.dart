import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../viewmodels/cotizacion_form_viewmodel.dart';
import '../../domain/entities/material_item_entity.dart';
import '../../domain/entities/labor_item_entity.dart';
import '../../domain/entities/entidad_cotizacion.dart';

import '../../../clientes/domain/entities/client_entity.dart';
import '../../../clientes/domain/repositories/client_repository.dart';

import '../widgets/previsualizacion_cotizacion.dart';
import '../../domain/utils/motor_calculo.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../configuracion/presentation/viewmodels/settings_viewmodel.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class CotizacionFormPage extends StatefulWidget {
  final bool conCliente;
  final bool isEmbedded;
  final EntidadCotizacion? cotizacion;

  const CotizacionFormPage({
    super.key,
    this.conCliente = false,
    this.isEmbedded = false,
    this.cotizacion,
  });

  @override
  State<CotizacionFormPage> createState() => _CotizacionFormPageState();
}

class _CotizacionFormPageState extends State<CotizacionFormPage> {
  late final CotizacionFormViewModel vm;
  String? clienteIdSeleccionado;
  String? nombreClienteSeleccionado;

  @override
  void initState() {
    super.initState();
    vm = sl<CotizacionFormViewModel>();
    vm.isConCliente = widget.conCliente;

    if (widget.cotizacion != null) {
      vm.cargarCotizacion(widget.cotizacion!);
      if (widget.conCliente) {
        if (!widget.cotizacion!.clienteId.startsWith('sin-cliente-') && !widget.cotizacion!.clienteId.startsWith('rapida-')) {
          clienteIdSeleccionado = widget.cotizacion!.clienteId;
          nombreClienteSeleccionado = widget.cotizacion!.nombreCliente;
        }
      }
    }
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoracion(BuildContext context, String label, {String? errorText}) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: colors.surface,
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
    );
  }

  void _mostrarDialogoMaterial({MaterialItemEntity? materialEditando, int? index}) {
    final esEditando = materialEditando != null && index != null;
    final nombreController = TextEditingController(text: esEditando ? materialEditando.nombre : '');
    final cantidadController = TextEditingController(text: esEditando ? materialEditando.cantidad.toInt().toString() : '');
    final precioController = TextEditingController(text: esEditando ? materialEditando.precioUnitario.toInt().toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            esEditando ? 'Editar Material' : 'Agregar Material',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: _inputDecoracion(context, 'Nombre del Material'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoracion(context, 'Cantidad'),
                  validator: (val) => int.tryParse(val ?? '') == null || int.parse(val!) <= 0 ? 'Debe ser mayor a 0' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoracion(context, 'Precio Unitario (\$)'),
                  validator: (val) => int.tryParse(val ?? '') == null || int.parse(val!) <= 0 ? 'Debe ser mayor a 0' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (esEditando) {
                    vm.editarMaterial(index, nombreController.text.trim(), int.parse(cantidadController.text), int.parse(precioController.text));
                  } else {
                    vm.agregarMaterial(nombreController.text.trim(), int.parse(cantidadController.text), int.parse(precioController.text));
                  }
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                esEditando ? 'Guardar' : 'Agregar',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoLabor({LaborItemEntity? laborEditando, int? index}) {
    final esEditando = laborEditando != null && index != null;
    final cargoController = TextEditingController(text: esEditando ? laborEditando.cargo : '');
    final jornadaController = TextEditingController(text: esEditando ? laborEditando.valorJornada.toInt().toString() : '');
    final diasController = TextEditingController(text: esEditando ? laborEditando.dias.toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            esEditando ? 'Editar Mano de Obra' : 'Agregar Mano de Obra',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: cargoController,
                  decoration: _inputDecoracion(context, 'Cargo (Ej: Maestro, Ayudante...)'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un cargo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: jornadaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoracion(context, 'Valor Jornada / Día (\$)'),
                  validator: (val) => int.tryParse(val ?? '') == null || int.parse(val!) <= 0 ? 'Debe ser mayor a 0' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: diasController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoracion(context, 'Días de Trabajo'),
                  validator: (val) => int.tryParse(val ?? '') == null || int.parse(val!) <= 0 ? 'Debe ser mayor a 0' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (esEditando) {
                    vm.editarLabor(index, cargoController.text.trim(), int.parse(jornadaController.text), int.parse(diasController.text));
                  } else {
                    vm.agregarLabor(cargoController.text.trim(), int.parse(jornadaController.text), int.parse(diasController.text));
                  }
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                esEditando ? 'Guardar' : 'Agregar',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectorCliente(ColorScheme colors) {
    final clientRepo = sl<ClientRepository>();

    return StreamBuilder<List<ClientEntity>>(
      stream: clientRepo.watchClientes(),
      builder: (context, snapshot) {
        final clientes = snapshot.data ?? [];

        return Card(
          elevation: 0,
          color: colors.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Theme.of(context).colorScheme.primaryContainer, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Seleccionar Cliente',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (clientes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colors.onSurfaceVariant, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No tienes clientes registrados.',
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String?>(
                    initialValue: clientes.any((c) => c.id == clienteIdSeleccionado) ? clienteIdSeleccionado : null,
                    decoration: _inputDecoracion(context, 'Cliente'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Ninguno (Sin cliente asignado)'),
                      ),
                      ...clientes.map((c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text('${c.nombre} — ${c.rut}', overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val == null) {
                          clienteIdSeleccionado = null;
                          nombreClienteSeleccionado = null;
                          vm.setCliente('', '');
                        } else {
                          clienteIdSeleccionado = val;
                          final c = clientes.firstWhere((x) => x.id == val);
                          nombreClienteSeleccionado = c.nombre;
                          vm.setCliente(c.id, c.nombre);
                        }
                      });
                    },
                  ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/nuevo-cliente'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Crear nuevo cliente'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = sl<SettingsViewModel>().state.data;
    final moneda = settings?.moneda ?? 'CLP';

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.conCliente) ...[
            _buildSelectorCliente(colors),
            const SizedBox(height: 24),
          ],

          const Text('Tipo de Trabajo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          AnimatedBuilder(
            animation: vm,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: vm.opcionesTipoTrabajo.map((opcion) {
                      final isSelected = vm.tipoTrabajoNotifier.value.contains(opcion);
                      return FilterChip(
                        label: Text(opcion),
                        selected: isSelected,
                        onSelected: (_) => vm.toggleTipoTrabajo(opcion),
                        selectedColor: colors.primaryContainer,
                        checkmarkColor: colors.onPrimaryContainer,
                      );
                    }).toList(),
                  ),
                  if (vm.tipoTrabajoError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(vm.tipoTrabajoError!, style: TextStyle(color: colors.error, fontSize: 12)),
                    ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: vm.direccionController,
                    onChanged: vm.validarDireccion,
                    decoration: _inputDecoracion(context, 'Dirección de la Obra', errorText: vm.direccionError),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: vm.m2Controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    onChanged: vm.validarM2,
                    decoration: _inputDecoracion(context, 'Metros Cuadrados (m²)', errorText: vm.m2Error),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: vm.transportController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: vm.validarTransporte,
                    decoration: _inputDecoracion(context, 'Costo de Transporte / Flete (\$)', errorText: vm.transportError),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: vm.utilityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: vm.validarUtilidad,
                    decoration: _inputDecoracion(context, 'Porcentaje Utilidad (%)', errorText: vm.utilityError),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: vm.ivaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: vm.validarIva,
                    decoration: _inputDecoracion(context, 'Porcentaje IVA (%)', errorText: vm.ivaError),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Materiales de la Obra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              FilledButton.icon(
                onPressed: () => _mostrarDialogoMaterial(),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Material'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ValueListenableBuilder<List<MaterialItemEntity>>(
            valueListenable: vm.materialesNotifier,
            builder: (context, materiales, child) {
              if (materiales.isEmpty) {
                return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Center(child: Text('No se han agregado materiales.', style: TextStyle(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic))));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materiales.length,
                itemBuilder: (context, index) {
                  final mat = materiales[index];
                  return Card(
                    key: ValueKey('material_${mat.nombre}_$index'),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(mat.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${mat.cantidad.toInt()} und x ${CurrencyFormatter.format(mat.precioUnitario, moneda)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(CurrencyFormatter.format(mat.subtotal, moneda), style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(icon: Icon(Icons.edit, color: colors.primary, size: 20), onPressed: () => _mostrarDialogoMaterial(materialEditando: mat, index: index)),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Eliminar material'),
                                  content: Text('¿Deseas eliminar "${mat.nombre}" de la lista de materiales?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                        foregroundColor: Theme.of(context).colorScheme.onError,
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmar == true) vm.eliminarMaterial(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mano de Obra / Equipo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              FilledButton.icon(
                onPressed: () => _mostrarDialogoLabor(),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Mano Obra'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ValueListenableBuilder<List<LaborItemEntity>>(
            valueListenable: vm.manoDeObraNotifier,
            builder: (context, manoDeObra, child) {
              if (manoDeObra.isEmpty) {
                return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Center(child: Text('No se ha agregado personal de trabajo.', style: TextStyle(color: colors.onSurfaceVariant, fontStyle: FontStyle.italic))));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: manoDeObra.length,
                itemBuilder: (context, index) {
                  final lab = manoDeObra[index];
                  return Card(
                    key: ValueKey('labor_${lab.cargo}_$index'),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(lab.cargo, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${lab.dias} días x ${CurrencyFormatter.format(lab.valorJornada, moneda)} por día'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(CurrencyFormatter.format(lab.subtotal, moneda), style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(icon: Icon(Icons.edit, color: colors.primary, size: 20), onPressed: () => _mostrarDialogoLabor(laborEditando: lab, index: index)),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Eliminar mano de obra'),
                                  content: Text('¿Deseas eliminar "${lab.cargo}" de la lista de personal?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                        foregroundColor: Theme.of(context).colorScheme.onError,
                                      ),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmar == true) vm.eliminarLabor(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          ValueListenableBuilder<ResultadoCotizacion?>(
            valueListenable: vm.resultadoNotifier,
            builder: (context, resultado, child) {
              if (resultado == null) return const SizedBox.shrink();
              return PrevisualizacionCotizacion(resultado: resultado);
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar y Ver PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if (widget.conCliente && clienteIdSeleccionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Debes seleccionar un cliente para generar la cotización.'),
                      backgroundColor: colors.error,
                    ),
                  );
                  return;
                }

                final isFormularioValido = vm.validarFormulario();

                if (!isFormularioValido) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Por favor, completa todos los campos obligatorios marcados en rojo.'),
                      backgroundColor: colors.error,
                    ),
                  );
                  return;
                }

                if (!vm.esValidaParaGenerarPdf()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Faltan datos (verifica que el total de la cotización sea mayor a \$0).'),
                      backgroundColor: colors.error,
                    ),
                  );
                  return;
                }

                String cId = vm.clienteId;
                String cNombre = vm.nombreCliente;

                if (cId.isEmpty) {
                  cId = widget.conCliente
                      ? 'sin-cliente-${DateTime.now().millisecondsSinceEpoch}'
                      : 'rapida-${DateTime.now().millisecondsSinceEpoch}';
                }

                if (cNombre.isEmpty) {
                  cNombre = widget.conCliente ? 'Sin cliente asignado' : 'Cotización Rápida';
                }

                final finalId = widget.cotizacion?.id ??
                    (vm.id.isNotEmpty ? vm.id : 'COT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}');

                final cotizacionFinal = EntidadCotizacion(
                  id: finalId,
                  clienteId: cId,
                  nombreCliente: cNombre,
                  materials: vm.materiales,
                  labor: vm.manoDeObra,
                  metrosCuadrados: vm.m2,
                  direccion: vm.direccionController.text.trim(),
                  tipoTrabajo: vm.tipoTrabajoNotifier.value,
                  transport: vm.transport,
                  utility: vm.utility,
                  iva: vm.iva,
                  total: vm.total,
                  status: 'borrador',
                  version: (widget.cotizacion?.version ?? 0) + 1,
                  createdAt: widget.cotizacion?.createdAt ?? vm.createdAt ?? DateTime.now(),
                );

                await vm.guardarExplicitamente(cotizacionFinal);

                if (context.mounted) {
                  context.push('/pdf_preview', extra: cotizacionFinal);
                }
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return body;
    }

    return Scaffold(
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(widget.conCliente ? 'Nueva Cotización' : 'Cotización Rápida'),
      ),
      body: body,
    );
  }
}