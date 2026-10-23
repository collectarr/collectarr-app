import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_library_entry_workspace_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const family = [
    CatalogMediaKind.game,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy,
  ];

  test('Games family column favorites follow the reference', () {
    for (final kind in family) {
      final presentation = libraryPresentationForKind(kind);
      final columns = {
        for (final column
            in libraryKindWorkspaceForKind(kind).workspaceFields.columns)
          column.id.value,
      };
      expect(presentation.columnFavorites.map((preset) => preset.label), [
        'My List View columns',
        'My Find Duplicates columns',
        'My Print / Export columns',
      ]);
      for (final preset in presentation.columnFavorites) {
        expect(columns, containsAll(preset.columns),
            reason: '$kind ${preset.label}');
      }
      expect(columns, containsAll(presentation.duplicateColumns!),
          reason: '$kind duplicates');
    }
  });

  test('Games columns offer the reference column chooser fields', () {
    final columns = {
      for (final column in gameLibraryEntryWorkspaceSchema.columns)
        column.displayName ?? column.metadata.label: column.group,
    };
    const expected = {
      'Front Cover': 'Images',
      'Has Front Cover': 'Images',
      'Has Back Cover': 'Images',
      'Audience Rating': 'Main',
      'Release Year': 'Main',
      'Series': 'Main',
      'Sort Title': 'Main',
      'Box': 'Value',
      'Completeness': 'Value',
      'Manual': 'Value',
      'PriceCharting ID': 'Value',
      'Purchase Date': 'Value',
      'Purchase Price': 'Value',
      'Purchase Store': 'Value',
      'Purchase Year': 'Value',
      'Value': 'Value',
      'Value CiB': 'Value',
      'Value Graded': 'Value',
      'Value Locked': 'Value',
      'Value Loose': 'Value',
      'Value New': 'Value',
      'Barcode': 'Edition',
      'Core Region': 'Edition',
      'Edition': 'Edition',
      'Format': 'Edition',
      'Region': 'Edition',
      'Added Date/Time': 'Personal',
      'Added Year': 'Personal',
      'Collection Status': 'Personal',
      'Completed': 'Personal',
      'Completed Date': 'Personal',
      'Completed Year': 'Personal',
      'Index': 'Personal',
      'Location': 'Personal',
      'Modified Date': 'Personal',
      'Modified Date/Time': 'Personal',
      'My Rating': 'Personal',
      'Notes': 'Personal',
      'Owner': 'Personal',
      'Quantity': 'Personal',
      'Storage': 'Personal',
      'Tags': 'Personal',
      'Loaned To': 'Loan',
      'Loan Date': 'Loan',
      'Due Date': 'Loan',
    };
    for (final MapEntry(:key, :value) in expected.entries) {
      expect(columns[key], value, reason: key);
    }
  });
}
