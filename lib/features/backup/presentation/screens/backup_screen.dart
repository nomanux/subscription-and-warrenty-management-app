/// Backup & Restore screen — export warranty data as CSV.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../theme.dart';
import '../../services/backup_service.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;

  Future<void> _exportData() async {
    try {
      setState(() => _exporting = true);
      _showSuccess('Starting export...');

      final db = ref.read(appDatabaseProvider);
      final service = BackupService(db);

      final filePath = await service.exportToCSV();
      if (!mounted) return;
      _showSuccess('✓ CSV saved to: $filePath');
    } catch (e, st) {
      if (!mounted) return;
      print('Export error: $e');
      print('Stack: $st');
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
