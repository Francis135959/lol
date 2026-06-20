import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../services/backup_service.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late final BackupService _backupService;

  bool _isExporting = false;
  bool _isRestoring = false;
  bool _isSyncing = false;

  int? _ultimosSincronizados;

  @override
  void initState() {
    super.initState();
    _backupService = sl<BackupService>();
  }

  Future<void> _exportarBackup() async {
    final nombreIngresado = await _mostrarDialogoNombreArchivo();

    if (nombreIngresado == null) return;

    setState(() => _isExporting = true);

    try {
      final rutaGuardada = nombreIngresado.trim().isEmpty
          ? await _backupService.exportarListaAJson()
          : await _backupService.exportarListaAJsonConNombre(
              nombreIngresado.trim(),
            );

      if (!mounted) return;

      if (rutaGuardada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exportación cancelada.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup guardado en:\n$rutaGuardada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<String?> _mostrarDialogoNombreArchivo() async {
    final controller = TextEditingController(
      text: _backupService.defaultFileName(),
    );

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nombre del archivo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre del archivo (.json)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Seleccionar carpeta'),
          ),
        ],
      ),
    );
  }

  Future<void> _restaurarBackup() async {
    setState(() => _isRestoring = true);

    try {
      final totalRestaurados =
          await _backupService.restaurarDesdeSelector();

      if (!mounted) return;

      if (totalRestaurados == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restauración cancelada.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Restauración exitosa: $totalRestaurados registros recuperados.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _sincronizarNube() async {
    setState(() => _isSyncing = true);
    try {
      final totalSincronizados =
          await _backupService.sincronizarFirestoreVerificable();

      if (!mounted) return;

      setState(() => _ultimosSincronizados = totalSincronizados);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sincronización completa: $totalSincronizados registros subidos.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  bool get _busy => _isExporting || _isRestoring || _isSyncing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Respaldos y Exportación'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Gestiona tus respaldos locales y sincronización en la nube.',
              style: TextStyle(fontSize: 14, color: theme.onSurface),
            ),
          ),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: theme.secondary,
                child: _isExporting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.onSecondary,
                        ),
                      )
                    : Icon(Icons.download, color: theme.onSecondary),
              ),
              title: const Text(
                'Exportar Backup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Elige la carpeta y el nombre del archivo de destino.',
              ),
              onTap: _busy ? null : _exportarBackup,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: theme.secondary,
                child: _isRestoring
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.onSecondary,
                        ),
                      )
                    : Icon(Icons.restore, color: theme.onSecondary),
              ),
              title: const Text(
                'Restaurar Backup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Selecciona un archivo de backup (.json) para restaurar.',
              ),
              onTap: _busy ? null : _restaurarBackup,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: theme.secondary,
                child: _isSyncing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.onSecondary,
                        ),
                      )
                    : Icon(Icons.cloud_sync, color: theme.onSecondary),
              ),
              title: const Text(
                'Sincronizar con Firestore',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _ultimosSincronizados != null
                    ? 'Última sincronización: $_ultimosSincronizados registros.'
                    : 'Sube datos locales a la nube de forma secuencial.',
              ),
              onTap: _busy ? null : _sincronizarNube,
            ),
          ),
        ],
      ),
    );
  }
}