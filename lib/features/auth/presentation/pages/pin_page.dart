import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/state/base_state.dart';

import '../viewmodels/pin_viewmodel.dart';

import '../../../../shared/widgets/input_decoration.dart';
import '../../data/datasources/pin_security_service.dart';
import '../../../configuracion/presentation/viewmodels/settings_viewmodel.dart';
import 'package:local_auth/local_auth.dart';

class PinPage extends StatefulWidget {
  const PinPage({super.key});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  late final PinViewModel _viewModel;
  late final SettingsViewModel _settingsVm;

  final TextEditingController _pinController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();

    _viewModel = sl<PinViewModel>();
    _settingsVm = sl<SettingsViewModel>();

    _viewModel.addListener(_onStateChanged);
  }

  Future<void> _checkBiometrics() async {
    if (_isAuthenticating) return;
    
    final settings = _settingsVm.state.data;
    if (settings != null && settings.isBiometricEnabled && settings.isPinEnabled) {
      try {
        _isAuthenticating = true;
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'Por favor, autentícate para acceder',
          biometricOnly: true,
        );
        _isAuthenticating = false;
        if (didAuthenticate) {
          _viewModel.setSuccess(true);
        }
      } catch (e) {
        _isAuthenticating = false;
      }
    }
  }

  void _onStateChanged() {
    final state = _viewModel.state;

    if (state.status == ViewState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( 
          content: const Text('Acceso concedido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).colorScheme.primary, 
        ),
      );

      context.go('/dashboard');
    }

    if (state.status == ViewState.error && state.message != null) {
      _pinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _viewModel.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsVm,
      builder: (context, _) {
        final settings = _settingsVm.state.data;
        final isPinEnabled = settings?.isPinEnabled ?? true;

        if (!isPinEnabled) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/dashboard');
            }
          });
          return const Scaffold();
        }

        return FutureBuilder<bool>(
          future: sl<PinSecurityService>().hasPinConfigured(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final hasPin = snapshot.data ?? false;

            if (!hasPin) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go('/dashboard');
                }
              });
              return const Scaffold();
            }

            final colors = Theme.of(context).colorScheme;
            final state = _viewModel.state;

            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, _) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: colors.primary.withAlpha(30),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 40,
                                  color: colors.primary,
                                ),
                              ),

                              const SizedBox(height: 24),

                              Text(
                                'Acceso seguro',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                settings?.isBiometricEnabled == true 
                                  ? 'Ingresa tu PIN de 4 dígitos o usa tu huella'
                                  : 'Ingresa tu PIN de 4 dígitos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.onSurface.withOpacity(0.6), 
                                ),
                              ),

                              const SizedBox(height: 32),

                              TextField(
                                controller: _pinController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                obscuringCharacter: '●',
                                maxLength: 4,
                                enabled: state.status != ViewState.loading,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30,
                                  letterSpacing: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (val) {
                                  if (val.length == 4) {
                                    _viewModel.executeLogin(val);
                                  }
                                },
                                decoration: AppInputDecoration.pin(
                                  hintText: '••••',
                                  errorText: state.status == ViewState.error ? state.message : null,
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.status == ViewState.loading
                                      ? null
                                      : () {
                                          _viewModel.executeLogin(_pinController.text);
                                        },
                                  child: state.status == ViewState.loading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Ingresar'),
                                ),
                              ),

                              const SizedBox(height: 12),

                              if (settings?.isBiometricEnabled == true) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _isAuthenticating ? null : _checkBiometrics,
                                    icon: const Icon(Icons.fingerprint, size: 24),
                                    label: const Text('Usar Huella'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Text(
                                  'Si olvidaste tu PIN, toca la opción de abajo o contacta al administrador del sistema.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant.withOpacity(0.8),
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  context.push('/recover');
                                },
                                child: const Text(
                                  '¿Olvidaste tu PIN?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}