import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/custom_label_images.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('label images are found by name in any case and can be removed',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final images = ComicCustomLabelImages(db);
    final image = Uint8List.fromList([1, 2, 3]);

    await images.save(' Spawn #1 ', image);
    expect(await images.watch('spawn #1').first, image);
    expect(await images.watchLabels().first, ['Spawn #1']);

    final replaced = Uint8List.fromList([4]);
    await images.save('SPAWN #1', replaced);
    expect(await images.watch('Spawn #1').first, replaced);
    expect(await images.watchLabels().first, ['SPAWN #1']);

    await images.remove('Spawn #1');
    expect(await images.watch('Spawn #1').first, isNull);
    expect(await images.watch('').first, isNull);
  });
}
