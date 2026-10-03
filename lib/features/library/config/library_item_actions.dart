import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
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
  Future<void> openDetails();
  Future<void> toggleEntry();
  Future<void> toggleWishlist();
  Future<void> edit();
  Future<void> duplicate();
  Future<void> loan();
  Future<void> refreshMetadata();
  Future<void> share();
  Future<void> unlinkFromCore();
  List<LibraryEntitySemanticAction> get semanticActions;
}

final class LibraryEntitySemanticAction {
  const LibraryEntitySemanticAction({
    required this.id,
    required this.label,
    required this.icon,
    this.onInvoke,
  });

  final String id;
  final String label;
  final IconData icon;
  final Future<void> Function()? onInvoke;
}

/// Entity actions are separate from workspace actions such as sorting,
/// grouping, printing, and column management.
final class LibraryEntityActionContributor {
  const LibraryEntityActionContributor({
    required this.scope,
    required this.actions,
  });

  final LibraryEntityScope scope;
  final LibraryItemActions actions;
}

final class LibraryEntityActionRegistry {
  const LibraryEntityActionRegistry({
    this.contributors = const [],
  });

  final List<LibraryEntityActionContributor> contributors;

  LibraryItemActions actionsForScope(LibraryEntityScope scope) {
    for (final contributor in contributors) {
      if (contributor.scope == scope) return contributor.actions;
    }
    throw StateError(
      'Missing entity action contributor for ${scope.apiValue}.',
    );
  }
}

class LibraryItemActions implements LibraryItemActionRunner {
  const LibraryItemActions({
    this.onOpenDetails,
    this.onToggleEntry,
    this.onToggleWishlist,
    this.onEdit,
    this.onDuplicate,
    this.onLoan,
    this.onRefreshMetadata,
    this.onShare,
    this.onUnlinkFromCore,
    this.semanticActions = const [],
  });

  final VoidCallback? onOpenDetails;
  final VoidCallback? onToggleEntry;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onLoan;
  final VoidCallback? onRefreshMetadata;
  final VoidCallback? onShare;
  final VoidCallback? onUnlinkFromCore;
  @override
  final List<LibraryEntitySemanticAction> semanticActions;

  @override
  @override
  Future<void> openDetails() async => onOpenDetails?.call();

  @override
  @override
  Future<void> toggleEntry() async => onToggleEntry?.call();

  @override
  Future<void> toggleWishlist() async => onToggleWishlist?.call();

  @override
  Future<void> edit() async => onEdit?.call();

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

class LibraryEditDialogRequest {
  LibraryEditDialogRequest({
    required this.type,
    required CatalogSearchCandidate item,
    this.node,
    required this.libraryEntry,
    this.libraryEntryDispatch,
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
  }) : kindItem = item;

  final LibraryKindRegistration type;

  /// Full candidate retained for the concrete kind edit contribution.
  final CatalogSearchCandidate kindItem;

  /// Structural node being edited. The node identifies either the canonical
  /// Catalog Item or its independently editable local entry.
  final LibraryEntityRef? node;
  final LibraryEntrySummary? libraryEntry;

  /// Concrete kind-entry aggregate, present only after kind dispatch.
  /// Generic edit infrastructure must not decode or inspect this value.
  final LibraryEntryDispatch? libraryEntryDispatch;
  final Color accent;
  final LibraryEntityScope? scope;

  /// A concrete node is authoritative. Explicit scope is used for actions
  /// without a node; Catalog Item is the default when neither is available.
  LibraryEntityScope get resolvedScope =>
      node?.scope ?? scope ?? LibraryEntityScope.catalogItem;

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

  LibraryEditDialogRequest copyWith({
    LibraryKindRegistration? type,
    CatalogSearchCandidate? item,
    LibraryEntityRef? node,
    LibraryEntrySummary? libraryEntry,
    LibraryEntryDispatch? libraryEntryDispatch,
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
  }) {
    return LibraryEditDialogRequest(
      type: type ?? this.type,
      item: item ?? kindItem,
      node: node ?? this.node,
      libraryEntry: libraryEntry ?? this.libraryEntry,
      libraryEntryDispatch: libraryEntryDispatch ?? this.libraryEntryDispatch,
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
    required this.libraryEntrySummary,
    this.libraryEntryDispatch,
    required this.accent,
    this.actions = const LibraryItemActions(),
    VoidCallback? onAddEntry,
    VoidCallback? onRemoveEntry,
    VoidCallback? onAddWishlist,
    VoidCallback? onRemoveWishlist,
    void Function(LibraryEntrySummary? libraryEntry)? onEdit,
    this.onFilterByValue,
  })  : _onAddEntry = onAddEntry,
        _onRemoveEntry = onRemoveEntry,
        _onAddWishlist = onAddWishlist,
        _onRemoveWishlist = onRemoveWishlist,
        _onEdit = onEdit;

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntrySummary;

