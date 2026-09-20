import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cidpbuddy/features/settings/services/backup_destination.dart';
import 'package:cidpbuddy/l10n/generated/app_localizations_en.dart';

/// The iOS backup folder is reached through a method channel, so everything
/// on this side of it can be tested without a device: what gets sent, what is
/// made of the answer, and — the part that silently breaks backups when it is
/// wrong — that a refreshed bookmark is persisted instead of dropped.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('de.fokuspunk.cidpbuddy/backup_bookmark');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final original = Uint8List.fromList([1, 2, 3]);
  late List<MethodCall> calls;

  /// Answers every call with [reply], or throws [error] if one is given.
  void mockChannel({Map<String, Object?>? reply, PlatformException? error}) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (error != null) throw error;
      return reply;
    });
  }

  setUp(() {
    calls = [];
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('isBackupFileName', () {
    test('accepts both prefixes and only ZIPs', () {
      expect(
        BackupDestination.isBackupFileName(
          'cidpbuddy_backup_20260101_120000.zip',
        ),
        isTrue,
      );
      // The app was called igkeeper once; those backups still restore.
      expect(
        BackupDestination.isBackupFileName(
          'igkeeper_backup_20240101_120000.zip',
        ),
        isTrue,
      );
      expect(
        BackupDestination.isBackupFileName('cidpbuddy_backup_1.txt'),
        isFalse,
      );
      expect(BackupDestination.isBackupFileName('holiday.zip'), isFalse);
      expect(BackupDestination.isBackupFileName('.cidp_health'), isFalse);
    });
  });

  group('BookmarkDestination', () {
    test('lists only backups, newest first', () async {
      mockChannel(
        reply: {
          'value': [
            {
              'name': 'cidpbuddy_backup_20260101_120000.zip',
              'size': 2048,
              'modified': 1000,
              'placeholder': false,
            },
            {
              'name': 'cidpbuddy_backup_20260301_120000.zip',
              'size': 0,
              'modified': 5000,
              'placeholder': true,
            },
            // Not ours: a holiday photo folder the patient also keeps there.
            {
              'name': 'IMG_0042.zip',
              'size': 999,
              'modified': 9000,
              'placeholder': false,
            },
          ],
        },
      );

      final destination = BookmarkDestination(original);
      final backups = await destination.listBackups();

      expect(backups.map((b) => b.name), [
        'cidpbuddy_backup_20260301_120000.zip',
        'cidpbuddy_backup_20260101_120000.zip',
      ]);
      // A backup iCloud has not downloaded here yet reports no size.
      expect(backups.first.size, 0);
      expect(backups.last.size, 2048);
      expect(calls.single.method, 'list');
      expect((calls.single.arguments as Map)['bookmark'], original);
    });

    test('persists a refreshed bookmark rather than dropping it', () async {
      final refreshed = Uint8List.fromList([9, 9, 9]);
      mockChannel(reply: {'bookmark': refreshed});

      final destination = BookmarkDestination(original, displayName: 'Backups');
      await destination.writeBackup(
        'cidpbuddy_backup_20260101_120000.zip',
        Uint8List.fromList([0]),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('backup_directory_path'), base64Encode(refreshed));
      expect(prefs.getString('backup_destination_kind'), 'bookmark');
      expect(prefs.getString('backup_bookmark_folder_name'), 'Backups');
      // The next call has to carry the new token, not the dead one.
      expect(destination.pathOrUri, base64Encode(refreshed));
    });

    test('sends the file name and returns the bytes on read', () async {
      final bytes = Uint8List.fromList([4, 5, 6]);
      mockChannel(reply: {'value': bytes});

      final destination = BookmarkDestination(original);
      final read = await destination.readBackup(
        BackupFile(
          name: 'cidpbuddy_backup_20260101_120000.zip',
          date: DateTime(2026),
          size: 3,
          pathOrUri: 'cidpbuddy_backup_20260101_120000.zip',
          isSaf: false,
        ),
      );

      expect(read, bytes);
      expect(calls.single.method, 'read');
      expect(
        (calls.single.arguments as Map)['name'],
        'cidpbuddy_backup_20260101_120000.zip',
      );
    });

    test('turns lost access into a sentence a patient can act on', () async {
      mockChannel(error: PlatformException(code: 'access_denied'));

      final error = await BookmarkDestination(original).verifyAccess();

      expect(error, AppLocalizationsEn().backupBookmarkAccessLost);
    });

    test('adopts the folder name it is told on verify', () async {
      mockChannel(reply: {'value': 'Nextcloud'});

      final destination = BookmarkDestination(original, displayName: 'Backups');
      expect(await destination.verifyAccess(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('backup_bookmark_folder_name'), 'Nextcloud');
      expect(destination.displayLabel(AppLocalizationsEn()), 'Nextcloud');
    });
  });
}
