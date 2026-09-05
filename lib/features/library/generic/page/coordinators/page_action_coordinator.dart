import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/session/library_workspace_session_controller.dart';

/// Clean coordinator carrying real dependencies for library page actions.
final class LibraryPageActionCoordinator {
  const LibraryPageActionCoordinator({
    required this.session,
    required this.ownedMutations,
    required this.wishlistMutations,
    required this.trackingMutations,
    required this.catalogCache,
    required this.kindRuntime,
  });

  final LibraryWorkspaceSessionController session;
  final OwnedItemMutations ownedMutations;
  final WishlistMutations wishlistMutations;
  final TrackingMutations trackingMutations;
  final LibraryCatalogRepository catalogCache;
  final LibraryKindRuntime kindRuntime;

  void updateSearch(String query) => session.updateSearch(query);

  void updateSort(String sortId, {bool? ascending}) => session.updateSort(
        kindRuntime.fields.decodeSortId(sortId),
        ascending: ascending,
      );

  void updateGroup(String? groupMode) => session.updateGroup(
        groupMode == null ? null : kindRuntime.fields.decodeGroupId(groupMode),
      );

  void toggleColumn(String columnId) => session.toggleColumn(
        kindRuntime.fields.decodeColumnId(columnId),
      );

  void selectItem(String itemId, {bool multiSelect = false}) =>
      session.selectItem(itemId, multiSelect: multiSelect);

  void clearSelection() => session.clearSelection();

  void reload() => session.reload();
}
