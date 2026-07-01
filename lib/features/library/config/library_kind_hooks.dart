import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

typedef LibraryItemDetailDrilldownPredicate = bool Function(
  LibraryProjectionItem item,
);

typedef LibraryItemDetailDrilldownOp = void Function(
  LibraryProjectionItem item,
);

typedef LibraryWorkspaceOverrideBuilder = Widget? Function(
  LibraryProjection projection,
  LibraryWorkspaceViewState viewState, {
  required List<OwnedItem> allOwnedCopies,
  required List<WishlistItem> allWishlistItems,
});

class LibraryPageKindHooks {
  const LibraryPageKindHooks({
    this.canOpenItemDetailDrilldown,
    this.openItemDetailDrilldown,
    this.canOpenDefaultVideoShelfDrilldown,
    this.openDefaultVideoShelfDrilldown,
    this.buildWorkspaceOverride,
  });

  final LibraryItemDetailDrilldownPredicate? canOpenItemDetailDrilldown;
  final LibraryItemDetailDrilldownOp? openItemDetailDrilldown;
  final LibraryItemDetailDrilldownPredicate? canOpenDefaultVideoShelfDrilldown;
  final LibraryItemDetailDrilldownOp? openDefaultVideoShelfDrilldown;
  final LibraryWorkspaceOverrideBuilder? buildWorkspaceOverride;
}

class LibraryInspectorKindHooks {
  const LibraryInspectorKindHooks({
    this.showActionBar = true,
  });

  final bool showActionBar;
}

class LibraryEditKindHooks {
  const LibraryEditKindHooks({
    this.defaultScope,
  });

  final LibraryEditScope? defaultScope;
}

class LibraryStateKindHooks {
  const LibraryStateKindHooks({
    this.useConcretePageState = false,
  });

  final bool useConcretePageState;
}

class LibraryKindHooks {
  const LibraryKindHooks({
    this.page = const LibraryPageKindHooks(),
    this.inspector = const LibraryInspectorKindHooks(),
    this.edit = const LibraryEditKindHooks(),
    this.state = const LibraryStateKindHooks(),
  });

  final LibraryPageKindHooks page;
  final LibraryInspectorKindHooks inspector;
  final LibraryEditKindHooks edit;
  final LibraryStateKindHooks state;
}
