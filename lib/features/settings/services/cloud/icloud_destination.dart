import 'dart:typed_data';
import '../backup_destination.dart';

/// Placeholder for the iOS / macOS iCloud Drive backup destination.
///
/// Not implemented yet. Adding it requires, at minimum:
///   1. Enabling the **iCloud (Documents)** capability in Xcode for the
///      Runner target, with a `iCloud.<bundle-id>` container identifier.
///   2. A Flutter plugin like `icloud_storage` (or a custom platform channel)
///      to enumerate / read / write files inside the ubiquity container.
///   3. Wiring this class' methods through that plugin.
///
/// Until then, the chooser shows it as "demnächst verfügbar" on iOS and hides
/// it elsewhere. Calling any method here throws.
class ICloudDestination extends BackupDestination {
  @override
  DestinationKind get kind => DestinationKind.iCloud;

  @override
  String get displayLabel => 'iCloud Drive';

  @override
  String get pathOrUri => 'icloud://';

  @override
  Future<String?> verifyAccess() async =>
      'iCloud-Backup ist in dieser Version noch nicht aktiv.';

  @override
  Future<void> writeBackup(String fileName, Uint8List bytes) =>
      throw UnimplementedError('iCloud-Backup nicht implementiert.');

  @override
  Future<List<BackupFile>> listBackups() async => const [];

  @override
  Future<Uint8List> readBackup(BackupFile file) =>
      throw UnimplementedError('iCloud-Backup nicht implementiert.');

  @override
  Future<void> deleteBackup(BackupFile file) =>
      throw UnimplementedError('iCloud-Backup nicht implementiert.');
}
