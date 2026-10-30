import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/body.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/alphabet_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _registration = ComicRegistration();

LibraryProjectionItem _comic(String id, ComicCatalogItem comic) =>
    LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
        item: WorkspaceItem(
          target: CatalogTargetRef(
              CatalogItemRef(kind: CatalogMediaKind.comic, id: id)),
          kindPresentationData: ComicWorkspaceData(comic: comic),
        ),
        personal: const PersonalOverlay(),
      ),
      _registration,
    );

void main() {
  test('letters pick series past a leading article, then titles', () {
    final items = [
      _comic('1',
          const ComicCatalogItem(title: 'Zebra', seriesTitle: 'The Art of X')),
      _comic('2', const ComicCatalogItem(title: 'Apple', seriesTitle: 'Zoo')),
    ];
    expect(
        comicAlphabetFields.map((field) => field.label), ['Series', 'Title']);
    expect(libraryItemsForLetter(items, comicAlphabetFields.first, 'A'),
        [items.first]);
    expect(libraryItemsForLetter(items, comicAlphabetFields.last, 'A'),
        [items.last]);
  });
}
