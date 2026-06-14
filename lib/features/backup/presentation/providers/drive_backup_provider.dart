/// Provider for the Google Drive backup service.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/drive_backup_service.dart';

final driveBackupServiceProvider = Provider<DriveBackupService>(
  (ref) => DriveBackupService.instance,
);
