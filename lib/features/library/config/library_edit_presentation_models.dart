import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

class LibraryEditPresentationContext {
  const LibraryEditPresentationContext({
    required this.isEntry,
    required this.isTrackingOnly,
    required this.hasTrackingContext,
    required this.hasWishlistContext,
    required this.isDigitalFormat,
    required this.hasPhysicalFormats,
    required this.hasCustomFields,
  });

  final bool isEntry;
  final bool isTrackingOnly;
  final bool hasTrackingContext;
  final bool hasWishlistContext;
  final bool isDigitalFormat;
  final bool hasPhysicalFormats;
  final bool hasCustomFields;
}

class LibraryEditTabSpec {
  const LibraryEditTabSpec({
    required this.id,
    required this.icon,
    required this.label,
    this.priority = 0,
    this.sectionIds = const [],
    this.sectionIdsForContext,
  });

  final String id;
  final IconData icon;
  final String label;
  final int priority;
  final List<String> sectionIds;
  final List<String> Function(LibraryEditPresentationContext context)?
      sectionIdsForContext;
}

enum LibraryEditTabTargetScope {
  all,
  catalogItem,
  libraryEntry,
}

/// Declares a shared tab that the library edit host can compose around
/// kind-owned tabs without asking the kind to build its lifecycle widget.
class LibraryEditTabContribution {
  const LibraryEditTabContribution({
    required this.tab,
    this.scope = LibraryEditTabTargetScope.all,
    this.afterTabId,
  });

  final LibraryEditTabSpec tab;
  final LibraryEditTabTargetScope scope;
  final String? afterTabId;

  bool isAvailableFor(LibraryEditPresentationContext context) =>
      switch (scope) {
        LibraryEditTabTargetScope.all => true,
        LibraryEditTabTargetScope.catalogItem => !context.isEntry,
        LibraryEditTabTargetScope.libraryEntry => context.isEntry,
      };
}

class LibraryEditPresentationState {
  const LibraryEditPresentationState({
    required this.usesEntryMainArtworkLayout,
    required this.usesDetailsTab,
    required this.usesArtworkCoverTab,
    required this.usesArtworkPhotosTab,
    required this.trackingSectionTitle,
    this.trackingSectionHint,
  });

  final bool usesEntryMainArtworkLayout;
  final bool usesDetailsTab;
  final bool usesArtworkCoverTab;
  final bool usesArtworkPhotosTab;
  final String trackingSectionTitle;
  final String? trackingSectionHint;
}

abstract class LibraryEditPresentationBuilder {
  const LibraryEditPresentationBuilder();

  String buildDialogTitle({
    required CatalogSearchCandidate kindItem,
  }) {
    return kindItem.summary.primaryLabel;
  }

  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  });

  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  });

  LibraryEditPresentationState build({
    required LibraryEditPresentationContext context,
  });

  Widget? buildCustomTabView({
    required String tabId,
    required BuildContext context,
    required LibraryEditShellState draft,
    required Color accent,
    required CatalogSearchCandidate item,
    required VoidCallback markDirty,
  }) =>
      null;
}

class LibraryEditPresentation {
  const LibraryEditPresentation({
    required this.builder,
    this.catalogItemBuilder,
    this.entryBuilder,
    this.sharedTabs = const [],
  });

  final LibraryEditPresentationBuilder builder;
  final LibraryEditPresentationBuilder? catalogItemBuilder;
  final LibraryEditPresentationBuilder? entryBuilder;
  final List<LibraryEditTabContribution> sharedTabs;

  LibraryEditPresentationBuilder builderForTarget(bool isEntry) =>
      isEntry ? entryBuilder ?? builder : catalogItemBuilder ?? builder;

  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
    required bool isEntry,
  }) {
    final tabs = [
      ...builderForTarget(isEntry).buildTabs(context: context),
    ];
    for (final contribution in sharedTabs) {
      if (!contribution.isAvailableFor(context) ||
          tabs.any((tab) => tab.id == contribution.tab.id)) {
        continue;
      }
      final anchorIndex = contribution.afterTabId == null
          ? -1
          : tabs.indexWhere((tab) => tab.id == contribution.afterTabId);
      tabs.insert(
        anchorIndex < 0 ? tabs.length : anchorIndex + 1,
        contribution.tab,
      );
    }
    return tabs;
  }
}
