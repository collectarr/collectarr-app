import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';

import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';

import 'catalog_item_builder.dart';
import 'library_entry_builder.dart';

LibraryWorkspaceContext testLibraryWorkspaceContext({
  String itemId = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  CatalogItemDto? catalogItem,
  LibraryWorkspaceKindData? catalogData,
  TestLibraryEntry? libraryEntry,
  WishlistItem? wishlistItem,
  String? locationPath,
}) {
  final resolvedCatalogItem = catalogItem ??
      testCatalogItem(
        id: itemId,
        kind: kind,
        title: title,
      );
  final mediaKind = catalogMediaKindFromApiValue(kind);
  final libraryEntryDispatch =
      libraryEntry == null ? null : testLibraryEntryDispatchFrom(libraryEntry);
  return LibraryWorkspaceContext(
    item: WorkspaceItem(
      target: CatalogTargetRef(CatalogItemRef(kind: mediaKind, id: itemId)),
      presentation: CatalogDisplaySummary(
        ref: CatalogItemRef(kind: mediaKind, id: itemId),
        kind: mediaKind,
        primaryLabel:
            (resolvedCatalogItem.kindData['title'] as String?) ?? title,
      ),
      kindPresentationData:
          catalogData ?? testWorkspaceCatalogData(resolvedCatalogItem),
      entrySummary:
          libraryEntry == null ? null : testLibraryEntrySummary(libraryEntry),
      libraryEntryDispatch: libraryEntryDispatch,
    ),
    personal: PersonalOverlay(
      wishlist: wishlistItem,
      locationPath: locationPath,
    ),
  );
}

LibraryWorkspaceContext testLibraryWorkspaceSource({
  required String itemId,
  String kind = 'comic',
  String title = 'Test Item',
  CatalogItemDto? catalogItem,
  LibraryWorkspaceKindData? catalogData,
  TestLibraryEntry? libraryEntry,
  LibraryEntrySummary? libraryEntrySummary,
  WishlistItem? wishlistItem,
  String? locationPath,
}) {
  final resolvedCatalogItem = catalogItem ??
      testCatalogItem(
        id: itemId,
        kind: kind,
        title: title,
      );
  final mediaKind = catalogMediaKindFromApiValue(kind);
  final libraryEntryDispatch =
      libraryEntry == null ? null : testLibraryEntryDispatchFrom(libraryEntry);
  return LibraryWorkspaceContext(
    item: WorkspaceItem(
      target: CatalogTargetRef(CatalogItemRef(kind: mediaKind, id: itemId)),
      presentation: CatalogDisplaySummary(
        ref: CatalogItemRef(kind: mediaKind, id: itemId),
        kind: mediaKind,
        primaryLabel:
            (resolvedCatalogItem.kindData['title'] as String?) ?? title,
      ),
      kindPresentationData:
          catalogData ?? testWorkspaceCatalogData(resolvedCatalogItem),
      entrySummary: libraryEntrySummary ??
          (libraryEntry == null ? null : testLibraryEntrySummary(libraryEntry)),
      libraryEntryDispatch: libraryEntryDispatch,
    ),
    personal: PersonalOverlay(
      wishlist: wishlistItem,
      locationPath: locationPath,
    ),
  );
}
