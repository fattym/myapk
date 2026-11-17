import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Tracks online/offline state. Updated by API results and, while offline,
/// by a periodic DNS probe so the banner clears when the network returns.
final class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final ValueNotifier<bool> online = ValueNotifier<bool>(true);
  Timer? _timer;

  void reportSuccess() {
    _timer?.cancel();
    _timer = null;
    if (!online.value) online.value = true;
  }

  void reportFailure() {
    if (online.value) online.value = false;
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => check());
  }

  Future<void> check() async {
    try {
      final r = await InternetAddress.lookup('mybidhaa.com')
          .timeout(const Duration(seconds: 4));
      if (r.isNotEmpty && r.first.rawAddress.isNotEmpty) reportSuccess();
    } catch (_) {
      reportFailure();
    }
  }
}
