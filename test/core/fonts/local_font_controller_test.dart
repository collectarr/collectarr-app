import 'dart:convert';
import 'package:collectarr_app/core/fonts/fallback_font_weight.dart';
import 'package:collectarr_app/core/fonts/local_font_controller.dart';
import 'package:collectarr_app/core/fonts/local_font_face.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_font_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  LocalFontFace face(int weight) =>
      LocalFontFace.parse(fontFixture(weight: weight), source: 'Imported');
  test('fills every missing UI weight, persists and restores imported faces',
      () async {
    final registered = <int>[];
    final c = LocalFontController(
        registerFont: (_, bytes) async => registered.add(fontWeight(bytes)));
    await c.initialize(discover: false);
    expect(c.activeFamily, 'Plus Jakarta Sans');
    await c.importFaces([face(700)]);
    expect(registered.toSet(), {400, 500, 600, 700, 800, 900});
    expect(registered.length, 6);
    expect(c.isGilroyActive, true);
    final restored = LocalFontController(registerFont: (_, __) async {});
    await restored.initialize(discover: false);
    expect(restored.faces.keys, [700]);
    expect(restored.faces[700]!.source, 'Imported');
    await restored.setEnabled(false);
    final disabled = LocalFontController(registerFont: (_, __) async {});
    await disabled.initialize(discover: false);
    expect(disabled.enabled, false);
    expect(disabled.activeFamily, 'Plus Jakarta Sans');
    expect(disabled.faces.keys, [700]);
    c.dispose();
    restored.dispose();
    disabled.dispose();
  });
  test('toggle reuses registrations and removing imports returns to fallback',
      () async {
    var calls = 0;
    final c = LocalFontController(registerFont: (_, __) async {
      calls++;
    });
    await c.initialize(discover: false);
    await c.importFaces([face(400)]);
    final family = c.activeFamily;
    final count = calls;
    await c.setEnabled(false);
    await c.setEnabled(true);
    expect(c.activeFamily, family);
    expect(calls, count);
    await c.removeImported();
    expect(c.hasImported, false);
    expect(c.isGilroyActive, false);
    final restored = LocalFontController(registerFont: (_, __) async {});
    await restored.initialize(discover: false);
    expect(restored.faces, isEmpty);
    c.dispose();
    restored.dispose();
  });
  test(
      'duplicate import and failed registration preserve existing fonts and storage',
      () async {
    var fail = false;
    final c = LocalFontController(registerFont: (_, __) async {
      if (fail) throw StateError('Invalid face');
    });
    await c.initialize(discover: false);
    await c.importFaces([face(400)]);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(LocalFontController.preferencesKey);
    final family = c.activeFamily;
    await expectLater(
        c.importFaces([face(700), face(700)]), throwsFormatException);
    fail = true;
    await expectLater(c.importFaces([face(700)]), throwsStateError);
    expect(c.faces.keys, [400]);
    expect(c.activeFamily, family);
    expect(prefs.getString(LocalFontController.preferencesKey), saved);
    c.dispose();
  });
  test(
      'replacing contents changes alias; permission failure preserves active fonts',
      () async {
    final c = LocalFontController(
        registerFont: (_, __) async {},
        discoverFonts: () async =>
            throw const FormatException('Permission denied'),
        canDiscover: true);
    await c.initialize(discover: false);
    await c.importFaces([face(400)]);
    final family = c.activeFamily;
    await expectLater(c.discoverInstalled(), throwsFormatException);
    expect(c.activeFamily, family);
    await c.importFaces([face(700)]);
    expect(c.activeFamily, isNot(family));
    c.dispose();
  });
  test(
      'corrupt persisted fonts keep startup usable and report restoration failure',
      () async {
    SharedPreferences.setMockInitialValues({
      LocalFontController.preferencesKey: jsonEncode({
        'enabled': true,
        'faces': [
          {'data': 'invalid', 'source': 'Imported'}
        ]
      })
    });
    final c = LocalFontController(registerFont: (_, __) async {});
    await c.initialize(discover: false);
    expect(c.isGilroyActive, false);
    expect(c.startupError, contains('restored'));
    c.dispose();
  });
  test(
      'browser discovery restores without permission prompts and clearing forgets its bytes',
      () async {
    final browserFace = LocalFontFace.parse(fontFixture(), source: 'Browser');
    final c = LocalFontController(
        registerFont: (_, __) async {},
        discoverFonts: () async => [browserFace]);
    await c.initialize(discover: false);
    await c.discoverInstalled();
    expect(c.faces[400]!.source, 'Browser');
    final restored = LocalFontController(
        registerFont: (_, __) async {},
        discoverFonts: () async =>
            throw StateError('Must not query on startup'));
    await restored.initialize(discover: false);
    expect(restored.isGilroyActive, true);
    await c.removeImported();
    expect(c.faces, isEmpty);
    expect(c.isGilroyActive, false);
    c.dispose();
    restored.dispose();
  });

  test(
      '900 fallback selects ExtraBold with valid adjusted checksum and unchanged glyph tables',
      () async {
    final original =
        (await rootBundle.load('assets/fonts/PlusJakartaSans-ExtraBold.ttf'))
            .buffer
            .asUint8List();
    final modified = fallbackFontAtWeight(original, 900);
    expect(fontWeight(original), 800);
    expect(fontWeight(modified), 900);
    var checksum = 0;
    for (var i = 0; i < modified.length; i += 4) {
      var word = 0;
      for (var j = 0; j < 4; j++) {
        word = (word << 8) | (i + j < modified.length ? modified[i + j] : 0);
      }
      checksum = (checksum + word) & 0xffffffff;
    }
    expect(checksum, 0xb1b0afba);
    final directory = ByteData.sublistView(original);
    for (var i = 0; i < directory.getUint16(4); i++) {
      final entry = 12 + i * 16;
      final tag = directory.getUint32(entry);
      if (tag == 0x4f532f32 || tag == 0x68656164) continue;
      final offset = directory.getUint32(entry + 8);
      final length = directory.getUint32(entry + 12);
      expect(modified.sublist(offset, offset + length),
          original.sublist(offset, offset + length));
    }
  });
}
