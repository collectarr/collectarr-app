import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

const _registration = ComicRegistration();

LibraryProjectionItem _issue(String number) => LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
        item: WorkspaceItem(
          target: CatalogTargetRef(
            CatalogItemRef(kind: CatalogMediaKind.comic, id: 'issue-$number'),
          ),
          kindPresentationData: ComicWorkspaceData(
            comic: ComicCatalogItem(
              id: CatalogItemRef(
                  kind: CatalogMediaKind.comic, id: 'issue-$number'),
              title: '',
              seriesTitle: 'AJIN',
              issueNumber: number,
              coverImageUrl: 'https://covers.test/$number.jpg',
            ),
          ),
        ),
        personal: const PersonalOverlay(),
      ),
      _registration,
    );

void main() {
  test('a series folder shows its first issue cover in any item order', () {
    final buckets = const LibraryGroupingEngine().buildBuckets(
      [_issue('17'), _issue('3'), _issue('1'), _issue('12')],
      _registration,
      ComicGroupIds.series,
    );
    expect(buckets.singleWhere((bucket) => bucket.title == 'AJIN').coverUrl,
        'https://covers.test/1.jpg');
  });
}
