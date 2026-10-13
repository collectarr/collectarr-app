import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin shared metadata fields use unique keys', () {
    final keys = kAdminMetadataScalarFields.map((field) => field.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('shared tabs stay represented in admin field contract', () {
    final tabs = kAdminMetadataScalarFields.map((field) => field.tab).toSet();
    expect(tabs, containsAll(SharedMetadataEditTab.values));
  });

  test('shared metadata helpers return tab-scoped field groups', () {
    final grouped = groupSharedMetadataFieldsByTab();
    expect(grouped[SharedMetadataEditTab.item], isNotEmpty);
    expect(grouped[SharedMetadataEditTab.relations], isNotEmpty);
    expect(
      sharedMetadataFieldByKey('title')?.tab,
      SharedMetadataEditTab.item,
    );
  });

  test('typed admin fields keep expected value types', () {
    SharedMetadataFieldDescriptor byKey(String key) =>
        kAdminMetadataScalarFields.firstWhere((field) => field.key == key);

    expect(
      byKey('release_date').valueType,
      SharedMetadataFieldValueType.partialDate,
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
      commonFields: [],
      kindFields: {
        'music': ['genres']
      },
      valueTypes: {'genres': 'string_list'},
    );

    final drift = compareSharedContractWithManifest(manifest);
    expect(drift.isInSync, isTrue);
    expect(drift.mismatchCount, 0);
  });

  test('normalized contract comparator reports extra core keys', () {
    final manifest = const MetadataNormalizedManifest(
      schemaVersion: 1,
      commonFields: ['audience_rating', 'unknown_new_field'],
      kindFields: {
        'comic': ['genres'],
      },
      valueTypes: {
        'audience_rating': 'string',
        'genres': 'string_list',
        'unknown_new_field': 'string',
      },
    );

    final drift = compareSharedContractWithManifest(manifest);
    expect(drift.isInSync, isFalse);
    expect(drift.extraInCore, contains('unknown_new_field'));
  });
}
