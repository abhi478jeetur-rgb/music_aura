import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests the necessary storage permissions based on Android SDK version.
  /// Returns [true] if permission is granted.
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ requires granular permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.audio,
          // Notification permission is needed for Foreground Service on 13+
          Permission.notification, 
        ].request();
        
        // We strictly need Audio access. Notification is optional for app to run but good for UX.
        return statuses[Permission.audio]?.isGranted ?? false;
      } else {
        // Android 12 and below use READ_EXTERNAL_STORAGE
        var status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    // For iOS or Desktop, we might need different logic.
    // For now assuming Android as primary target for "Offline Music App".
    return true; 
  }
  
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
