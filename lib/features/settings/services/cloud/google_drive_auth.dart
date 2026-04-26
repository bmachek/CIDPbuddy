import 'dart:async';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'google_drive_config.dart';

/// Thin singleton wrapping `google_sign_in` v7 for the Drive backup flow.
///
/// Responsibilities:
///   * one-time `GoogleSignIn.instance.initialize(...)` call (also safe to
///     re-call from the WorkManager isolate);
///   * silent re-auth via [tryRestore];
///   * interactive [signInAndAuthorize] for the picker;
///   * a fresh-token [http.Client] for googleapis to use.
class GoogleDriveAuth {
  GoogleDriveAuth._();
  static final GoogleDriveAuth instance = GoogleDriveAuth._();

  static const List<String> _scopes = [GoogleDriveConfig.driveAppDataScope];

  bool _initialized = false;
  Future<void>? _initFuture;
  GoogleSignInAccount? _currentUser;

  /// Whether the platform supports interactive sign-in. Desktop platforms
  /// other than macOS have no Google Sign-In implementation.
  bool get isPlatformSupported =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> ensureInitialized() {
    if (_initialized) return Future.value();
    return _initFuture ??= _doInit();
  }

  Future<void> _doInit() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId:
            (Platform.isIOS || Platform.isMacOS) ? GoogleDriveConfig.iosClientId : null,
      );
      // Track the current user via the auth event stream so silent token
      // refresh can find a valid account.
      GoogleSignIn.instance.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _currentUser = event.user;
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          _currentUser = null;
        }
      });
      _initialized = true;
    } catch (e, stack) {
      dev.log('GoogleDriveAuth.init failed: $e\n$stack');
      _initFuture = null;
      rethrow;
    }
  }

  /// Try to recover a previously-signed-in account without UI. Used at app
  /// startup and inside the WorkManager isolate.
  Future<GoogleSignInAccount?> tryRestore() async {
    await ensureInitialized();
    try {
      final user =
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (user != null) _currentUser = user;
      return user;
    } catch (e) {
      dev.log('GoogleDriveAuth.tryRestore: $e');
      return null;
    }
  }

  /// Interactive sign-in + scope authorization. Called from the destination
  /// picker UI. Returns the account on success, null on cancel.
  Future<GoogleSignInAccount?> signInAndAuthorize() async {
    await ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: _scopes,
      );
      _currentUser = account;
      // Make sure scopes are granted (some platforms separate auth from
      // authorization).
      await account.authorizationClient.authorizeScopes(_scopes);
      return account;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      dev.log('GoogleDriveAuth.signIn failed: ${e.code} ${e.description}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await ensureInitialized();
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {/* best-effort */}
    }
    _currentUser = null;
  }

  /// Returns an HTTP client that injects a fresh Bearer token on every
  /// request. The client is cheap to construct — keep one per high-level
  /// operation rather than caching globally.
  Future<http.Client> authorizedClient({bool promptIfNeeded = false}) async {
    await ensureInitialized();
    final user = _currentUser ?? await tryRestore();
    if (user == null) {
      throw StateError('Nicht bei Google angemeldet.');
    }
    return _BearerClient(http.Client(), () async {
      final client = user.authorizationClient;
      var headers = await client.authorizationHeaders(_scopes);
      if (headers == null && promptIfNeeded) {
        await client.authorizeScopes(_scopes);
        headers = await client.authorizationHeaders(_scopes);
      }
      if (headers == null) {
        throw StateError('Drive-Berechtigung fehlt.');
      }
      return headers;
    });
  }
}

/// http.Client that calls a token-provider function to populate the
/// Authorization header on every request — works around the fact that Google
/// access tokens expire roughly hourly. The platform implementation caches
/// tokens internally, so calling it per-request is cheap.
class _BearerClient extends http.BaseClient {
  final http.Client _inner;
  final Future<Map<String, String>> Function() _headerProvider;

  _BearerClient(this._inner, this._headerProvider);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final headers = await _headerProvider();
    request.headers.addAll(headers);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
