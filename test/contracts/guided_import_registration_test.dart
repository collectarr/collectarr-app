import 'dart:convert';
import 'dart:io';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every advertised guided source owns an importer and fixture manifest',
      () {
    final manifest = jsonDecode(
            File('test/fixtures/imports/manifest.json').readAsStringSync())
        as Map<String, dynamic>;
    final registered = <String>{};
    for (final kind in defaultLibraryKindRegistry.allKinds) {
      final capability = libraryImportForKind(kind.kind);
      expect(capability.sources.map((s) => s.id).toSet().length,
          capability.sources.length);
      for (final source in capability.sources) {
        if (source.sourceType == LibraryImportSourceType.csvTxt) {
          expect(capability.mappedCsvImporter, isNotNull);
          continue;
        }
        expect(source.importer, isNotNull, reason: source.title);
        final fixture = manifest['${kind.kind.apiValue}.${source.id}']
            as Map<String, dynamic>?;
        expect(fixture, isNotNull, reason: source.title);
        expect(fixture!['kind'], kind.kind.apiValue);
        expect(fixture['origin'], isNotEmpty);
        for (final key in ['minimal', 'optional', 'invalid']) {
          expect(File('test/fixtures/imports/${fixture[key]}').existsSync(),
              isTrue);
        }
        final rows = source.importer!.parse(
            File('test/fixtures/imports/${fixture['minimal']}')
                .readAsStringSync());
        expect(rows, isNotEmpty);
        expect(rows.every((row) => row.mediaKind == kind.kind), isTrue);
        registered.add('${kind.kind.apiValue}.${source.id}');
      }
    }
    expect(manifest.keys.toSet(), registered);
  });
}
