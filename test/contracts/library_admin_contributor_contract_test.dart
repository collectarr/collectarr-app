import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/metadata_field_id.dart';
import 'package:collectarr_app/features/library/config/library_metadata_correction_source.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers one admin contributor for every concrete kind', () {
    final contributors = libraryAdminContributors.toList(growable: false);

    expect(
      contributors.map((contributor) => contributor.kind).toSet(),
      CatalogMediaKind.values.where((kind) => !kind.isUnknown).toSet(),
    );
    for (final contributor in contributors) {
      final keys = contributor.proposalFields.map((field) => field.key);
      expect(keys.toSet().length, keys.length,
          reason: '${contributor.kind.apiValue} has duplicate field keys');
      for (final field in contributor.proposalFields) {
        expect(field.key.trim(), isNotEmpty);
        expect(field.label.trim(), isNotEmpty);
        expect(field.minLines, greaterThanOrEqualTo(1));
        expect(field.maxLines, greaterThanOrEqualTo(field.minLines));
      }

      final overrideFields = contributor.metadataOverrideFields;
      final overrideIds = overrideFields.map((field) => field.id);
      expect(
        overrideIds.toSet().length,
        overrideIds.length,
        reason: '${contributor.kind.apiValue} has duplicate override fields',
      );
      expect(
        overrideFields.map((field) => field.id.value),
        contains('title'),
      );
      for (final field in overrideFields) {
        expect(field.id.kind, contributor.kind);
        expect(field.id, isA<MetadataFieldId>());
        expect(field.id.value.trim(), isNotEmpty);
        expect(field.label.trim(), isNotEmpty);
      }
    }
  });

  test('Game owns the platform proposal payload codec', () {
    final contributor = libraryAdminContributorForKind(CatalogMediaKind.game)!;
    final field = contributor.proposalFields
        .singleWhere((field) => field.key == 'platforms');
    final values = LibraryMetadataCorrectionValues.fromSerialized({
      'platforms': ['Switch'],
    });

    expect(field.read(values), 'Switch');
    field.write(values, 'PlayStation 5, Nintendo Switch');
    expect(values.read('platforms'), ['PlayStation 5', 'Nintendo Switch']);
  });

  test('Music owns the track proposal payload codec and validation', () {
    final contributor = libraryAdminContributorForKind(CatalogMediaKind.music)!;
    final field = contributor.proposalFields
        .singleWhere((field) => field.key == 'tracks');
    final values = LibraryMetadataCorrectionValues.fromSerialized({
      'tracks': [
        {
          'id': 'track-1',
          'disc_id': 'disc-1',
          'title': 'Intro',
          'artist': 'Band',
          'disc_number': 1,
          'position': 2,
          'position_order': 0,
          'duration_ms': 90000,
          'is_header': false,
          'parent_header_id': null,
          'indent_level': 0,
        },
      ],
    });

    expect(field.read(values), 'Intro | Band | 1 | 2 | 90 | false');
    field.write(values, 'Outro | Band | 1 | 3 | 120');
    final track = (values.read('tracks') as List).single as Map;
    expect(track, containsPair('title', 'Outro'));
    expect(track, containsPair('artist', 'Band'));
    expect(track, containsPair('disc_id', 'disc-1'));
    expect(track, containsPair('disc_number', 1));
    expect(track, containsPair('position', '3'));
    expect(track, containsPair('duration_ms', 120000));
    expect(track, containsPair('is_header', false));
    expect(track, contains('id'));
    expect(
      () => field.write(values, 'Broken | Band | one'),
      throwsA(isA<FormatException>()),
    );
  });

  test('unknown kind has no semantic admin contribution', () {
    expect(libraryAdminContributorForKind(CatalogMediaKind.unknown), isNull);
  });
}
