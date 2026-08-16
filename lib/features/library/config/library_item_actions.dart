import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

class LibraryItemActions {
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
  final ValueChanged<String>? onSelectOwnedItem;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback? onCorrectMetadata;
  final VoidCallback? onDuplicate;
  final VoidCallback? onLoan;
  final VoidCallback? onRefreshMetadata;
  final VoidCallback? onShare;
  final VoidCallback? onUnlinkFromCore;
}

class LibraryAddDialogRequest {
  const LibraryAddDialogRequest({
    required this.type,
    this.accent,
    this.initialQuery,
    this.initialBarcode,
  });

  final LibraryTypeConfig type;
  final Color? accent;
  final String? initialQuery;
  final String? initialBarcode;
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
  const LibraryEditDialogRequest({
    required this.type,
    required this.item,
    required this.ownedItem,
    required this.accent,
    this.scope,
    this.wishlistItem,
    this.trackingEntry,
    this.availableBundleReleases = const [],
    this.physicalFormats = const [],
    this.customFieldDefinitions = const [],
    this.customFieldValues = const [],
    this.itemImages = const [],
    this.onPrevious,
    this.onNext,
    this.openMetadataCompareOnOpen = false,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final OwnedItem? ownedItem;
  final Color accent;
  final LibraryEditScope? scope;

  LibraryEditScope get resolvedScope {
    if (scope != null) {
      return scope!;
    }
    if (ownedItem != null) {
      return type.supportsMediaReleaseSplit
          ? LibraryEditScope.release
          : LibraryEditScope.all;
    }
    return type.supportsMediaReleaseSplit
        ? LibraryEditScope.all
        : LibraryEditScope.media;
  }

  final WishlistItem? wishlistItem;
  final TrackingEntry? trackingEntry;
  final List<BundleReleaseSummary> availableBundleReleases;
  final List<PhysicalMediaFormat> physicalFormats;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<ItemImage> itemImages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool openMetadataCompareOnOpen;

  LibraryEditDialogRequest copyWith({
    LibraryTypeConfig? type,
    LibraryMetadataItem? item,
    OwnedItem? ownedItem,
    Color? accent,
    LibraryEditScope? scope,
    WishlistItem? wishlistItem,
    TrackingEntry? trackingEntry,
    List<BundleReleaseSummary>? availableBundleReleases,
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
      item: item ?? this.item,
      ownedItem: ownedItem ?? this.ownedItem,
      accent: accent ?? this.accent,
      scope: scope ?? this.scope,
      wishlistItem: wishlistItem ?? this.wishlistItem,
      trackingEntry: trackingEntry ?? this.trackingEntry,
      availableBundleReleases:
          availableBundleReleases ?? this.availableBundleReleases,
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
    required this.ownedItem,
    required this.accent,
    this.actions = const LibraryItemActions(),
    VoidCallback? onAddOwned,
    VoidCallback? onRemoveOwned,
    VoidCallback? onAddWishlist,
    VoidCallback? onRemoveWishlist,
    void Function(OwnedItem? ownedItem)? onEdit,
    this.onFilterByValue,
  })  : _onAddOwned = onAddOwned,
        _onRemoveOwned = onRemoveOwned,
        _onAddWishlist = onAddWishlist,
        _onRemoveWishlist = onRemoveWishlist,
        _onEdit = onEdit;

  final LibraryTypeConfig type;
  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;
  final Color accent;
  final LibraryItemActions actions;
  final ValueChanged<String>? onFilterByValue;

  final VoidCallback? _onAddOwned;
  final VoidCallback? _onRemoveOwned;
  final VoidCallback? _onAddWishlist;
  final VoidCallback? _onRemoveWishlist;
  final void Function(OwnedItem? ownedItem)? _onEdit;

  VoidCallback? get onAddOwned => _onAddOwned ?? actions.onToggleOwned;
  VoidCallback? get onRemoveOwned => _onRemoveOwned ?? actions.onToggleOwned;
  VoidCallback? get onAddWishlist => _onAddWishlist ?? actions.onToggleWishlist;
  VoidCallback? get onRemoveWishlist =>
      _onRemoveWishlist ?? actions.onToggleWishlist;
  void Function(OwnedItem? ownedItem)? get onEdit =>
      _onEdit ?? (actions.onEdit != null ? (_) => actions.onEdit!() : null);
}

typedef LibraryDetailPageBuilder = Widget Function(
  BuildContext context,
  LibraryDetailPageRequest request,
);

class LibraryInspectorRequest {
  const LibraryInspectorRequest({
    required this.type,
    required this.item,
    required this.ownedItem,
    this.onEdit,
    this.ownedCopies = const [],
    required this.trackingEntry,
    required this.accent,
    this.detailsLayout = LibraryDetailsLayout.hidden,
    this.onFilterByValue,
    this.searchQuery,
    this.searchTarget = LibrarySearchTarget.all,
  });

  final LibraryTypeConfig type;
  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;
  final VoidCallback? onEdit;
  final List<OwnedItem> ownedCopies;
  final TrackingEntry? trackingEntry;
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
    required this.selectedOwnedItemId,
    required this.extraActions,
    this.actions = const LibraryItemActions(),
    this.onDetailsLayoutChanged,
    this.ownedCopiesSection,
    this.bundleSection,
    this.conditionGradeSection,
    VoidCallback? onAddCopy,
    VoidCallback? onOpenDetails,
    ValueChanged<String>? onSelectOwnedItem,
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
  final List<OwnedItem> ownedCopies;
  final String? selectedOwnedItemId;
  final List<Widget> extraActions;
  final LibraryItemActions actions;
  final ValueChanged<LibraryDetailsLayout>? onDetailsLayoutChanged;
  final Widget? ownedCopiesSection;
  final Widget? bundleSection;
  final Widget? conditionGradeSection;

  final VoidCallback? _onAddCopy;
  final VoidCallback? _onOpenDetails;
  final ValueChanged<String>? _onSelectOwnedItem;
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
  ValueChanged<String>? get onSelectOwnedItem =>
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
