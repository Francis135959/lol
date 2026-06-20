import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/state/base_state.dart';
import '../viewmodels/recover_pin_viewmodel.dart';
import '../../../configuracion/presentation/viewmodels/settings_viewmodel.dart';
import '../../../../shared/widgets/input_decoration.dart';

class RecoverPinPage extends StatefulWidget {
  const RecoverPinPage({super.key});

  @override
  State<RecoverPinPage> createState() => _RecoverPinPageState();
}

class _RecoverPinPageState extends State<RecoverPinPage> {
  late final RecoverPinViewModel _vm;

  final a1 = TextEditingController();
  final a2 = TextEditingController();
  final a3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = sl<RecoverPinViewModel>();
    // Cambiamos el Listener para que ejecute nuestra lógica de validación
    _vm.addListener(_onStateChanged);
  }

  void _onStateChanged() async {
    // Forzamos un redibujado de la pantalla para mostrar/ocultar el "cargando"
    setState(() {});

    final state = _vm.state;
    
    // Si las respuestas fueron correctas
    if (state.status == ViewState.success) {
      final settingsVm = sl<SettingsViewModel>();
      final current = settingsVm.state.data;
      
      // 1. Guardamos la configuración con el PIN DESACTIVADO
      if (current != null) {
        await settingsVm.saveAllSettings(
          isDark: current.isDarkMode,
          iva: current.iva,
          moneda: current.moneda,
          isDebug: current.isDebugMode,
          isPinEnabled: false,
          isBiometricEnabled: false,
        );
      }
      
      // 2. Lanzamos un mensaje y saltamos al Dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Identidad verificada. Se desactivó el PIN por seguridad.'),
          ),
        );
        context.go('/dashboard');
      }
    }
  }

  @override
  void dispose() {
    a1.dispose();
    a2.dispose();
    a3.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _vm.state;

    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'Para recuperar tu PIN, responde correctamente a tus preguntas de seguridad o contacta al administrador del sistema.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
            ),
            const Text("1. Nombre de su primera mascota"),
            const SizedBox(height: 8),
            TextField(controller: a1, decoration: const InputDecoration(border: OutlineInputBorder())),

            const SizedBox(height: 12),

            const Text("2. Año de nacimiento de su madre"),
            const SizedBox(height: 8),
            TextField(controller: a2, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder())),

            const SizedBox(height: 12),

            const Text("3. Ciudad donde nació su padre"),
            const SizedBox(height: 8),
            TextField(controller: a3, decoration: const InputDecoration(border: OutlineInputBorder())),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.status == ViewState.loading
                    ? null
                    : () {
                        _vm.verifyAnswers(
                          a1: a1.text,
                          a2: a2.text,
                          a3: a3.text,
                        );
                      },
                child: state.status == ViewState.loading
                    ? const CircularProgressIndicator()
                    : const Text("Validar"),
              ),
            ),

            const SizedBox(height: 20),

            if (state.status == ViewState.error)
              Text(
                state.message ?? "",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}
