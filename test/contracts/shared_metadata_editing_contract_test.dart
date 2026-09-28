import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
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
      byKey('page_count').valueType,
      SharedMetadataFieldValueType.integer,
    );
    expect(
      byKey('runtime_minutes').valueType,
      SharedMetadataFieldValueType.integer,
    );
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
}
