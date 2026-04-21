import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;
import 'package:shared_storage/shared_storage.dart' as saf;

class BackupService {
  static const String kAutoBackupEnabled = 'auto_backup_enabled';
  static const String kBackupDirectoryPath = 'backup_directory_path';
  static const String kBackupIsSaf = 'backup_is_saf';
  static const String kLastBackupTime = 'last_backup_time';

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

  Future<void> setSafBackupDirectory(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kBackupDirectoryPath, uri);
    await prefs.setBool(kBackupIsSaf, true);
    dev.log('BackupService: SAF-Verzeichnis gesetzt: $uri');
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
        dev.log('BackupService: Nutze SAF für Ziel: $targetDir');
        
        // 1. Create ZIP locally in temp folder
        final tempDir = await getTemporaryDirectory();
        final localZipPath = p.join(tempDir.path, zipFileName);
        final encoder = ZipFileEncoder();
        encoder.create(localZipPath);
        await encoder.addFile(dbFile);
        encoder.close();

        // 2. Write to SAF folder
        final uri = Uri.parse(targetDir);
        final bytes = await File(localZipPath).readAsBytes();
        
        final result = await saf.createFile(
          uri,
          mimeType: 'application/zip',
          displayName: zipFileName,
          content: '', // Create empty first, content as String isn't for binary
        );

        if (result != null) {
          // Write the actual binary bytes using the DocumentFile method
          await result.writeToFileAsBytes(
            bytes: bytes,
          );
          
          dev.log('BackupService: SAF-Upload erfolgreich: ${result.uri}');
          await File(localZipPath).delete(); // Cleanup temp
          return true;
        } else {
          dev.log('BackupService: SAF-Upload fehlgeschlagen.');
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
        await encoder.addFile(dbFile);
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
