import 'package:collectarr_app/features/library/metadata/shared_metadata_editing_contract.dart';
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
}
