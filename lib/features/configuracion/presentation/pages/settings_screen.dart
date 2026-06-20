import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'widgets/pin_setup_dialog.dart';
import '../../../../shared/widgets/input_decoration.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _vm;

  String _cacheSize = 'Calculando...';
  bool _isDark = false;
  String _moneda = 'CLP';
  bool _isDebug = false;
  bool _isPinEnabled = false;
  bool _isBiometricEnabled = false;
  final _ivaCtrl = TextEditingController();
  final _ivaFormKey = GlobalKey<FormState>();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _vm = sl<SettingsViewModel>();

    if (_vm.state.data == null) {
      _vm.loadSettings().then((_) => _initData());
    } else {
      _initData();
    }
  }

  void _initData() {
    final s = _vm.state.data;
    if (s != null && mounted) {
      setState(() {
        _isDark = s.isDarkMode;
        _moneda = s.moneda;
        _ivaCtrl.text = s.iva.toString();
        _isDebug = s.isDebugMode;
        _isPinEnabled = s.isPinEnabled;
        _isBiometricEnabled = s.isBiometricEnabled;
        _isInitialized = true;
      });

      _vm.getCacheSize().then((size) {
        if (mounted) setState(() => _cacheSize = size);
      });
    }
  }

  @override
  void dispose() {
    _ivaCtrl.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (!(_ivaFormKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El valor de IVA no es válido. Ingresa un número entre 0 y 100.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final double ivaDouble = double.parse(_ivaCtrl.text.trim());

    await _vm.saveAllSettings(
      isDark: _isDark,
      iva: ivaDouble,
      moneda: _moneda,
      isDebug: _isDebug,
      isPinEnabled: _isPinEnabled,
      isBiometricEnabled: _isBiometricEnabled,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuraciones guardadas exitosamente')),
      );
    }
  }

  void _showPinSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PinSetupDialog(
        onSave: (pin, q1, q2, q3) async {
          Navigator.pop(dialogContext);
          await _vm.setupPin(pin: pin, a1: q1, a2: q2, a3: q3);
          if (mounted) {
            setState(() {
              _isPinEnabled = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Seguridad PIN configurada. Presiona Guardar Cambios para aplicar.')),
            );
          }
        },
        onCancel: () {
          Navigator.pop(dialogContext);
          setState(() {
            _isPinEnabled = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/dashboard');
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
        onPressed: _guardarCambios,
        icon: const Icon(Icons.save),
        label: const Text('Guardar Cambios'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16).copyWith(bottom: 80),
        children: [
          const _SectionTitle(title: 'Apariencia'),
          SwitchListTile(
            title: const Text('Tema Oscuro'),
            subtitle: const Text('Ahorra batería en pantallas OLED'),
            value: _isDark,
            activeThumbColor: Theme.of(context).colorScheme.secondary,
            onChanged: (val) => setState(() => _isDark = val),
          ),
          const Divider(),

          const _SectionTitle(title: 'Cotizaciones'),
          ListTile(
            title: const Text('Moneda por defecto'),
            trailing: DropdownButton<String>(
              value: _moneda,
              items: const [
                DropdownMenuItem(value: 'CLP', child: Text('CLP (\$) ', style: TextStyle(fontSize: 14))),
                DropdownMenuItem(value: 'USD', child: Text('USD (\$US)', style: TextStyle(fontSize: 14))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _moneda = val);
              },
            ),
          ),
          Form(
            key: _ivaFormKey,
            child: ListTile(
              title: const Text('IVA (%)'),
              subtitle: const Text('Porcentaje a sumar en cotizaciones'),
              trailing: SizedBox(
                width: 80,
                child: TextFormField(
                  controller: _ivaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  textAlign: TextAlign.end,
                  decoration: AppInputDecoration.field(
                    label: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                  validator: (val) {
                    final v = double.tryParse(val?.trim() ?? '');
                    if (v == null) return 'Inválido';
                    if (v < 0 || v > 100) return '0-100';
                    return null;
                  },
                ),
              ),
            ),
          ),
          const Divider(),

          const _SectionTitle(title: 'Seguridad'),
          SwitchListTile(
            title: const Text('Bloqueo por PIN'),
            subtitle: const Text('Requerir PIN al abrir la aplicación'),
            value: _isPinEnabled,
            activeThumbColor: Theme.of(context).colorScheme.secondary,
            onChanged: (val) {
              if (val) {
                _showPinSetupDialog();
              } else {
                setState(() {
                  _isPinEnabled = false;
                  _isBiometricEnabled = false;
                });
              }
            },
          ),
          SwitchListTile(
            title: const Text('Desbloquear con Huella'),
            subtitle: const Text('Requiere tener el PIN configurado'),
            value: _isBiometricEnabled,
            activeThumbColor: Theme.of(context).colorScheme.secondary,
            onChanged: _isPinEnabled
                ? (val) => setState(() => _isBiometricEnabled = val)
                : null,
          ),
          const Divider(),

          const _SectionTitle(title: 'Avanzado'),
          ListTile(
            title: const Text('Respaldos y Exportación'),
            subtitle: const Text('Gestionar copias JSON y sincronización'),
            leading: const Icon(Icons.backup_rounded),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/backup');
            },
          ),
          ListTile(
            title: const Text('Limpiar caché de PDFs'),
            subtitle: Text('Libera $_cacheSize de espacio.\nSolo elimina documentos PDF generados temporalmente.'),
            isThreeLine: true,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            onTap: () async {
              await _vm.clearCache();
              final newSize = await _vm.getCacheSize();
              if (context.mounted) {
                setState(() => _cacheSize = newSize);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Documentos PDF temporales eliminados.')),
                );
              }
            },
          ),
        ],
      ),
    ));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}