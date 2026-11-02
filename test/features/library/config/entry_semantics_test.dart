import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/builders/library_entry_builder.dart';

void main() {
  test('every kind owns explicit digital-copy resolution', () {
    for (final type in collectarrKindRegistrationsList) {
      final digital = testLibraryEntry(
        id: '${type.kind.apiValue}-digital',
        itemId: '${type.kind.apiValue}-item',
        kind: type.kind.apiValue,
        isDigital: true,
      );
      final physical = testLibraryEntry(
        id: '${type.kind.apiValue}-physical',
        itemId: '${type.kind.apiValue}-item',
        kind: type.kind.apiValue,
        isDigital: false,
      );

      expect(
        libraryEntryEditForKind(type.kind).resolveEntryDigitalFlag(
          testLibraryEntrySummary(digital),
        ),
        type.kind == CatalogMediaKind.gameHardware ||
                type.kind == CatalogMediaKind.gameToy
            ? isFalse
            : isTrue,
        reason: type.kind.apiValue,
      );
      expect(
        libraryEntryEditForKind(type.kind).resolveEntryDigitalFlag(
          testLibraryEntrySummary(physical),
        ),
        isFalse,
        reason: type.kind.apiValue,
      );
    }
  });
}
