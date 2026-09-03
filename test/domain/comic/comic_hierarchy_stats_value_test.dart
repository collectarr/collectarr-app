import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/stats/comic_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/value/comic_value_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Comic stats count only owned key comics', () {
    final entries = [
      testShelfEntry(
        itemId: 'comic-1',
        ownedItem: testOwnedItem(
          itemId: 'comic-1',
          keyComic: true,
          kind: 'comic',
        ),
      ),
      testShelfEntry(
        itemId: 'comic-2',
        ownedItem: testOwnedItem(itemId: 'comic-2', kind: 'comic'),
      ),
      testShelfEntry(
        itemId: 'comic-3',
        ownedItem: null,
      ),
    ];

    expect(ComicStatsCapability.countKeyComics(entries), 1);
  });

  test('Comic value capability summarizes cover prices and currencies', () {
    final entries = [
      testShelfEntry(
        itemId: 'comic-1',
        ownedItem: testOwnedItem(
          itemId: 'comic-1',
          kind: 'comic',
          coverPriceCents: 1200,
          currency: 'USD',
        ),
      ),
      testShelfEntry(
        itemId: 'comic-2',
        ownedItem: testOwnedItem(
          itemId: 'comic-2',
          kind: 'comic',
          coverPriceCents: 800,
          currency: 'USD',
        ),
      ),
      testShelfEntry(
        itemId: 'comic-3',
        ownedItem: testOwnedItem(
          itemId: 'comic-3',
          kind: 'comic',
          coverPriceCents: 500,
        ),
      ),
    ];

    final summary =
        const ComicValueCapability().resolveCollectionValueSummary(entries);

    expect(summary?.valuedCount, 2);
    expect(summary?.totalValueCents, 2000);
    expect(summary?.currency, 'USD');
    expect(summary?.hasMixedCurrencies, isFalse);
  });

  test('Comic hierarchy diagnostics are owned by the Comic module', () {
    final complete = _comicProjection(
      id: 'complete',
      seriesTitle: 'Saga',
      variant: 'A',
    );
    final missingSeries = _comicProjection(id: 'missing-series');
    final missingVariant = _comicProjection(
      id: 'missing-variant',
      seriesTitle: 'Saga',
      node: const LibraryCopyNodeRef(
          titleItemId: 'missing-variant', ownedItemId: 'owned-missing-variant'),
    );

    expect(libraryHierarchyContractDiagnosticLabel(complete), isNull);
    expect(
      libraryHierarchyContractDiagnosticLabel(missingSeries),
      'Missing series title',
    );
    expect(
      libraryHierarchyContractDiagnosticLabel(missingVariant),
      'Missing release variant',
    );
  });

  test('Comic owns its cover-price transfer field', () {
    expect(kTransferableReleaseFieldKeys, isNot(contains('coverPriceCents')));
    expect(
      comicKindModule.transfer.fieldKeysForScope(LibraryEditScope.release),
      contains('coverPriceCents'),
    );
  });
}

LibraryProjectionItem<ComicWorkspaceDto> _comicProjection({
  required String id,
  String? seriesTitle,
  String? variant,
  LibraryNodeRef? node,
}) {
  final source = testShelfEntry(
    itemId: id,
    catalogItem: testCatalogItem(
      id: id,
      kind: 'comic',
      series: seriesTitle == null
          ? null
          : CatalogSeriesDetailsDto(seriesTitle: seriesTitle),
      variant: variant,
    ),
  );
  final titleNode = LibraryTitleNodeRef(titleItemId: id);
  final dto = comicKindModule.projector.projectTitle(
    source: source,
    node: titleNode,
  );
  return LibraryProjectionItem(
    source: source,
    node: node ?? titleNode,
    dto: dto,
  );
}
