import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:flutter/material.dart';

/// The entity-level actions a kind intentionally exposes for one scope.
///
/// Workspace actions such as sorting, grouping, columns, and printing do not
/// belong here. They are registered by the workspace toolbar instead.
final class LibraryEntityActionSet {
  const LibraryEntityActionSet({
    this.addCopy = false,
    this.openDetails = false,
    this.selectOwnedItem = false,
    this.toggleOwned = false,
    this.toggleWishlist = false,
    this.edit = false,
    this.duplicate = false,
    this.loan = false,
    this.refreshMetadata = false,
    this.share = false,
    this.unlinkFromCore = false,
  });

  static const work = LibraryEntityActionSet(
    addCopy: true,
    openDetails: true,
    selectOwnedItem: true,
    toggleOwned: true,
    toggleWishlist: true,
    edit: true,
    refreshMetadata: true,
    share: true,
  );

  static const release = LibraryEntityActionSet(
    addCopy: true,
    openDetails: true,
    selectOwnedItem: true,
    toggleOwned: true,
    toggleWishlist: true,
    edit: true,
    refreshMetadata: true,
    share: true,
  );

  static const copy = LibraryEntityActionSet(
    openDetails: true,
    selectOwnedItem: true,
    toggleOwned: true,
    edit: true,
    duplicate: true,
    loan: true,
    refreshMetadata: true,
    share: true,
  );

  final bool addCopy;
  final bool openDetails;
  final bool selectOwnedItem;
  final bool toggleOwned;
  final bool toggleWishlist;
  final bool edit;
  final bool duplicate;
  final bool loan;
  final bool refreshMetadata;
  final bool share;
  final bool unlinkFromCore;
}

/// Runtime callbacks supplied by the generic host to a kind-owned action
/// capability. The host owns lifecycle and navigation mechanics; the kind
/// decides which callbacks are legal at each entity scope.
final class LibraryEntityActionContext {
  const LibraryEntityActionContext({
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.ownedCopies,
    required this.onAddCopy,
    required this.onOpenDetails,
    required this.onSelectOwnedItem,
    required this.onToggleOwned,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onDuplicate,
    required this.onLoan,
    required this.onRefreshMetadata,
    required this.onShare,
    required this.onUnlinkFromCore,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final OwnedItemSummary? ownedItem;
  final List<OwnedItemSummary> ownedCopies;
  final VoidCallback? onAddCopy;
  final VoidCallback? onOpenDetails;
  final ValueChanged<OwnedItemRef>? onSelectOwnedItem;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onLoan;
  final VoidCallback? onRefreshMetadata;
  final VoidCallback? onShare;
  final VoidCallback? onUnlinkFromCore;
}

/// Kind-owned entity action registration.
final class LibraryEntityActionCapability {
  const LibraryEntityActionCapability({
    required this.work,
    required this.release,
    required this.copy,
  });

  final LibraryEntityActionSet work;
  final LibraryEntityActionSet release;
  final LibraryEntityActionSet copy;

  LibraryEntityActionRegistry build(LibraryEntityActionContext context) {
    return LibraryEntityActionRegistry(
      contributors: [
        LibraryEntityActionContributor(
          scope: LibraryEntityScope.work,
          actions: _buildActions(work, context),
        ),
        LibraryEntityActionContributor(
          scope: LibraryEntityScope.release,
          actions: _buildActions(release, context),
        ),
        LibraryEntityActionContributor(
          scope: LibraryEntityScope.copy,
          actions: _buildActions(copy, context),
        ),
      ],
    );
  }

  LibraryItemActions _buildActions(
    LibraryEntityActionSet actionSet,
    LibraryEntityActionContext context,
  ) {
    return LibraryItemActions(
      onAddCopy: actionSet.addCopy ? context.onAddCopy : null,
      onOpenDetails: actionSet.openDetails ? context.onOpenDetails : null,
      onSelectOwnedItem:
          actionSet.selectOwnedItem ? context.onSelectOwnedItem : null,
      onToggleOwned: actionSet.toggleOwned ? context.onToggleOwned : null,
      onToggleWishlist:
          actionSet.toggleWishlist ? context.onToggleWishlist : null,
      onEdit: actionSet.edit ? context.onEdit : null,
      onDuplicate: actionSet.duplicate ? context.onDuplicate : null,
      onLoan: actionSet.loan ? context.onLoan : null,
      onRefreshMetadata:
          actionSet.refreshMetadata ? context.onRefreshMetadata : null,
      onShare: actionSet.share ? context.onShare : null,
      onUnlinkFromCore:
          actionSet.unlinkFromCore ? context.onUnlinkFromCore : null,
    );
  }
}
