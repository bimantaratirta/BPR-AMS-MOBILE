import 'package:flutter/foundation.dart';

class PlatformUtils {
  /// True if running in a web browser
  static bool get isWeb => kIsWeb;

  /// True if running in a browser on an Android device
  static bool get isAndroidWeb =>
      kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// True if running in a browser on an iOS device
  static bool get isIOSWeb =>
      kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// True if running on a mobile browser (Android or iOS)
  static bool get isMobileWeb => isAndroidWeb || isIOSWeb;
}
