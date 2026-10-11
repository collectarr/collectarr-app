import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Discovers and dynamically loads locally installed system fonts into Flutter.
///
/// On Windows 10/11, fonts installed per-user are placed in
/// `%LOCALAPPDATA%\Microsoft\Windows\Fonts` instead of `C:\Windows\Fonts`.
/// Flutter's desktop engine queries system-wide fonts by default, so per-user
/// fonts like Gilroy need to be registered into the engine via [FontLoader].
class SystemFontLoader {
  static bool _gilroyLoaded = false;

  /// Whether Gilroy has been successfully detected and loaded from system fonts.
  static bool get isGilroyLoaded => _gilroyLoaded;

  @visibleForTesting
  static set isGilroyLoadedForTesting(bool value) => _gilroyLoaded = value;

  /// Discovers and loads Gilroy from system font directories if present.
  static Future<bool> loadSystemGilroy() async {
    if (kIsWeb) return false;
    if (_gilroyLoaded) return true;
    if (!Platform.isWindows) return false;

    try {
      final candidateDirectories = <Directory>[];

      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.trim().isNotEmpty) {
        candidateDirectories
            .add(Directory('$localAppData/Microsoft/Windows/Fonts'));
      }

      final winDir = Platform.environment['WINDIR'] ?? 'C:\\Windows';
      candidateDirectories.add(Directory('$winDir/Fonts'));

      final fontFiles = <File>[];
      for (final dir in candidateDirectories) {
        if (!dir.existsSync()) continue;
        try {
          for (final entity in dir.listSync()) {
            if (entity is File) {
              final name = entity.uri.pathSegments.last.toLowerCase();
              if (name.contains('gilroy') &&
                  (name.endsWith('.ttf') || name.endsWith('.otf'))) {
                fontFiles.add(entity);
              }
            }
          }
        } catch (_) {}
      }

      if (fontFiles.isEmpty) {
        return false;
      }

      final loader = FontLoader('Gilroy');
      for (final file in fontFiles) {
        final bytes = await file.readAsBytes();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      }
      await loader.load();
      _gilroyLoaded = true;
      return true;
    } catch (_) {
      return false;
    }
  }
}
