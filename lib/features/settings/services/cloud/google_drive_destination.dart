import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import '../backup_destination.dart';
import 'google_drive_auth.dart';

/// Backup destination that stores ZIPs in the user's Google Drive
/// `appDataFolder` — a hidden per-app folder that no other app can read.
///
/// Pros: per-user, free, no folder picking, survives device wipes.
/// Cons: requires network + Google account.
class GoogleDriveDestination extends BackupDestination {
  static const String _kAccountEmail = 'backup_drive_account_email';
  static const String _filePrefix = 'igkeeper_backup_';
  static const String _appDataFolder = 'appDataFolder';

  final String accountEmail;
  GoogleDriveDestination(this.accountEmail);

  @override
  DestinationKind get kind => DestinationKind.googleDrive;

  @override
  String get pathOrUri => 'gdrive://$accountEmail';

  @override
  String get displayLabel => 'Google Drive ($accountEmail)';

  /// Run [body] with a fresh authorized Drive client and ensure it is closed.
  Future<T> _withDrive<T>(Future<T> Function(drive.DriveApi api) body) async {
    final http.Client client =
        await GoogleDriveAuth.instance.authorizedClient();
    try {
      return await body(drive.DriveApi(client));
    } finally {
      client.close();
    }
  }

  @override
  Future<String?> verifyAccess() async {
    try {
      // List the appdata folder — cheapest possible call that proves the
      // grant is still live. We don't write a probe file because Drive
      // counts every create/delete against the user's quota & history.
      await _withDrive((api) async {
        await api.files.list(
          spaces: _appDataFolder,
          pageSize: 1,
          $fields: 'files(id)',
        );
      });
      return null;
    } catch (e) {
      dev.log('GoogleDriveDestination.verifyAccess failed: $e');
      return 'Google Drive nicht erreichbar. Bitte erneut anmelden.';
    }
  }

  @override
  Future<void> writeBackup(String fileName, Uint8List bytes) async {
    await _withDrive((api) async {
      final media = drive.Media(
        Stream<List<int>>.value(bytes),
        bytes.length,
        contentType: 'application/zip',
      );
      final metadata = drive.File()
        ..name = fileName
        ..parents = [_appDataFolder];
      await api.files.create(metadata, uploadMedia: media);
    });
  }

  @override
  Future<List<BackupFile>> listBackups() async {
    return _withDrive((api) async {
      final result = <BackupFile>[];
      String? pageToken;
      do {
        final response = await api.files.list(
          spaces: _appDataFolder,
          pageSize: 100,
          pageToken: pageToken,
          q: "name contains '$_filePrefix' and trashed = false",
          $fields:
              'nextPageToken, files(id, name, modifiedTime, size)',
        );
        for (final f in response.files ?? const <drive.File>[]) {
          final name = f.name;
          final id = f.id;
          if (name == null || id == null) continue;
          if (!name.startsWith(_filePrefix) || !name.endsWith('.zip')) continue;
          final size =
              f.size != null ? int.tryParse(f.size!) ?? 0 : 0;
          result.add(BackupFile(
            name: name,
            date: f.modifiedTime?.toLocal() ?? DateTime.now(),
            size: size,
            pathOrUri: id,
            isSaf: false,
          ));
        }
        pageToken = response.nextPageToken;
      } while (pageToken != null);
      result.sort((a, b) => b.date.compareTo(a.date));
      return result;
    });
  }

  @override
  Future<Uint8List> readBackup(BackupFile file) async {
    return _withDrive((api) async {
      final media = await api.files.get(
        file.pathOrUri,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in media.stream) {
        builder.add(chunk);
      }
      return builder.toBytes();
    });
  }

  @override
  Future<void> deleteBackup(BackupFile file) async {
    await _withDrive((api) async {
      await api.files.delete(file.pathOrUri);
    });
  }

  @override
  Future<void> persist() async {
    await super.persist();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccountEmail, accountEmail);
  }

  static Future<GoogleDriveDestination?> tryLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kAccountEmail);
    if (email == null || email.isEmpty) return null;
    return GoogleDriveDestination(email);
  }

  static Future<void> clearStored() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccountEmail);
  }
}
