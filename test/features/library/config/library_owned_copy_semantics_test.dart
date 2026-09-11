import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  test('every kind owns explicit digital-copy resolution', () {
    for (final type in collectarrKindRegistrationsList) {
      final digital = testOwnedItem(
        id: '${type.kind.apiValue}-digital',
        itemId: '${type.kind.apiValue}-item',
        kind: type.kind.apiValue,
        isDigital: true,
      );
      final physical = testOwnedItem(
        id: '${type.kind.apiValue}-physical',
        itemId: '${type.kind.apiValue}-item',
        kind: type.kind.apiValue,
        isDigital: false,
      );

      expect(
        type.edit.resolveOwnedDigitalFlag(
          testOwnedItemSummary(digital),
          const [],
        ),
        isTrue,
        reason: type.kind.apiValue,
      );
      expect(
        type.edit.resolveOwnedDigitalFlag(
          testOwnedItemSummary(physical),
          const [],
        ),
        isFalse,
        reason: type.kind.apiValue,
      );
    }
  });
}
