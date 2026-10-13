import 'dart:io';
import 'local_font_face.dart';

bool get canDiscoverLocalFonts =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;
bool get discoverFontsAtStartup => canDiscoverLocalFonts;

List<String> localFontDirectories(String platform, Map<String, String> env) {
  final home = env['HOME'];
  return switch (platform) {
    'windows' => [
        if (env['LOCALAPPDATA'] case final local?)
          '$local/Microsoft/Windows/Fonts',
        '${env['WINDIR'] ?? r'C:\Windows'}/Fonts',
      ],
    'macos' => [
        if (home != null) '$home/Library/Fonts',
        '/Library/Fonts',
        '/System/Library/Fonts',
      ],
    'linux' => [
        if (env['XDG_DATA_HOME'] case final data?) '$data/fonts',
        if (home != null) ...['$home/.local/share/fonts', '$home/.fonts'],
        '/usr/local/share/fonts',
        '/usr/share/fonts',
      ],
    _ => [],
  };
}

Future<List<LocalFontFace>> discoverLocalFonts() async {
  if (!canDiscoverLocalFonts) return [];
  final files = <String, File>{};
  for (final path
      in localFontDirectories(Platform.operatingSystem, Platform.environment)) {
    final directory = Directory(path);
    if (!await directory.exists()) continue;
    try {
      await for (final entry
          in directory.list(recursive: true, followLinks: false)) {
        if (entry is! File) continue;
        final name = entry.uri.pathSegments.last.toLowerCase();
        if (name.contains('gilroy') &&
            (name.endsWith('.ttf') || name.endsWith('.otf'))) {
          files[entry.path] = entry;
        }
      }
    } on FileSystemException {
      // Unreadable system directories do not prevent manual font import.
    }
  }
  final faces = <int, LocalFontFace>{};
  final paths = files.keys.toList()..sort();
  for (final path in paths) {
    try {
      if (await files[path]!.length() > 2 * 1024 * 1024) continue;
      final face = LocalFontFace.parse(await files[path]!.readAsBytes(),
          source: 'Installed');
      faces.putIfAbsent(face.weight, () => face);
    } on FormatException {
      // Collections, italic faces and unrelated fonts are not UI faces.
    } on FileSystemException {
      // An inaccessible file does not hide other installed weights.
    }
  }
  return faces.values.toList();
}
