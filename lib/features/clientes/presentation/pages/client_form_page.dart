import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/client_entity.dart';
import '../formatters/phone_input_formatter.dart';
import '../formatters/rut_input_formatter.dart';
import '../viewmodels/client_form_viewmodel.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/input_decoration.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class ClientFormPage extends StatefulWidget {
  final ClientEntity? cliente;

  const ClientFormPage({
    super.key,
    this.cliente,
  });

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  late final ClientFormViewModel vm;

  @override
  void initState() {
    super.initState();

    vm = sl<ClientFormViewModel>();

    if (widget.cliente != null) {
      vm.cargarClienteParaEditar(
        widget.cliente!,
      );
    }

    vm.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>();

    return Scaffold(
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          widget.cliente != null ? 'Editar Cliente' : 'Nuevo Cliente',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete la información del cliente',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    TextField(
                      controller: vm.nombreController,
                      onChanged: vm.validarNombre,
                      decoration: AppInputDecoration.field(
                        label: 'Nombre',
                        errorText: vm.nombreError,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: vm.rutController,
                      enabled: !vm.modoEdicion,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            r'[0-9kK.]',
                          ),
                        ),
                        RutInputFormatter(),
                      ],
                      onChanged: vm.onRutChanged,
                      decoration: AppInputDecoration.field(
                        label: 'RUT',
                        hintText: '12.345.678-5',
                        errorText: vm.rutError,
                        suffixIcon: vm.clienteAutocompletado &&
                            !vm.clienteEliminado
                            ? Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                        )
                            : (vm.clienteEliminado
                            ? Icon(
                          Icons.warning_amber_rounded,
                          color: appColors?.warning,
                        )
                            : null),
                      ),
                    ),
                    if (vm.clienteAutocompletado || vm.clienteEliminado)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: vm.clienteEliminado
                                ? colorScheme.tertiary.withValues(alpha: 0.3)
                                : colorScheme.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                vm.mensajeIcono,
                                size: 16,
                                color: vm.clienteEliminado
                                    ? appColors?.warning
                                    : colorScheme.secondary,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  vm.mensajeTexto,
                                  style: TextStyle(
                                    color: vm.clienteEliminado
                                        ? appColors?.warning
                                        : colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: vm.telefonoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        PhoneInputFormatter(),
                      ],
                      onChanged: vm.validarTelefono,
                      decoration: AppInputDecoration.field(
                        label: 'Teléfono',
                        hintText: '+56 9 1234 5678',
                        errorText: vm.telefonoError,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: vm.correoController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: vm.validarCorreo,
                      decoration: AppInputDecoration.field(
                        label: 'Correo',
                        errorText: vm.correoError,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: vm.loading
                            ? null
                            : () async {
                          if (vm.nombreController.text.trim().isEmpty &&
                              vm.rutController.text.trim().isEmpty &&
                              vm.telefonoController.text.trim().isEmpty &&
                              vm.correoController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'No se ha ingresado ningún dato',
                                ),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                            return;
                          }

                          final guardadoExitoso = await vm.guardar();

                          if (guardadoExitoso && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Cliente guardado correctamente',
                                ),
                                backgroundColor: colorScheme.primary,
                              ),
                            );
                            context.pop();
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Por favor, corrija los errores en el formulario',
                                ),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        },
                        icon: vm.loading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                            : Icon(
                          vm.botonIcono,
                        ),
                        label: Text(
                          vm.botonTexto,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}