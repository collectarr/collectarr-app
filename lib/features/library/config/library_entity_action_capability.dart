import 'dart:async';

import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:flutter/material.dart';

/// The entity-level actions a kind intentionally exposes for one scope.
///
/// Workspace actions such as sorting, grouping, columns, and printing do not
/// belong here. They are registered by the workspace toolbar instead.
final class LibraryEntityActionSet {
  const LibraryEntityActionSet({
    this.openDetails = false,
    this.toggleEntry = false,
    this.toggleWishlist = false,
    this.edit = false,
    this.duplicate = false,
    this.loan = false,
    this.refreshMetadata = false,
    this.share = false,
    this.unlinkFromCore = false,
  });

  static const catalogItem = LibraryEntityActionSet(
    openDetails: true,
    toggleEntry: true,
    toggleWishlist: true,
    edit: true,
    refreshMetadata: true,
    share: true,
  );

  static const libraryEntry = LibraryEntityActionSet(
    openDetails: true,
    toggleEntry: true,
    edit: true,
    duplicate: true,
    loan: true,
    refreshMetadata: true,
    share: true,
  );

  final bool openDetails;
  final bool toggleEntry;
  final bool toggleWishlist;
  final bool edit;
  final bool duplicate;
  final bool loan;
  final bool refreshMetadata;
  final bool share;
  final bool unlinkFromCore;
}

/// Runtime callbacks supplied by the generic host to a kind-entry action
/// capability. The host owns lifecycle and navigation mechanics; the kind
/// decides which callbacks are legal at each entity scope.
final class LibraryEntityActionContext {
  const LibraryEntityActionContext({
    required this.type,
    required this.buildContext,
    required this.projection,
    required this.item,
    required this.libraryEntry,
    required this.onOpenDetails,
    required this.onToggleEntry,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onDuplicate,
    required this.onLoan,
    required this.onRefreshMetadata,
    required this.onShare,
    required this.onUnlinkFromCore,
    required this.accent,
  });

  final LibraryKindRegistration type;
  final BuildContext buildContext;
  final LibraryProjection projection;
  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntry;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onToggleEntry;
  final VoidCallback? onToggleWishlist;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onLoan;
  final VoidCallback? onRefreshMetadata;
  final VoidCallback? onShare;
  final VoidCallback? onUnlinkFromCore;
  final Color accent;
}

final class LibraryEntitySemanticActionDefinition {
  const LibraryEntitySemanticActionDefinition({
    required this.id,
    required this.label,
    required this.icon,
    required this.invoke,
  });

  final String id;
  final String label;
  final IconData icon;
  final FutureOr<void> Function(LibraryEntityActionContext context) invoke;
}

/// Kind-entry entity action registration.
final class LibraryEntityActionCapability {
  const LibraryEntityActionCapability({
    required this.catalogItem,
    required this.libraryEntry,
    this.semanticActions = const {},
  });

  final LibraryEntityActionSet catalogItem;
  final LibraryEntityActionSet libraryEntry;
  final Map<LibraryEntityScope, List<LibraryEntitySemanticActionDefinition>>
      semanticActions;

  LibraryEntityActionSet actionSetForScope(LibraryEntityScope scope) =>
      switch (scope) {
        LibraryEntityScope.catalogItem => catalogItem,
        LibraryEntityScope.libraryEntry => libraryEntry,
      };

  List<LibraryEntitySemanticActionDefinition> semanticActionsForScope(
    LibraryEntityScope scope,
  ) =>
      semanticActions[scope] ?? const [];

  LibraryEntityActionRegistry build(LibraryEntityActionContext context) {
    return LibraryEntityActionRegistry(
      contributors: [
        LibraryEntityActionContributor(
          scope: LibraryEntityScope.catalogItem,
          actions: _buildActions(
            LibraryEntityScope.catalogItem,
            catalogItem,
            context,
          ),
        ),
        LibraryEntityActionContributor(
          scope: LibraryEntityScope.libraryEntry,
          actions: _buildActions(
            LibraryEntityScope.libraryEntry,
            libraryEntry,
            context,
          ),
        ),
      ],
    );
  }

  LibraryItemActions _buildActions(
    LibraryEntityScope scope,
    LibraryEntityActionSet actionSet,
    LibraryEntityActionContext context,
  ) {
    final definitions = semanticActionsForScope(scope);
    return LibraryItemActions(
      onOpenDetails: actionSet.openDetails ? context.onOpenDetails : null,
      onToggleEntry: actionSet.toggleEntry ? context.onToggleEntry : null,
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
      semanticActions: [
        for (final definition in definitions)
          LibraryEntitySemanticAction(
            id: definition.id,
            label: definition.label,
            icon: definition.icon,
            onInvoke: () async => definition.invoke(context),
          ),
      ],
    );
  }
}
