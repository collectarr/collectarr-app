import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/catalog_edit_metadata.dart';
import 'package:collectarr_app/core/models/catalog_target_option.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

abstract interface class LibraryItemActionRunner {
  Future<void> addCopy();
  Future<void> openDetails();
  Future<void> selectOwnedItem(OwnedItemRef ref);
  Future<void> toggleOwned();
  Future<void> toggleWishlist();
  Future<void> edit();
  Future<void> correctMetadata();
  Future<void> duplicate();
  Future<void> loan();
  Future<void> refreshMetadata();
  Future<void> share();
  Future<void> unlinkFromCore();
}

/// Entity actions are separate from workspace actions such as sorting,
/// grouping, printing, and column management.
final class LibraryEntityActionContributor {
  const LibraryEntityActionContributor({
    required this.scope,
    required this.actions,
  });

  final LibraryEntityScope scope;
  final LibraryItemActionRunner actions;
}

final class LibraryEntityActionRegistry {
  const LibraryEntityActionRegistry({
    this.contributors = const [],
  });

  final List<LibraryEntityActionContributor> contributors;

  LibraryItemActionRunner? actionsForScope(LibraryEntityScope scope) {
    for (final contributor in contributors) {
      if (contributor.scope == scope) return contributor.actions;
    }
    return null;
  }
}

class LibraryItemActions implements LibraryItemActionRunner {
  const LibraryItemActions({
    this.onAddCopy,
    this.onOpenDetails,
    this.onSelectOwnedItem,
    this.onToggleOwned,
    this.onToggleWishlist,
    this.onEdit,
    this.onCorrectMetadata,
    this.onDuplicate,
    this.onLoan,
    this.onRefreshMetadata,
    this.onShare,
    this.onUnlinkFromCore,
  });

  final VoidCallback? onAddCopy;
  final VoidCallback? onOpenDetails;
  final ValueChanged<OwnedItemRef>? onSelectOwnedItem;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback? onCorrectMetadata;
  final VoidCallback? onDuplicate;
  final VoidCallback? onLoan;
  final VoidCallback? onRefreshMetadata;
  final VoidCallback? onShare;
  final VoidCallback? onUnlinkFromCore;

  @override
  Future<void> addCopy() async => onAddCopy?.call();

  @override
  Future<void> openDetails() async => onOpenDetails?.call();

  @override
  Future<void> selectOwnedItem(OwnedItemRef ref) async =>
      onSelectOwnedItem?.call(ref);

  @override
  Future<void> toggleOwned() async => onToggleOwned?.call();

  @override
  Future<void> toggleWishlist() async => onToggleWishlist?.call();

  @override
  Future<void> edit() async => onEdit?.call();

  @override
  Future<void> correctMetadata() async => onCorrectMetadata?.call();

  @override
  Future<void> duplicate() async => onDuplicate?.call();

  @override
  Future<void> loan() async => onLoan?.call();

  @override
  Future<void> refreshMetadata() async => onRefreshMetadata?.call();

  @override
  Future<void> share() async => onShare?.call();

  @override
  Future<void> unlinkFromCore() async => onUnlinkFromCore?.call();
}

class LibraryAddDialogRequest {
  const LibraryAddDialogRequest({
    required this.type,
    this.accent,
    this.initialQuery,
    this.initialIdentifier,
  });

  final LibraryKindRegistration type;
  final Color? accent;
  final String? initialQuery;
  final String? initialIdentifier;
}

class LibraryAddDialogResult {
  const LibraryAddDialogResult({
    required this.target,
    required this.itemIds,
  });

  final LibraryAddTarget target;
  final List<String> itemIds;
}

typedef LibraryAddDialogLauncher = Future<LibraryAddDialogResult?> Function(
  BuildContext context,
  LibraryAddDialogRequest request,
);

class LibraryEditDialogRequest {
  LibraryEditDialogRequest({
    required this.type,
    required CatalogSearchCandidate item,
    this.node,
    required this.ownedItem,
    this.ownedItemDispatch,
    required this.accent,
    this.scope,
    this.wishlistItem,
    this.trackingSummary,
    this.wishlistTargetOptions = const [],
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
    this.onPrevious,
    this.onNext,
    this.openMetadataCompareOnOpen = false,
    this.editPrimaryRelease = false,
  })  : item = item.editMetadata,
        kindItem = item;

  final LibraryKindRegistration type;

  /// Common metadata consumed by the shared edit host.
  final CatalogEditMetadata item;

  /// Full candidate retained for the concrete kind edit contribution.
  final CatalogSearchCandidate kindItem;

  /// Structural node being edited. Kind-owned dialogs use this to select a
  /// concrete release/copy without teaching the generic host Music semantics.
  final LibraryEntityRef? node;
  final OwnedItemSummary? ownedItem;

  /// Concrete kind-owned aggregate, present only after kind dispatch.
  /// Generic edit infrastructure must not decode or inspect this value.
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final Color accent;
  final LibraryEntityScope? scope;

