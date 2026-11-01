import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('images are kept per list and found by value in any case', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final images = ListValueImages(db);
    final image = Uint8List.fromList([1, 2, 3]);

    await images.save('platform', ' Nintendo Switch ', image);
    await images.save('comic.custom_label', 'Spawn #1', image);
    expect(await images.watch('platform', 'nintendo switch').first, image);
    expect(await images.watch('comic.custom_label', 'Nintendo Switch').first,
        isNull);
    expect(await images.watchValues('platform').first, ['Nintendo Switch']);

    final replaced = Uint8List.fromList([4]);
    await images.save('platform', 'NINTENDO SWITCH', replaced);
    expect(await images.watch('platform', 'Nintendo Switch').first, replaced);

    await images.remove('platform', 'Nintendo Switch');
    expect(await images.watch('platform', 'Nintendo Switch').first, isNull);
    await images.removeAll('comic.custom_label');
    expect(await images.watchValues('comic.custom_label').first, isEmpty);
    expect(await images.watch('platform', '').first, isNull);
  });

  test('files are named after their value and SVGs are accepted', () async {
    expect(listValueFromFileName('Nintendo Switch.svg'), 'Nintendo Switch');
    expect(listValueFromFileName('Spawn #1.png'), 'Spawn #1');
    final svg = Uint8List.fromList(utf8.encode(
        '<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg"/>'));
    expect(isSvgImage(svg), isTrue);
    expect(isSvgImage(Uint8List.fromList([0x89, 0x50, 0x4e, 0x47])), isFalse);
    await validateListValueImage(svg);
    await expectLater(validateListValueImage(Uint8List.fromList([1, 2])),
        throwsFormatException);
  });

  test('an all-black SVG can take the text colour, a coloured one keeps its',
      () {
    Uint8List svg(String body) => Uint8List.fromList(
        utf8.encode('<svg xmlns="http://www.w3.org/2000/svg">$body</svg>'));
    expect(isBlackSvg(svg('<path fill="#000000" d="M0 0h1"/>')), isTrue);
    expect(isBlackSvg(svg('<path style="fill:#221e1f" d="M0 0h1"/>')), isTrue);
    expect(isBlackSvg(svg('<path d="M0 0h1"/>')), isTrue);
    expect(isBlackSvg(svg('<path fill="#CE181E" d="M0 0h1"/>')), isFalse);
    expect(isBlackSvg(Uint8List.fromList([0x89, 0x50, 0x4e, 0x47])), isFalse);
  });
}