  /// Concrete kind-entry aggregate available after Library kind dispatch.
  final LibraryEntryDispatch? libraryEntryDispatch;
  final Color accent;
  final LibraryItemActions actions;
  final ValueChanged<String>? onFilterByValue;

  final VoidCallback? _onAddEntry;
  final VoidCallback? _onRemoveEntry;
  final VoidCallback? _onAddWishlist;
  final VoidCallback? _onRemoveWishlist;
  final void Function(LibraryEntrySummary? libraryEntry)? _onEdit;

  VoidCallback? get onAddEntry => _onAddEntry ?? actions.onToggleEntry;
  VoidCallback? get onRemoveEntry => _onRemoveEntry ?? actions.onToggleEntry;
  VoidCallback? get onAddWishlist => _onAddWishlist ?? actions.onToggleWishlist;
  VoidCallback? get onRemoveWishlist =>
      _onRemoveWishlist ?? actions.onToggleWishlist;
  void Function(LibraryEntrySummary? libraryEntry)? get onEdit =>
      _onEdit ?? (actions.onEdit != null ? (_) => actions.onEdit!() : null);
}

typedef LibraryDetailPageBuilder = Widget Function(
  BuildContext context,
  LibraryDetailPageRequest request,
);

/// Optional kind-entry contribution rendered inside a media detail host.
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
    required this.libraryEntry,
    this.libraryEntryDispatch,
    this.onEdit,
    this.libraryEntries = const [],
    this.trackingSummary,
    required this.accent,
    this.detailsLayout = LibraryDetailsLayout.hidden,
    this.onFilterByValue,
    this.searchQuery,
    this.searchTarget = LibrarySearchTarget.all,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntry;

  /// Concrete kind-entry aggregate for kind-entry inspector contributions.
  final LibraryEntryDispatch? libraryEntryDispatch;
  final VoidCallback? onEdit;
  final List<LibraryEntrySummary> libraryEntries;
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
    required this.libraryEntries,
    required this.extraActions,
    this.actions = const LibraryItemActions(),
    this.onDetailsLayoutChanged,
    this.bundleSection,
    this.conditionGradeSection,
    VoidCallback? onOpenDetails,
    VoidCallback? onToggleEntry,
    VoidCallback? onToggleWishlist,
    VoidCallback? onEdit,
    VoidCallback? onDuplicate,
    VoidCallback? onLoan,
    VoidCallback? onRefreshMetadata,
    VoidCallback? onShare,
    VoidCallback? onUnlinkFromCore,
  })  : _onOpenDetails = onOpenDetails,
        _onToggleEntry = onToggleEntry,
        _onToggleWishlist = onToggleWishlist,
        _onEdit = onEdit,
        _onDuplicate = onDuplicate,
        _onLoan = onLoan,
        _onRefreshMetadata = onRefreshMetadata,
        _onShare = onShare,
        _onUnlinkFromCore = onUnlinkFromCore;

  final LibraryInspectorRequest inspector;
  final Widget hero;
  final List<Widget> primarySections;
  final List<Widget> trailingSections;
  final List<LibraryEntrySummary> libraryEntries;
  final List<Widget> extraActions;
  final LibraryItemActions actions;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final Widget? bundleSection;
  final Widget? conditionGradeSection;

  final VoidCallback? _onOpenDetails;
  final VoidCallback? _onToggleEntry;
  final VoidCallback? _onToggleWishlist;
  final VoidCallback? _onEdit;
  final VoidCallback? _onDuplicate;
  final VoidCallback? _onLoan;
  final VoidCallback? _onRefreshMetadata;
  final VoidCallback? _onShare;
  final VoidCallback? _onUnlinkFromCore;

  VoidCallback get onOpenDetails =>
      _onOpenDetails ?? actions.onOpenDetails ?? () {};
  VoidCallback? get onToggleEntry => _onToggleEntry ?? actions.onToggleEntry;
  VoidCallback? get onToggleWishlist =>
      _onToggleWishlist ?? actions.onToggleWishlist;
  VoidCallback? get onEdit => _onEdit ?? actions.onEdit;
  VoidCallback? get onDuplicate => _onDuplicate ?? actions.onDuplicate;
  VoidCallback? get onLoan => _onLoan ?? actions.onLoan;
  VoidCallback? get onRefreshMetadata =>
      _onRefreshMetadata ?? actions.onRefreshMetadata;
  VoidCallback? get onShare => _onShare ?? actions.onShare;
  VoidCallback? get onUnlinkFromCore =>
      _onUnlinkFromCore ?? actions.onUnlinkFromCore;
}