  /// A concrete node is authoritative. Explicit scope is used for actions
  /// without a node (for example provider-candidate editing), and Work is
  /// the final structural default only when neither is available.
  LibraryEntityScope get resolvedScope =>
      node?.scope ?? scope ?? LibraryEntityScope.work;

  final WishlistItem? wishlistItem;
  final TrackingSummary? trackingSummary;
  final List<CatalogTargetOption> wishlistTargetOptions;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool openMetadataCompareOnOpen;

  /// Allows a kind-owned release editor to intentionally choose the primary
  /// release when no concrete release node was selected. A stale or explicit
  /// release reference must never use this fallback.
  final bool editPrimaryRelease;

  LibraryEditDialogRequest copyWith({
    LibraryKindRegistration? type,
    CatalogSearchCandidate? item,
    LibraryEntityRef? node,
    OwnedItemSummary? ownedItem,
    LibraryOwnedItemDispatch? ownedItemDispatch,
    Color? accent,
    LibraryEntityScope? scope,
    WishlistItem? wishlistItem,
    TrackingSummary? trackingSummary,
    List<CatalogTargetOption>? wishlistTargetOptions,
    List<PhysicalMediaFormat>? physicalFormats,
    List<CustomFieldDefinition>? customFieldDefinitions,
    List<CustomFieldValue>? customFieldValues,
    List<ItemImage>? itemImages,
    VoidCallback? onPrevious,
    VoidCallback? onNext,
    bool? openMetadataCompareOnOpen,
    bool? editPrimaryRelease,
  }) {
    return LibraryEditDialogRequest(
      type: type ?? this.type,
      item: item ?? kindItem,
      node: node ?? this.node,
      ownedItem: ownedItem ?? this.ownedItem,
      ownedItemDispatch: ownedItemDispatch ?? this.ownedItemDispatch,
      accent: accent ?? this.accent,
      scope: scope ?? this.scope,
      wishlistItem: wishlistItem ?? this.wishlistItem,
      trackingSummary: trackingSummary ?? this.trackingSummary,
      wishlistTargetOptions:
          wishlistTargetOptions ?? this.wishlistTargetOptions,
      physicalFormats: physicalFormats ?? this.physicalFormats,
      customFieldDefinitions:
          customFieldDefinitions ?? this.customFieldDefinitions,
      customFieldValues: customFieldValues ?? this.customFieldValues,
      itemImages: itemImages ?? this.itemImages,
      onPrevious: onPrevious ?? this.onPrevious,
      onNext: onNext ?? this.onNext,
      openMetadataCompareOnOpen:
          openMetadataCompareOnOpen ?? this.openMetadataCompareOnOpen,
      editPrimaryRelease: editPrimaryRelease ?? this.editPrimaryRelease,
    );
  }
}

typedef LibraryEditDialogBuilder = Widget Function(
  BuildContext context,
  LibraryEditDialogRequest request,
);

class LibraryDetailPageRequest {
  const LibraryDetailPageRequest({
    required this.type,
    required this.item,
    required this.ownedSummary,
    this.ownedItemDispatch,
    required this.accent,
    this.actions = const LibraryItemActions(),
    VoidCallback? onAddOwned,
    VoidCallback? onRemoveOwned,
    VoidCallback? onAddWishlist,
    VoidCallback? onRemoveWishlist,
    void Function(OwnedItemSummary? ownedItem)? onEdit,
    this.onFilterByValue,
  })  : _onAddOwned = onAddOwned,
        _onRemoveOwned = onRemoveOwned,
        _onAddWishlist = onAddWishlist,
        _onRemoveWishlist = onRemoveWishlist,
        _onEdit = onEdit;

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final OwnedItemSummary? ownedSummary;

  /// Concrete kind-owned aggregate available after Library kind dispatch.
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final Color accent;
  final LibraryItemActions actions;
  final ValueChanged<String>? onFilterByValue;

  final VoidCallback? _onAddOwned;
  final VoidCallback? _onRemoveOwned;
  final VoidCallback? _onAddWishlist;
  final VoidCallback? _onRemoveWishlist;
  final void Function(OwnedItemSummary? ownedItem)? _onEdit;

  VoidCallback? get onAddOwned => _onAddOwned ?? actions.onToggleOwned;
  VoidCallback? get onRemoveOwned => _onRemoveOwned ?? actions.onToggleOwned;
  VoidCallback? get onAddWishlist => _onAddWishlist ?? actions.onToggleWishlist;
  VoidCallback? get onRemoveWishlist =>
      _onRemoveWishlist ?? actions.onToggleWishlist;
  void Function(OwnedItemSummary? ownedItem)? get onEdit =>
      _onEdit ?? (actions.onEdit != null ? (_) => actions.onEdit!() : null);
}

typedef LibraryDetailPageBuilder = Widget Function(
  BuildContext context,
  LibraryDetailPageRequest request,
);

/// Optional kind-owned contribution rendered inside a media detail host.
///
/// The host owns page chrome and layout; the kind owns its semantic sections
/// and any provider-backed state needed to render them.
typedef LibraryMediaDetailContributionBuilder = Widget Function(
  BuildContext context,
  LibraryDetailPageRequest request,
);

