import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
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
          'title': 'Intro',
          'artist': 'Band',
          'disc_number': 1,
          'position': 2,
          'duration_seconds': 90,
        },
      ],
    });

    expect(field.read(values), 'Intro | Band | 1 | 2 | 90');
    field.write(values, 'Outro | Band | 1 | 3 | 120');
    expect(values.read('tracks'), [
      {
        'title': 'Outro',
        'artist': 'Band',
        'disc_number': 1,
        'position': 3,
        'duration_seconds': 120,
      },
    ]);
    expect(
      () => field.write(values, 'Broken | Band | one'),
      throwsA(isA<FormatException>()),
    );
  });

  test('unknown kind has no semantic admin contribution', () {
    expect(libraryAdminContributorForKind(CatalogMediaKind.unknown), isNull);
  });
}
