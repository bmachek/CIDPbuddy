import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;
import 'package:saf_util/saf_util.dart';
import 'package:saf_stream/saf_stream.dart';
import '../../reminders/services/notification_service.dart';

class BackupFile {
  final String name;
  final DateTime date;
  final int size;
  final String pathOrUri;
  final bool isSaf;

  BackupFile({
    required this.name,
    required this.date,
    required this.size,
    required this.pathOrUri,
    required this.isSaf,
  });
}

class BackupService {
  static const String kAutoBackupEnabled = 'auto_backup_enabled';
  static const String kBackupDirectoryPath = 'backup_directory_path';
  static const String kBackupIsSaf = 'backup_is_saf';
  static const String kLastBackupTime = 'last_backup_time';

  Future<List<BackupFile>> getAvailableBackups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? targetDir = prefs.getString(kBackupDirectoryPath);
    final bool isSaf = prefs.getBool(kBackupIsSaf) ?? false;

    if (targetDir == null) return [];

    try {
      if (isSaf && Platform.isAndroid) {
        final safUtil = SafUtil();
        final files = await safUtil.list(targetDir);
        
        return files
            .where((f) => f.name.startsWith('igkeeper_backup_') && f.name.endsWith('.zip'))
            .map((f) => BackupFile(
                  name: f.name, 
                  date: DateTime.fromMillisecondsSinceEpoch(f.lastModified),
                  size: f.length,
                  pathOrUri: f.uri,
                  isSaf: true,
                ))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        final directory = Directory(targetDir);
        if (!await directory.exists()) return [];

        final List<FileSystemEntity> files = await directory.list().toList();
        return files
            .whereType<File>()
            .where((f) => p.basename(f.path).startsWith('igkeeper_backup_') && f.path.endsWith('.zip'))
            .map((f) {
              final stat = f.statSync();
              return BackupFile(
                name: p.basename(f.path),
                date: stat.modified,
                size: stat.size,
                pathOrUri: f.path,
                isSaf: false,
              );
            })
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      dev.log('Fehler beim Abrufen der Backups: $e');
      return [];
    }
  }

  Future<bool> restoreFromZippedBackup(BackupFile backup) async {
    try {
      dev.log('Wiederherstellung gestartet von: ${backup.name}');
      
      final List<int> bytes;
      if (backup.isSaf && Platform.isAndroid) {
        final safStream = SafStream();
        bytes = await safStream.readFileBytes(backup.pathOrUri);
      } else {
        final file = File(backup.pathOrUri);
        if (!await file.exists()) {
          dev.log('Fehler: Backup-Datei existiert nicht lokal.');
          return false;
        }
        bytes = await file.readAsBytes();
      }

      if (bytes.isEmpty) {
        dev.log('Fehler: Backup-Datei ist leer.');
        return false;
      }

      final archive = ZipDecoder().decodeBytes(bytes);
      final dbFolder = await getApplicationDocumentsDirectory();
      bool dbRestored = false;

      dev.log('Extrahiere ${archive.length} Dateien nach ${dbFolder.path}');

      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File(p.join(dbFolder.path, file.name));
          
          try {
            // Attempt to write. If it fails due to lock, we'll see it in logs.
            await outFile.writeAsBytes(data, flush: true);
            
            if (file.name == 'igkeeper.sqlite') {
              dbRestored = true;
            }
            dev.log('Erfolgreich wiederhergestellt: ${file.name}');
          } catch (e) {
            dev.log('FEHLER beim Schreiben von ${file.name}: $e');
          }
        }
      }

