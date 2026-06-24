import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin shared metadata fields use unique keys', () {
    final keys = kAdminMetadataScalarFields.map((field) => field.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('proposal correction fields expose expected shared keys', () {
    final keys = kProposalCorrectionFields.map((field) => field.key).toSet();
    expect(
      keys,
      containsAll(<String>{
        'title',
        'item_number',
        'publisher',
        'release_year',
        'barcode',
        'variant',
        'source_url',
        'notes',
      }),
    );
  });

  test('shared tabs stay represented in admin field contract', () {
    final tabs = kAdminMetadataScalarFields.map((field) => field.tab).toSet();
    expect(tabs, containsAll(SharedMetadataEditTab.values));
  });

  test('typed admin fields keep expected value types', () {
    SharedMetadataFieldDescriptor byKey(String key) =>
        kAdminMetadataScalarFields.firstWhere((field) => field.key == key);

    expect(
      byKey('page_count').valueType,
      SharedMetadataFieldValueType.integer,
    );
    expect(
      byKey('runtime_minutes').valueType,
      SharedMetadataFieldValueType.integer,
    );
    expect(
      byKey('release_date').valueType,
      SharedMetadataFieldValueType.date,
    );
    expect(
      byKey('genres').valueType,
      SharedMetadataFieldValueType.stringList,
    );
    expect(
      byKey('title').valueType,
      SharedMetadataFieldValueType.text,
    );
  });

  test('normalized contract comparator reports in-sync manifest', () {
    final manifest = const MetadataNormalizedManifest(
      schemaVersion: 1,
      commonFields: ['audience_rating'],
      kindFields: {
        'comic': ['genres'],
        'game': ['platforms'],
        'movie': [
          'color',
          'nr_discs',
          'screen_ratio',
          'audio_tracks',
          'subtitles',
          'layers'
        ],
      },
      valueTypes: {
        'audience_rating': 'string',
        'genres': 'string_list',
        'platforms': 'string_list',
        'color': 'string',
        'nr_discs': 'integer',
        'screen_ratio': 'string',
        'audio_tracks': 'string',
        'subtitles': 'string',
        'layers': 'string',
      },
    );

    final drift = compareSharedContractWithManifest(manifest);
    expect(drift.isInSync, isTrue);
    expect(drift.mismatchCount, 0);
  });
}
