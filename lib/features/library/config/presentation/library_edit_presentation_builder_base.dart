import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_edit_tab_order.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

abstract class LibraryEditPresentationBuilderBase
    extends LibraryEditPresentationBuilder {
  const LibraryEditPresentationBuilderBase({
    required this.useEntryMainArtworkLayout,
    required this.useDetailsTab,
    required this.useArtworkCoverTab,
    required this.useArtworkPhotosTab,
    required this.trackingSectionTitle,
    required this.entryDigitalTrackingSectionTitle,
    required this.entryDigitalTrackingHint,
    required this.entryTabs,
    required this.trackedTabs,
    required this.catalogTabs,
    this.customTabBuilder,
  });

  final bool useEntryMainArtworkLayout;
  final bool useDetailsTab;
  final bool useArtworkCoverTab;
  final bool useArtworkPhotosTab;
  final String trackingSectionTitle;
  final String entryDigitalTrackingSectionTitle;
  final String entryDigitalTrackingHint;
  final List<LibraryEditTabSpec> entryTabs;
  final List<LibraryEditTabSpec> trackedTabs;
  final List<LibraryEditTabSpec> catalogTabs;
  final Widget? Function({
    required String tabId,
    required BuildContext context,
    required LibraryEditShellState draft,
    required Color accent,
    required LibraryEntityScope scope,
    required CatalogSearchCandidate item,
    required VoidCallback markDirty,
  })? customTabBuilder;

  @override
  Widget? buildCustomTabView({
    required String tabId,
    required BuildContext context,
    required LibraryEditShellState draft,
    required Color accent,
    required LibraryEntityScope scope,
    required CatalogSearchCandidate item,
    required VoidCallback markDirty,
  }) {
    return customTabBuilder?.call(
      tabId: tabId,
      context: context,
      draft: draft,
      accent: accent,
      scope: scope,
      item: item,
      markDirty: markDirty,
    );
  }

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) {
    final tabs = context.scope == LibraryEntityScope.catalogItem
        ? [
            ...catalogTabs,
            if (context.hasCustomFields)
              const LibraryEditTabSpec(
                id: 'custom',
                icon: Icons.tune,
                label: 'Custom',
              ),
          ]
        : context.isEntry
            ? entryTabs
            : context.isTrackingOnly || context.hasWishlistContext
                ? trackedTabs
                : catalogTabs;
    return LibraryEditTabOrder.instance.orderTabs(tabs);
  }

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
    final tabs = buildTabs(context: context);
    for (final tab in tabs) {
      if (tab.id == tabId && tab.sectionIds.isNotEmpty) {
        return List<String>.unmodifiable(tab.sectionIds);
      }
      if (tab.id == tabId && tab.sectionIdsForContext != null) {
        return List<String>.unmodifiable(tab.sectionIdsForContext!(context));
      }
    }
    return const <String>[];
  }

  @override
  LibraryEditPresentationState build({
    required LibraryEditPresentationContext context,
  }) {
    return LibraryEditPresentationState(
      usesEntryMainArtworkLayout: useEntryMainArtworkLayout && context.isEntry,
      usesDetailsTab: useDetailsTab,
      usesArtworkCoverTab: useArtworkCoverTab,
      usesArtworkPhotosTab: useArtworkPhotosTab && context.isEntry,
      trackingSectionTitle: context.isEntry
          ? context.isDigitalFormat
              ? entryDigitalTrackingSectionTitle
              : trackingSectionTitle
          : trackingSectionTitle,
      trackingSectionHint: context.isEntry && context.isDigitalFormat
          ? entryDigitalTrackingHint
          : null,
    );
  }
}