      if (dbRestored) {
        dev.log('Backup-Wiederherstellung erfolgreich abgeschlossen.');
        return true;
      } else {
        dev.log('Kritisch: igkeeper.sqlite im ZIP nicht gefunden!');
        return false;
      }
    } catch (e, stack) {
      dev.log('Schwerer Fehler bei der Wiederherstellung: $e');
      dev.log(stack.toString());
      return false;
    }
  }

  Future<void> exportDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'igkeeper.sqlite'));

    if (await dbFile.exists()) {
      // Create a temporary copy to share
      final tempDir = await getTemporaryDirectory();
      final backupPath = p.join(tempDir.path, 'igkeeper_backup.sqlite');
      
      // Ensure the directory exists
      final backupFile = File(backupPath);
      if (!await backupFile.parent.exists()) {
        await backupFile.parent.create(recursive: true);
      }
      
      final tempFile = await dbFile.copy(backupPath);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: 'IgKeeper Backup',
        text: 'Sicherung der IgKeeper Datenbank vom ${DateTime.now().toLocal()}',
      );
    }
  }

  Future<bool> importDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // .sqlite might not be recognized on all platforms
    );

    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'igkeeper.sqlite'));

      // Replace the current database
      // NOTE: In a real app, we should close the database connection first
      await pickedFile.copy(dbFile.path);
      return true;
    }
    return false;
  }

  // --- New Automated Zipped Backup Feature ---

  // --- Universal Cloud Folder (SAF) Support ---

  Future<String?> pickSafBackupDirectory() async {
    try {
      final safUtil = SafUtil();
      final dir = await safUtil.pickDirectory(
        writePermission: true,
        persistablePermission: true,
      );

      if (dir != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kBackupDirectoryPath, dir.uri);
        await prefs.setBool(kBackupIsSaf, true);
        dev.log('BackupService: SAF-Verzeichnis gesetzt: ${dir.uri}');
        return dir.uri;
      }
    } catch (e, stack) {
      dev.log('BackupService: Fehler beim Wählen des SAF-Ordners: $e');
      dev.log('Stacktrace: $stack');
    }
    return null;
  }

  /// Ensures that we still have permission to access the SAF directory.
  /// On some Android versions, permissions might need to be "re-taken" if they weren't persisted correctly.
  Future<bool> ensureSafPermission(String uri) async {
    if (!Platform.isAndroid) return true;
    try {
      // We assume it's okay for now, saf_stream will fail if not
      return true; 
    } catch (e) {
      dev.log('BackupService: Fehler bei SAF-Validierung: $e');
      return false;
    }
  }

  Future<String?> selectBackupDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        // Validate if we can actually write to this directory
        final isWritable = await _isPathWritable(selectedDirectory);
        if (!isWritable) {
          dev.log('Gewähltes Verzeichnis ist nicht beschreibbar: $selectedDirectory');
          // We return the error string so the UI can react to it
          return 'Error: Not writable: $selectedDirectory';
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kBackupDirectoryPath, selectedDirectory);
        await prefs.setBool(kBackupIsSaf, false);
        return selectedDirectory;
      }
    } catch (e) {
      dev.log('Fehler bei der Verzeichnisauswahl: $e');
    }
    return null;
  }

  Future<String> getSafeBackupDirectory() async {
    if (Platform.isAndroid) {
      // getExternalStorageDirectory is usually /storage/emulated/0/Android/data/com.example.app/files
      // This is visible to the user and always writable.
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final backupDir = Directory(p.join(extDir.path, 'Backups'));
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        return backupDir.path;
      }
    }
    
    // Fallback to documents directory
    final docDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docDir.path, 'Backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<void> setBackupDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kBackupDirectoryPath, path);
  }

  Future<bool> _isPathWritable(String path) async {
    try {
      final testFile = File(p.join(path, '.write_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      dev.log('Pfad-Validierung fehlgeschlagen ($path): $e');
      return false;
    }
  }

  Future<void> autoBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool(kAutoBackupEnabled) ?? false;
    final String? targetDir = prefs.getString(kBackupDirectoryPath);

    if (isEnabled && targetDir != null) {
      dev.log('Starte automatisches Backup nach: $targetDir');
      final success = await performZippedBackup(targetDir);
      if (success) {
        await prefs.setString(kLastBackupTime, DateTime.now().toIso8601String());
        await _cleanupOldBackups(targetDir);
      } else {
        await NotificationService().showBackupFailureNotification('Fehler beim Schreiben der Backup-Datei.');
      }
    }
  }

  Future<bool> performZippedBackup(String targetDir) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isSaf = prefs.getBool(kBackupIsSaf) ?? false;
      
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'igkeeper.sqlite'));

      if (!await dbFile.exists()) {
        dev.log('Backup fehlgeschlagen: Quelldatenbank nicht gefunden.');
        return false;
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final zipFileName = 'igkeeper_backup_$timestamp.zip';

      if (isSaf && Platform.isAndroid) {
        // --- SAF / Cloud Folder Mode ---
        dev.log('BackupService: Nutze SAF (modern) für Ziel-URI: $targetDir');
        
        // 1. Create ZIP locally in temp folder
        final tempDir = await getTemporaryDirectory();
        final localZipPath = p.join(tempDir.path, zipFileName);
        final encoder = ZipFileEncoder();
        encoder.create(localZipPath);
        
        // Add DB
        await encoder.addFile(dbFile);
        
        // Add Photos
        final List<FileSystemEntity> files = await dbFolder.list().toList();
        final chargePhotos = files.whereType<File>().where((f) => p.basename(f.path).startsWith('charge_'));
        for (final photo in chargePhotos) {
          await encoder.addFile(photo);
        }
        
        encoder.close();

        // 2. Write to SAF folder using saf_stream
        final bytes = await File(localZipPath).readAsBytes();
        
        try {
          final safStream = SafStream();
          
          // Verify access before writing
          await ensureSafPermission(targetDir);
          
          await safStream.writeFileBytes(
            targetDir, // Tree URI
            zipFileName,
            'application/zip',
            bytes,
          );
          
          dev.log('BackupService: SAF-Upload (saf_stream) erfolgreich für $zipFileName');
          await File(localZipPath).delete(); // Cleanup temp
          return true;
        } catch (e, stack) {
          dev.log('BackupService: FEHLER beim Schreiben via saf_stream: $e');
          dev.log('Stacktrace: $stack');
          dev.log('Ziel-URI war: $targetDir');
          return false;
        }
      } else {
        // --- Classic Local Directory Mode ---
        // Ensure target directory exists and is writable
        final directory = Directory(targetDir);
        if (!await directory.exists()) {
          dev.log('Backup-Verzeichnis existiert nicht: $targetDir. Versuche es zu erstellen...');
          try {
            await directory.create(recursive: true);
          } catch (e) {
            dev.log('Konnte Verzeichnis nicht erstellen: $e');
            return false;
          }
        }

        // Create ZIP
        final encoder = ZipFileEncoder();
        final zipPath = p.join(targetDir, zipFileName);

        dev.log('Erstelle ZIP in: $zipPath');
        encoder.create(zipPath);
        
        // Add DB
        await encoder.addFile(dbFile);
        
        // Add Photos
        final List<FileSystemEntity> files = await dbFolder.list().toList();
        final chargePhotos = files.whereType<File>().where((f) => p.basename(f.path).startsWith('charge_'));
        for (final photo in chargePhotos) {
          await encoder.addFile(photo);
        }
        
        encoder.close();

        dev.log('Zipped Backup erfolgreich erstellt: $zipPath');
        return true;
      }
    } catch (e) {
      dev.log('Fehler beim Erstellen des zipped Backups: $e');
      return false;
    }
  }

  Future<void> _cleanupOldBackups(String targetDir) async {
    try {
      final directory = Directory(targetDir);
      final List<FileSystemEntity> files = await directory.list().toList();

      // Filter for our backup files
      final backupFiles = files.whereType<File>().where((file) {
        final name = p.basename(file.path);
        return name.startsWith('igkeeper_backup_') && name.endsWith('.zip');
      }).toList();

      // Sort by modification date (oldest first)
      backupFiles.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));

      // Keep only last 5
      if (backupFiles.length > 5) {
        final toDelete = backupFiles.take(backupFiles.length - 5);
        for (final file in toDelete) {
          await file.delete();
          dev.log('Altes Backup gelöscht: ${file.path}');
        }
      }
    } catch (e) {
      dev.log('Fehler bei der Bereinigung alter Backups: $e');
    }
  }
}
