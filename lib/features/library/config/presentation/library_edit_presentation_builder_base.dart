import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_edit_tab_order.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

abstract class LibraryEditPresentationBuilderBase
    extends LibraryEditPresentationBuilder {
  const LibraryEditPresentationBuilderBase({
    required this.showOwnershipReferenceSection,
    required this.useOwnedMainArtworkLayout,
    required this.useDetailsTab,
    required this.useArtworkCoverTab,
    required this.useArtworkPhotosTab,
    required this.trackingSectionTitle,
    required this.ownedDigitalTrackingSectionTitle,
    required this.ownedDigitalTrackingHint,
    required this.ownershipReferenceTitle,
    required this.ownedBundleLabel,
    required this.ownedTabs,
    required this.trackedTabs,
    required this.catalogTabs,
    this.customTabBuilder,
  });

  final bool showOwnershipReferenceSection;
  final bool useOwnedMainArtworkLayout;
  final bool useDetailsTab;
  final bool useArtworkCoverTab;
  final bool useArtworkPhotosTab;
  final String trackingSectionTitle;
  final String ownedDigitalTrackingSectionTitle;
  final String ownedDigitalTrackingHint;
  final String ownershipReferenceTitle;
  final String ownedBundleLabel;
  final List<LibraryEditTabSpec> ownedTabs;
  final List<LibraryEditTabSpec> trackedTabs;
  final List<LibraryEditTabSpec> catalogTabs;
  final Widget? Function({
    required String tabId,
    required BuildContext context,
    required LibraryEditDraft draft,
    required Color accent,
    required LibraryEditScope scope,
    required CatalogItem item,
    required VoidCallback markDirty,
  })? customTabBuilder;

  @override
  Widget? buildCustomTabView({
    required String tabId,
    required BuildContext context,
    required LibraryEditDraft draft,
    required Color accent,
    required LibraryEditScope scope,
    required CatalogItem item,
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
    final tabs = context.scope == LibraryEditScope.media
        ? [
            ...catalogTabs,
            if (context.hasCustomFields)
              const LibraryEditTabSpec(
                id: 'custom',
                icon: Icons.tune,
                label: 'Custom',
              ),
          ]
        : context.isOwned
            ? ownedTabs
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
      showsOwnershipReferenceSection: showOwnershipReferenceSection &&
          context.isOwned &&
          (context.hasEditionAnchors || context.hasBundleReleaseAnchors),
      usesOwnedMainArtworkLayout: useOwnedMainArtworkLayout && context.isOwned,
      usesDetailsTab: useDetailsTab,
      usesArtworkCoverTab: useArtworkCoverTab,
      usesArtworkPhotosTab: useArtworkPhotosTab && context.isOwned,
      trackingSectionTitle: context.isOwned
          ? context.isDigitalFormat
              ? ownedDigitalTrackingSectionTitle
              : trackingSectionTitle
          : trackingSectionTitle,
      trackingSectionHint: context.isOwned && context.isDigitalFormat
          ? ownedDigitalTrackingHint
          : null,
      ownershipReferenceTitle: ownershipReferenceTitle,
      ownedBundleLabel: ownedBundleLabel,
    );
  }
}
