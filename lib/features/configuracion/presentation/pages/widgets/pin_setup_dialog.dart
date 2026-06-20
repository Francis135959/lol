import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../shared/widgets/input_decoration.dart';

class PinSetupDialog extends StatefulWidget {
  final Function(String pin, String q1, String q2, String q3) onSave;
  final VoidCallback onCancel;

  const PinSetupDialog({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  final _pinCtrl = TextEditingController();
  final _q1Ctrl = TextEditingController();
  final _q2Ctrl = TextEditingController();
  final _q3Ctrl = TextEditingController();

  bool get isValid {
    return _pinCtrl.text.length == 4 &&
        _q1Ctrl.text.trim().isNotEmpty &&
        _q2Ctrl.text.trim().isNotEmpty &&
        _q3Ctrl.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configurar PIN de Seguridad"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ingrese un PIN de 4 dígitos:"),
            const SizedBox(height: 8),
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: AppInputDecoration.pin(),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text("Preguntas de recuperación:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _q1Ctrl,
              decoration: AppInputDecoration.dialog(label: '1. Nombre de su primera mascota'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _q2Ctrl,
              decoration: AppInputDecoration.dialog(label: '2. Año de nacimiento de su madre'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _q3Ctrl,
              decoration: AppInputDecoration.dialog(label: '3. Ciudad donde nació su padre'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: isValid
              ? () {
                  widget.onSave(
                    _pinCtrl.text,
                    _q1Ctrl.text,
                    _q2Ctrl.text,
                    _q3Ctrl.text,
                  );
                }
              : null,
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
