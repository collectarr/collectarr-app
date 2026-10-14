import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'font_weight.dart';
import 'local_font_access.dart' as access;
import 'local_font_face.dart';

typedef RegisterLocalFont = Future<void> Function(String, Uint8List);

class LocalFontController extends ChangeNotifier {
  LocalFontController(
      {RegisterLocalFont? registerFont,
      Future<List<LocalFontFace>> Function()? discoverFonts,
      bool? canDiscover})
      : _registerFont = registerFont ?? _register,
        _discoverFonts = discoverFonts ?? access.discoverLocalFonts,
        _canDiscover = canDiscover;
  static final instance = LocalFontController();
  static const preferencesKey = 'app.localFonts';
  static const maxImportedBytes = 2 * 1024 * 1024;
  static const _fallback = {
    400: 'Regular',
    500: 'Medium',
    600: 'SemiBold',
    700: 'Bold',
    800: 'ExtraBold',
    900: 'ExtraBold',
  };
  final RegisterLocalFont _registerFont;
  final Future<List<LocalFontFace>> Function() _discoverFonts;
  final bool? _canDiscover;
  SharedPreferences? _preferences;
  final _installed = <int, LocalFontFace>{};
  final _imported = <int, LocalFontFace>{};
  bool _enabled = true;
  int _generation = 0;
  final _registeredFamilies = <String, String>{};
  String _family = 'Plus Jakarta Sans';
  String? _startupError;
  LocalFontFace? get normalTextFace => _normalFace(faces);

  // Match the reference's painted weight, not only its CSS number. At small
  // sizes Flutter paints local Medium noticeably lighter than the browser.
  static LocalFontFace? _normalFace(Map<int, LocalFontFace> faces) =>
      faces[600] ?? faces[500] ?? faces[400];
  bool get enabled => _enabled;
  String get activeFamily => _family;
  String? get startupError => _startupError;
  bool get isGilroyActive => _family != 'Plus Jakarta Sans';
  bool get canDiscover => _canDiscover ?? access.canDiscoverLocalFonts;
  bool get hasImported => _imported.isNotEmpty;
  Map<int, LocalFontFace> get faces =>
      Map.unmodifiable({..._installed, ..._imported});

