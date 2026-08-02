import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source tree does not import obsolete catalog_item_types.dart', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);

    final filesWithObsoleteImport = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        if (content.contains('catalog_item_types.dart')) {
          filesWithObsoleteImport.add(entity.path);
        }
      }
    }

    expect(
      filesWithObsoleteImport,
      isEmpty,
      reason:
          'The obsolete file catalog_item_types.dart should not be imported. '
          'Import canonical domain/DTO models directly instead.',
    );
  });
}
