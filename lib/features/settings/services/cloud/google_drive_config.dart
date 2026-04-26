/// OAuth client IDs for Google Sign-In, used by the Google Drive backup
/// destination.
///
/// SETUP — see `docs/google_drive_setup.md`. Short version:
/// 1. Create a Google Cloud project, enable the Drive API.
/// 2. Configure OAuth consent screen (External, scope `drive.appdata`).
/// 3. Create OAuth Client IDs:
///    - Android: package name `com.example.igkeeper` + SHA-1 of the signing
///      cert. No clientId is needed in code — the SDK reads it via the
///      package+SHA combination on Google's side.
///    - iOS: bundle id (e.g. `com.example.igkeeper`). Paste the resulting
///      reversed client ID into Info.plist as a URL scheme. Put the iOS
///      OAuth client ID into [iosClientId] below.
/// 4. Add yourself (and any test users) under "Test users" until the consent
///    screen is published.
class GoogleDriveConfig {
  /// iOS OAuth 2.0 client ID, format `<digits>-<hash>.apps.googleusercontent.com`.
  /// Leave null on platforms where it is not required (Android reads its
  /// config from the package/SHA registration in Cloud Console).
  static const String? iosClientId = null;

  /// The single Drive scope we ever request. `drive.appdata` is restricted to
  /// our own hidden per-user folder — much lighter OAuth verification than
  /// `drive` (full access).
  static const String driveAppDataScope =
      'https://www.googleapis.com/auth/drive.appdata';
}
