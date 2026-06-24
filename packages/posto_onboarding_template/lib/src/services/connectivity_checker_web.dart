import 'package:web/web.dart';

/// Web connectivity checker using browser's native API.
/// This file is used when running on web (dart.library.html is present).
class ConnectivityChecker {
  static Future<bool> check() async {
    try {
      // window.navigator.onLine is the browser's own connectivity state.
      // This avoids CORS issues entirely since it's a browser API, not an HTTP probe.
      return window.navigator.onLine;
    } catch (_) {
      return true; // Default to online on error
    }
  }
}
