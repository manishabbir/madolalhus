import 'dart:async';

import 'package:flutter/foundation.dart';

import 'connectivity_checker_stub.dart'
    if (dart.library.html) 'connectivity_checker_web.dart';

/// Monitors real network connectivity via platform-appropriate probes.
///
/// - **Native**: Uses `InternetAddress.lookup('google.com')` (DNS resolution).
/// - **Web**: Uses `window.navigator.onLine` (browser's native connectivity).
///
/// [connectivity_plus] is deliberately **not** used because it
/// frequently returns false negatives on Windows (reports offline when
/// the network is actually available).
///
/// Self-initializes on first access so consuming code does NOT need to
/// explicitly call [initialize] or [ensureReady].
enum ConnectionStatus { online, offline }

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  Timer? _pollTimer;
  bool _initialized = false;

  ConnectionStatus _status = ConnectionStatus.offline;

  ConnectionStatus get status {
    _ensureInitialized();
    return _status;
  }

  bool get isOnline {
    _ensureInitialized();
    return _status == ConnectionStatus.online;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
      _poll();
      _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _poll();
      });
    }
  }

  /// Blocks until the initial connectivity probe completes.
  /// Call this before the app starts so the status is ready immediately.
  Future<void> ensureReady() async {
    if (!_initialized) {
      _initialized = true;
      _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _poll();
      });
      await _poll();
    }
  }

  Future<void> initialize() async {
    _ensureInitialized();
  }

  Future<void> _poll() async {
    final nowOnline = await ConnectivityChecker.check();
    final newStatus =
        nowOnline ? ConnectionStatus.online : ConnectionStatus.offline;
    if (newStatus != _status) {
      _status = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
