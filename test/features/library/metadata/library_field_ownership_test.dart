import 'package:collectarr_app/features/library/metadata/library_field_ownership.dart';
import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical metadata and personal library fields stay disjoint', () {
    final canonicalKeys = kCanonicalMetadataFieldKeys.toSet();
    final personalKeys =
        kPersonalLibraryFields.map((field) => field.key).toSet();

    expect(canonicalKeys.intersection(personalKeys), isEmpty);
    expect(personalKeys, contains('collection_status'));
    expect(personalKeys, contains('owner_label'));
    expect(personalKeys, contains('front_cover'));
    expect(personalKeys, contains('back_cover'));
  });

  test('syncable personal fields are owned by the app', () {
    final canonicalKeys = kCanonicalMetadataFieldKeys.toSet();
    final personalKeys =
        kPersonalLibraryFields.map((field) => field.key).toSet();
    final syncableKeys =
        kSyncablePersonalFields.map((field) => field.key).toSet();

    expect(syncableKeys.difference(personalKeys), isEmpty);
    expect(syncableKeys.intersection(canonicalKeys), isEmpty);
    expect(syncableKeys, contains('condition'));
    expect(syncableKeys, contains('rating'));
    expect(syncableKeys, contains('personal_notes'));
    expect(syncableKeys, contains('front_cover'));
    expect(syncableKeys, contains('back_cover'));
  });
}
