import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class BackupService {
  Future<void> exportDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'igkeeper.sqlite'));

    if (await dbFile.exists()) {
      // Create a temporary copy to share
      final tempDir = await getTemporaryDirectory();
      final tempFile = await dbFile.copy(p.join(tempDir.path, 'igkeeper_backup.sqlite'));

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
}
