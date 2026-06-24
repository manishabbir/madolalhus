import 'dart:io';

/// Native connectivity checker using DNS lookup.
/// This file is used when NOT running on web (dart.library.html is absent).
class ConnectivityChecker {
  static Future<bool> check() async {
    try {
      final list = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return list.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
