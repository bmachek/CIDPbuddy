import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:developer' as dev;
import '../backup_destination.dart';

/// Backup destination that stores ZIPs in the app's iCloud Documents container.
/// Files are visible in Files.app under the app's iCloud folder.
///
/// SETUP (required in Xcode before this works):
///   Runner target → Signing & Capabilities → + → iCloud
///   ☑ iCloud Documents   (kein CloudKit)
///   Container: iCloud.de.gbs-cidp.cidpbuddy
class ICloudDestination extends BackupDestination {
  static const _containerId = 'iCloud.de.gbs-cidp.cidpbuddy';
  static const _filePrefix  = 'igkeeper_backup_';

  @override
  DestinationKind get kind    => DestinationKind.iCloud;
  @override
  String get displayLabel     => 'iCloud Drive';
  @override
  String get pathOrUri        => 'icloud://';

  @override
  Future<String?> verifyAccess() async {
    try {
      await ICloudStorage.gather(containerId: _containerId, onUpdate: null);
      return null;
    } catch (e) {
      dev.log('ICloudDestination.verifyAccess failed: $e');
      return 'iCloud nicht verfügbar. Bitte iCloud in den Systemeinstellungen aktivieren.';
    }
  }

  @override
  Future<void> writeBackup(String fileName, Uint8List bytes) async {
    final tmp = await _writeTmp(fileName, bytes);
    try {
      await ICloudStorage.upload(
        containerId: _containerId,
        filePath: tmp.path,
        destinationRelativePath: fileName,
      );
    } finally {
      try { await tmp.delete(); } catch (_) {}
    }
  }

  @override
  Future<List<BackupFile>> listBackups() async {
    final files = await ICloudStorage.gather(
      containerId: _containerId,
      onUpdate: null,
    );
    final result = files
        .where((f) =>
            f.relativePath.startsWith(_filePrefix) &&
            f.relativePath.endsWith('.zip'))
        .map((f) => BackupFile(
              name: f.relativePath,
              date: f.contentChangeDate.toLocal(),
              size: f.sizeInBytes,
              pathOrUri: f.relativePath,
              isSaf: false,
            ))
        .toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  @override
  Future<Uint8List> readBackup(BackupFile file) async {
    final tmp   = await _tmpPath('dl_${file.name}');
    final done  = Completer<void>();

    await ICloudStorage.download(
      containerId: _containerId,
      relativePath: file.pathOrUri,
      destinationFilePath: tmp,
      onProgress: (stream) {
        stream.listen(
          null,
          onDone: () {
            if (!done.isCompleted) done.complete();
          },
          onError: (Object e) {
            if (!done.isCompleted) done.completeError(e);
          },
          cancelOnError: true,
        );
      },
    );

    // Wait for the OS to finish writing the local copy (2-min timeout).
    // Gracefully falls through if the file was already local.
    try {
      await done.future.timeout(const Duration(minutes: 2));
    } catch (e) {
      if (!await File(tmp).exists()) rethrow;
    }

    try {
      return await File(tmp).readAsBytes();
    } finally {
      try { await File(tmp).delete(); } catch (_) {}
    }
  }

  @override
  Future<void> deleteBackup(BackupFile file) async {
    await ICloudStorage.delete(
      containerId: _containerId,
      relativePath: file.pathOrUri,
    );
  }

  Future<File> _writeTmp(String name, Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final f   = File(p.join(dir.path, 'icloud_up_$name'));
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }

  Future<String> _tmpPath(String name) async {
    final dir = await getTemporaryDirectory();
    return p.join(dir.path, name);
  }
}
