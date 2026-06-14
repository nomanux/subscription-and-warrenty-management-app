/// Backup & Restore screen — export warranty data as CSV.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../theme.dart';
import '../../services/backup_service.dart';
import '../providers/drive_backup_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;
  bool _importing = false;
  bool _backingUp = false;
  bool _restoring = false;
  DateTime? _lastBackup;

  @override
  void initState() {
    super.initState();
    _loadLastBackup();
  }

  Future<void> _loadLastBackup() async {
    final time = await ref.read(driveBackupServiceProvider).lastBackup();
    if (mounted) setState(() => _lastBackup = time);
  }

  Future<void> _driveBackup() async {
    setState(() => _backingUp = true);
    try {
      final name = await ref.read(driveBackupServiceProvider).backupNow();
      if (!mounted) return;
      _showSuccess('✓ Backed up to Google Drive ($name)');
      await _loadLastBackup();
    } catch (e) {
      debugPrint('DRIVE_BACKUP_ERROR: $e');
      if (!mounted) return;
      _showError('Backup failed: $e');
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  Future<void> _driveRestore() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from Google Drive?'),
        content: const Text(
          'This loads your most recent Drive backup and merges it into your '
          'warranties (matching items are overwritten).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _restoring = true);
    try {
      final count = await ref.read(driveBackupServiceProvider).restoreLatest();
      if (!mounted) return;
      _showSuccess('✓ Restored $count warranties from Google Drive');
    } catch (e) {
      debugPrint('DRIVE_RESTORE_ERROR: $e');
      if (!mounted) return;
      _showError('Restore failed: $e');
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  String _formatTime(DateTime time) {
    final t = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}';
  }

  Widget _buildDriveCard() {
    final busy = _backingUp || _restoring;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.cloud_outlined, color: kPrimary, size: 24),
            const SizedBox(width: 12),
            const Text('Google Drive Backup',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: kInk)),
          ]),
          const SizedBox(height: 8),
          const Text(
            'Back up all your warranties to Google Drive. '
            'Automatic daily backup on app open.',
            style: TextStyle(color: kMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy ? null : _driveBackup,
              icon: _backingUp
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.backup),
              label: Text(_backingUp ? 'Backing up…' : 'Back up now'),
              style: FilledButton.styleFrom(backgroundColor: kPrimary),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy ? null : _driveRestore,
              icon: _restoring
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.restore),
              label: Text(_restoring ? 'Restoring…' : 'Restore from Drive'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _lastBackup == null
                ? 'Not backed up yet'
                : 'Last backed up: ${_formatTime(_lastBackup!)}',
            style: const TextStyle(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _importData() async {
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      final path = result?.files.single.path;
      if (path == null) return; // cancelled

      final service = BackupService(ref.read(appDatabaseProvider));
      await service.importFromCSV(path);
      if (!mounted) return;
      _showSuccess('✓ Imported warranties from CSV.');
    } catch (e) {
      if (!mounted) return;
      _showError('Import failed: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      // Need "All files access" to write to a visible shared folder.
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      if (!status.isGranted) {
        if (!mounted) return;
        _showError('Enable "All files access" to save the export.');
        await openAppSettings();
        return;
      }

      final service = BackupService(ref.read(appDatabaseProvider));
      final filePath = await service.exportToCSV();
      if (!mounted) return;
      _showSuccess('✓ Saved to: $filePath');
    } catch (e) {
      if (!mounted) return;
      _showError('Export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(backgroundColor: kSurface, title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDriveCard(),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.download, color: kPrimary, size: 24),
                  const SizedBox(width: 12),
                  const Text('Export Data to CSV',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kInk)),
                ]),
                const SizedBox(height: 8),
                const Text(
                  'Exports all your warranties to a CSV file that you can download and save.',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _exporting ? null : _exportData,
                    icon: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download),
                    label: Text(_exporting ? 'Exporting…' : 'Export to CSV'),
                    style: FilledButton.styleFrom(backgroundColor: kPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.upload_file, color: kPrimary, size: 24),
                  const SizedBox(width: 12),
                  const Text('Import Data from CSV',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kInk)),
                ]),
                const SizedBox(height: 8),
                const Text(
                  'Pick a CSV file (same format as the export) to add those '
                  'warranties to your vault.',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _importing ? null : _importData,
                    icon: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_file),
                    label: Text(_importing ? 'Importing…' : 'Import from CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}