class LibraryInspectorRequest {
  const LibraryInspectorRequest({
    required this.type,
    required this.item,
    required this.ownedItem,
    this.ownedItemDispatch,
    this.onEdit,
    this.ownedCopies = const [],
    this.trackingSummary,
    required this.accent,
    this.detailsLayout = LibraryDetailsLayout.hidden,
    this.onFilterByValue,
    this.searchQuery,
    this.searchTarget = LibrarySearchTarget.all,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final OwnedItemSummary? ownedItem;

  /// Concrete kind-owned aggregate for kind-owned inspector contributions.
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final VoidCallback? onEdit;
  final List<OwnedItemSummary> ownedCopies;
  final TrackingSummary? trackingSummary;
  final Color accent;
  final LibraryDetailsLayout detailsLayout;
  final ValueChanged<String>? onFilterByValue;
  final String? searchQuery;
  final LibrarySearchTarget searchTarget;
}

typedef LibraryDetailSectionsBuilder = List<Widget> Function(
  BuildContext context,
  LibraryInspectorRequest request,
);

typedef LibraryInspectorHeroBuilder = Widget Function(
  BuildContext context,
  LibraryInspectorRequest request,
);

class LibraryInspectorPanelRequest {
  const LibraryInspectorPanelRequest({
    required this.inspector,
    required this.hero,
    required this.primarySections,
    required this.trailingSections,
    required this.ownedCopies,
    required this.selectedOwnedItemRef,
    required this.extraActions,
    this.actions = const LibraryItemActions(),
    this.onDetailsLayoutChanged,
    this.ownedCopiesSection,
    this.bundleSection,
    this.conditionGradeSection,
    VoidCallback? onAddCopy,
    VoidCallback? onOpenDetails,
    ValueChanged<OwnedItemRef>? onSelectOwnedItem,
    VoidCallback? onToggleOwned,
    VoidCallback? onToggleWishlist,
    VoidCallback? onEdit,
    VoidCallback? onCorrectMetadata,
    VoidCallback? onDuplicate,
    VoidCallback? onLoan,
    VoidCallback? onRefreshMetadata,
    VoidCallback? onShare,
    VoidCallback? onUnlinkFromCore,
  })  : _onAddCopy = onAddCopy,
        _onOpenDetails = onOpenDetails,
        _onSelectOwnedItem = onSelectOwnedItem,
        _onToggleOwned = onToggleOwned,
        _onToggleWishlist = onToggleWishlist,
        _onEdit = onEdit,
        _onCorrectMetadata = onCorrectMetadata,
        _onDuplicate = onDuplicate,
        _onLoan = onLoan,
        _onRefreshMetadata = onRefreshMetadata,
        _onShare = onShare,
        _onUnlinkFromCore = onUnlinkFromCore;

  final LibraryInspectorRequest inspector;
  final Widget hero;
  final List<Widget> primarySections;
  final List<Widget> trailingSections;
  final List<OwnedItemSummary> ownedCopies;
  final OwnedItemRef? selectedOwnedItemRef;
  final List<Widget> extraActions;
  final LibraryItemActions actions;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final Widget? ownedCopiesSection;
  final Widget? bundleSection;
  final Widget? conditionGradeSection;

  final VoidCallback? _onAddCopy;
  final VoidCallback? _onOpenDetails;
  final ValueChanged<OwnedItemRef>? _onSelectOwnedItem;
  final VoidCallback? _onToggleOwned;
  final VoidCallback? _onToggleWishlist;
  final VoidCallback? _onEdit;
  final VoidCallback? _onCorrectMetadata;
  final VoidCallback? _onDuplicate;
  final VoidCallback? _onLoan;
  final VoidCallback? _onRefreshMetadata;
  final VoidCallback? _onShare;
  final VoidCallback? _onUnlinkFromCore;

  VoidCallback get onAddCopy => _onAddCopy ?? actions.onAddCopy ?? () {};
  VoidCallback get onOpenDetails =>
      _onOpenDetails ?? actions.onOpenDetails ?? () {};
  ValueChanged<OwnedItemRef>? get onSelectOwnedItem =>
      _onSelectOwnedItem ?? actions.onSelectOwnedItem;
  VoidCallback? get onToggleOwned => _onToggleOwned ?? actions.onToggleOwned;
  VoidCallback? get onToggleWishlist =>
      _onToggleWishlist ?? actions.onToggleWishlist;
  VoidCallback? get onEdit => _onEdit ?? actions.onEdit;
  VoidCallback? get onCorrectMetadata =>
      _onCorrectMetadata ?? actions.onCorrectMetadata;
  VoidCallback? get onDuplicate => _onDuplicate ?? actions.onDuplicate;
  VoidCallback? get onLoan => _onLoan ?? actions.onLoan;
  VoidCallback? get onRefreshMetadata =>
      _onRefreshMetadata ?? actions.onRefreshMetadata;
  VoidCallback? get onShare => _onShare ?? actions.onShare;
  VoidCallback? get onUnlinkFromCore =>
      _onUnlinkFromCore ?? actions.onUnlinkFromCore;
}
