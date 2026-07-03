import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('variant anchor type without IDs falls back to item', () {
    final anchor = PersonalItemAnchor.fromRaw(anchorType: 'variant');

    expect(anchor?.type, PersonalItemAnchorType.item);
    expect(anchor?.editionId, isNull);
    expect(anchor?.variantId, isNull);
  });

  test('variant anchor type still resolves to edition when only edition id exists', () {
    final anchor = PersonalItemAnchor.fromRaw(
      anchorType: 'variant',
      editionId: 'edition-1',
    );

    expect(anchor?.type, PersonalItemAnchorType.edition);
    expect(anchor?.editionId, 'edition-1');
    expect(anchor?.variantId, isNull);
  });
}