  static Future<void> _register(String family, Uint8List bytes) {
    // The web engine requires a native ArrayBuffer, not an unmodifiable view.
    // Keep the validated face immutable and give the engine its own copy.
    final engineBytes = Uint8List.fromList(bytes);
    return (FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(engineBytes))))
        .load();
  }

  Future<void> initialize(
      {SharedPreferences? preferences, bool discover = true}) async {
    try {
      _preferences = preferences ?? await SharedPreferences.getInstance();
    } catch (_) {
      _startupError = 'Font preferences could not be read on this device.';
    }
    try {
      final raw = _preferences?.getString(preferencesKey);
      if (raw != null) {
        if (raw.length > maxImportedBytes * 2) {
          throw const FormatException('Font cache is too large.');
        }
        final value = jsonDecode(raw) as Map<String, dynamic>;
        final enabled = value['enabled'];
        if (enabled is! bool || value['faces'] is! List) {
          throw const FormatException('Invalid local font settings.');
        }
        final restored = <int, LocalFontFace>{};
        for (final item in value['faces'] as List) {
          final record = item as Map<String, dynamic>;
          if (!['Imported', 'Browser'].contains(record['source'])) {
            throw const FormatException('Invalid cached font source.');
          }
          final face = LocalFontFace.parse(
              base64Decode(record['data'] as String),
              source: record['source'] as String);
          if (restored.containsKey(face.weight)) {
            throw const FormatException('Duplicate cached font weights.');
          }
          restored[face.weight] = face;
        }
        _validateSize(restored.values);
        _imported.addAll(restored);
        _enabled = enabled;
      }
    } catch (_) {
      _startupError = 'Saved fonts could not be restored. Import them again.';
    }
    if (discover && access.discoverFontsAtStartup) {
      try {
        for (final face in await _discoverFonts()) {
          _installed[face.weight] = face;
        }
      } catch (_) {
        _startupError =
            'Installed fonts could not be read. Import local files instead.';
      }
    }
    try {
      await _apply();
    } catch (_) {
      _family = 'Plus Jakarta Sans';
      _startupError =
          'Local fonts could not be loaded. Import valid files again.';
      notifyListeners();
    }
  }

  Future<int> discoverInstalled() async {
    final discovered = await _discoverFonts();
    if (discovered.isEmpty) {
      throw const FormatException('No upright Gilroy faces were found.');
    }
    final installed = {for (final face in discovered) face.weight: face};
    final imported = {..._imported};
    // Browser-granted bytes are stored locally so startup never prompts.
    for (final face in discovered.where((f) => f.source == 'Browser')) {
      imported[face.weight] = face;
    }
    await _commit(enabled: true, imported: imported, installed: installed);
    return discovered.length;
  }

  Future<void> importFaces(List<LocalFontFace> additions) async {
    if (additions.isEmpty) return;
    final weights = <int>{};
    for (final face in additions) {
      if (!weights.add(face.weight)) {
        throw FormatException('Choose one face for weight ${face.weight}.');
      }
    }
    final next = {
      ..._imported,
      for (final face in additions) face.weight: face
    };
    _validateSize(next.values);
    await _commit(enabled: true, imported: next);
  }

  Future<void> setEnabled(bool enabled) =>
      _commit(enabled: enabled, imported: _imported);

  Future<void> removeImported() =>
      _commit(enabled: _enabled, imported: {}, installed: {
        for (final entry in _installed.entries)
          if (entry.value.source == 'Installed') entry.key: entry.value
      });

  Future<void> _commit(
      {required bool enabled,
      required Map<int, LocalFontFace> imported,
      Map<int, LocalFontFace>? installed}) async {
    _validateSize(imported.values);
    final nextInstalled = installed ?? _installed;
    final family =
        await _prepareFamily(enabled, {...nextInstalled, ...imported});
    await _save(enabled, imported);
    // Copy before clearing: callers can pass the current maps.
    final savedInstalled = Map<int, LocalFontFace>.of(nextInstalled);
    final savedImported = Map<int, LocalFontFace>.of(imported);
    _installed
      ..clear()
      ..addAll(savedInstalled);
    _imported
      ..clear()
      ..addAll(savedImported);
    _enabled = enabled;
    _family = family;
    _startupError = null;
    notifyListeners();
  }

  static void _validateSize(Iterable<LocalFontFace> faces) {
    if (faces.fold<int>(0, (n, f) => n + f.bytes.length) > maxImportedBytes) {
      throw const FormatException('Select font files totalling at most 2 MB.');
    }
  }

  Future<void> _save(bool enabled, Map<int, LocalFontFace> fonts) async {
    _preferences ??= await SharedPreferences.getInstance();
    final saved = await _preferences!.setString(
        preferencesKey,
        jsonEncode({
          'enabled': enabled,
          'faces': fonts.values.map((f) => f.toJson()).toList(),
        }));
    if (!saved) {
      throw StateError('Local fonts could not be saved on this device.');
    }
  }

  Future<void> _apply() async {
    _family = await _prepareFamily(_enabled, faces);
    notifyListeners();
  }

  Future<String> _prepareFamily(
      bool enabled, Map<int, LocalFontFace> current) async {
    if (!enabled || current.isEmpty) return 'Plus Jakarta Sans';
    final weights = current.keys.toList()..sort();
    final fingerprint =
        weights.map((w) => '$w:${sha256.convert(current[w]!.bytes)}').join('|');
    if (_registeredFamilies[fingerprint] case final registered?) {
      return registered;
    }
    // New contents get a fresh engine alias. Toggle/reuse needs no new fonts.
    final family = 'Collectarr Local Font ${++_generation}';
    // Keep regular/medium UI roles optically consistent across menus, fields
    // and navigation. Only registration copies change; originals stay intact.
    final normalFace = _normalFace(current);
    for (final entry in _fallback.entries) {
      if (current.containsKey(entry.key) ||
          ((entry.key == 400 || entry.key == 500) && normalFace != null)) {
        continue;
      }
      final data = await rootBundle
          .load('assets/fonts/PlusJakartaSans-${entry.value}.ttf');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await _registerFont(
          family, entry.key == 900 ? fontBytesAtWeight(bytes, 900) : bytes);
    }
    if (normalFace != null) {
      for (final weight in [400, 500]) {
        await _registerFont(
            family,
            normalFace.weight == weight
                ? normalFace.bytes
                : fontBytesAtWeight(normalFace.bytes, weight));
      }
    }
    for (final face in current.values) {
      if (face.weight == 400 || face.weight == 500) continue;
      await _registerFont(family, face.bytes);
    }
    _registeredFamilies[fingerprint] = family;
    return family;
  }
}
