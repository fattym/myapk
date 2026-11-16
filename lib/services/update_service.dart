import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Play Store in-app updates (Android only; no-ops for sideloaded builds).
final class UpdateService {
  const UpdateService._();

  static Future<void> check() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }
      if (info.immediateUpdateAllowed && (info.updatePriority >= 4)) {
        await InAppUpdate.performImmediateUpdate();
      } else if (info.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (_) {
      // Not installed from Play / no Play services: ignore.
    }
  }
}
