import 'dart:convert';
import 'dart:io';

import 'package:collectarr_app/core/api/generated/catalog_item_v2_fields.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core contracts bundle matches manifest hashes', () {
    final manifest = jsonDecode(
      File('tool/core_contracts/contract-manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final activeKinds = jsonDecode(
      File('tool/core_contracts/active-kinds.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final fieldSchema = jsonDecode(
      File('tool/core_contracts/metadata-field-schema.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final catalogItemSchema = jsonDecode(
      File('tool/core_contracts/catalog-item-v2.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final musicContract = jsonDecode(
      File('tool/core_contracts/music-catalog-v2.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    expect(manifest['contractVersion'], isA<String>());
    expect((manifest['contractVersion'] as String).isNotEmpty, isTrue);
    expect(manifest['coreCommit'], isA<String>());
    expect(
        manifest['openApiHash'], _fileHash('tool/core_contracts/openapi.json'));
    expect(
      manifest['fieldSchemaHash'],
      _fileHash('tool/core_contracts/metadata-field-schema.json'),
    );
    expect(
      manifest['catalogItemV2Hash'],
      _fileHash('tool/core_contracts/catalog-item-v2.json'),
    );
    expect(
      manifest['activeKindsHash'],
      _fileHash('tool/core_contracts/active-kinds.json'),
    );
    final coreManifest =
        File(r'..\collectarr-core\contracts\contract-manifest.json');
    if (coreManifest.existsSync()) {
      expect(manifest, jsonDecode(coreManifest.readAsStringSync()));
    }

    expect(
      Set<String>.from(activeKinds['kinds'] as List<dynamic>),
      equals({
        'comic',
        'manga',
        'anime',
        'book',
        'game',
        'boardgame',
        'movie',
        'tv',
        'music',
      }),
    );
    expect(fieldSchema['contractVersion'], manifest['contractVersion']);
    expect(fieldSchema['fields'], isNotEmpty);
    expect(catalogItemSchema['schemaVersion'], 2);
    expect(catalogItemSchema['contractVersion'], '2.0.0');
    final catalogKinds = catalogItemSchema['kinds'] as Map<String, dynamic>;
    expect(
      catalogItemV2FieldsByKind.keys.toSet(),
      catalogKinds.keys.toSet(),
    );
    for (final entry in catalogKinds.entries) {
      final kindSchema = entry.value as Map<String, dynamic>;
      final properties = kindSchema['properties'] as Map<String, dynamic>;
      expect(
        catalogItemV2FieldsByKind[entry.key],
        properties.keys.toSet(),
        reason: 'Generated App fields drifted for ${entry.key}.',
      );
    }
    expect(catalogKinds.keys, contains('music'));
    final musicSchema = catalogKinds['music'] as Map<String, dynamic>;
    final musicProperties = musicSchema['properties'] as Map<String, dynamic>;
    expect(musicProperties.keys, contains('discs'));
    expect(musicProperties.keys, contains('credits'));
    expect(musicProperties.keys, contains('original_release_date'));
    final musicDefinitions = musicContract[r'$defs'] as Map<String, dynamic>;
    final musicDiscSchema =
        musicDefinitions['CatalogMusicDiscResponse'] as Map<String, dynamic>;
    final formatFamilyRule = (musicDiscSchema['allOf'] as List<dynamic>).single
        as Map<String, dynamic>;
    expect(formatFamilyRule['if'], {
      'properties': {
        'format': {'type': 'string'},
      },
      'required': ['format'],
    });
    expect(
      (formatFamilyRule['then'] as Map<String, dynamic>)['required'],
      ['format_family'],
    );
    for (final field in [
      'recording_date',
      'studios',
      'is_live',
      'spars_code',
      'composers',
      'conductors',
      'choruses',
      'compositions',
      'orchestras',
      'songwriters',
      'producers',
      'engineers',
      'musicians',
    ]) {
      expect(musicProperties, isNot(containsPair(field, anything)));
    }
    expect(
        musicProperties.keys, isNot(contains('original_release_date_parts')));
    expect(musicProperties, isNot(containsPair('recording_id', anything)));
    final fields =
        (fieldSchema['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
    Map<String, dynamic>? fieldFor(String key, String kind) {
      for (final field in fields) {
        if (field['key'] == key && field['kind'] == kind) {
          return field;
        }
      }
      return null;
    }

    expect(fieldFor('title', 'game')?['editable'], isTrue);
    expect(fieldFor('title', 'game')?['valueType'], 'string');
  });
}

String _fileHash(String path) {
  return sha256.convert(File(path).readAsBytesSync()).toString();
}
