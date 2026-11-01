import 'package:flutter/foundation.dart';

/// Application presentation is independent of window size and input device.
enum AppPresentationPlatform {
  desktopWeb,
  nativeMobile;

  bool get isNativeMobile => this == nativeMobile;

  /// Web retains desktop presentation even when hosted on Android or iOS.
  static AppPresentationPlatform fromTarget(TargetPlatform target,
          {required bool isWeb}) =>
      !isWeb &&
              (target == TargetPlatform.android || target == TargetPlatform.iOS)
          ? nativeMobile
          : desktopWeb;
}

AppPresentationPlatform get appPresentationPlatform =>
    AppPresentationPlatform.fromTarget(defaultTargetPlatform, isWeb: kIsWeb);
