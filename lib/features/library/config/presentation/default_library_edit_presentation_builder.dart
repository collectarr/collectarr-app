import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_section_registry.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

class DefaultLibraryEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const DefaultLibraryEditPresentationBuilder({
    this.showOwnershipReferenceSection = true,
    this.useOwnedMainArtworkLayout = false,
    this.useDetailsTab = false,
    this.useArtworkCoverTab = false,
    this.useArtworkPhotosTab = false,
    this.trackingSectionTitle = 'Tracking edition',
    this.ownedDigitalTrackingSectionTitle = 'Ownership details',
    this.ownedDigitalTrackingHint =
        'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
    this.ownershipReferenceTitle = 'Ownership reference',
    this.ownedBundleLabel = 'Owned bundle',
    this.ownedTabs = const [
      LibraryEditTabSpec(id: 'main', icon: Icons.article, label: 'Main'),
      LibraryEditTabSpec(id: 'value', icon: Icons.attach_money, label: 'Value'),
      LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
      LibraryEditTabSpec(id: 'sold', icon: Icons.sell, label: 'Sold'),
      LibraryEditTabSpec(id: 'custom', icon: Icons.tune, label: 'Custom'),
      LibraryEditTabSpec(
          id: 'photos', icon: Icons.photo_library, label: 'Photos'),
      LibraryEditTabSpec(id: 'cover', icon: Icons.image, label: 'Cover'),
      LibraryEditTabSpec(id: 'synopsis', icon: Icons.notes, label: 'Synopsis'),
    ],
    this.trackedTabs = const [
      LibraryEditTabSpec(id: 'main', icon: Icons.article, label: 'Main'),
      LibraryEditTabSpec(id: 'personal', icon: Icons.person, label: 'Personal'),
      LibraryEditTabSpec(id: 'cover', icon: Icons.image, label: 'Cover'),
      LibraryEditTabSpec(id: 'synopsis', icon: Icons.notes, label: 'Synopsis'),
    ],
    this.catalogTabs = const [
      LibraryEditTabSpec(id: 'main', icon: Icons.article, label: 'Main'),
      LibraryEditTabSpec(id: 'cover', icon: Icons.image, label: 'Cover'),
      LibraryEditTabSpec(id: 'synopsis', icon: Icons.notes, label: 'Synopsis'),
    ],
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
    return LibraryEditSectionRegistry.instance.orderTabs(tabs);
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
    final sections = switch (tabId) {
      'details' => ['catalog_details'],
      'main' => [
          'catalog_snapshot',
          'tracking_context',
          'ownership_reference',
          'owned_grading'
        ],
      'value' => ['purchase', 'value_summary'],
      'personal' => [
          'tracking_personal',
          'wishlist_reference',
          'owned_notes',
          'collection_fields_info'
        ],
      'sold' => ['sold_status', 'profit_loss'],
      'custom' => ['custom_fields'],
      'photos' => ['photos'],
      'cover' => ['cover_images'],
      'synopsis' => ['synopsis'],
      _ => const <String>[],
    };
    return List<String>.unmodifiable(sections);
  }

  @override
  LibraryEditFooterSpec buildFooter({
    required LibraryEditPresentationContext context,
  }) {
    return LibraryEditFooterSpec(
      label: context.isOwned
          ? 'Catalog + collection'
          : context.hasWishlistContext
              ? 'Catalog + wishlist'
              : context.isTrackingOnly
                  ? 'Catalog + tracking'
                  : 'Catalog snapshot only',
      fieldIds: context.isOwned ? const ['user_tags'] : const [],
    );
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
