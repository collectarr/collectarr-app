import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:flutter/material.dart';

class DefaultLibraryEditPresentationBuilder
    extends LibraryEditPresentationBuilder {
  const DefaultLibraryEditPresentationBuilder({
    this.showOwnershipReferenceSection = true,
    this.showOwnedGradingSection = false,
    this.useOwnedMainArtworkLayout = false,
    this.useDetailsTab = false,
    this.useArtworkCoverTab = false,
    this.useArtworkPhotosTab = false,
    this.showOwnedCoverPriceField = true,
    this.trackingSectionTitle = 'Tracking edition',
    this.ownedPhysicalTrackingSectionTitle = 'Condition & Grade',
    this.ownedDigitalTrackingSectionTitle = 'Ownership details',
    this.ownedDigitalTrackingHint =
        'Digital items keep tracking, notes and value fields, while copy-specific physical fields stay disabled.',
    this.ownershipReferenceTitle = 'Ownership reference',
    this.ownedBundleLabel = 'Owned bundle',
    this.ownedPhysicalGradingSectionTitle = 'Grading details',
    this.ownedDigitalGradingSectionTitle = 'Collection flags',
    this.ownedDigitalGradingHint =
        'Grading and copy-condition fields are hidden for digital copies.',
    this.keyToggleLabel = 'Key comic',
    this.keyReasonLabel = 'Key reason (first appearance, etc.)',
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
  });

  final bool showOwnershipReferenceSection;
  final bool showOwnedGradingSection;
  final bool useOwnedMainArtworkLayout;
  final bool useDetailsTab;
  final bool useArtworkCoverTab;
  final bool useArtworkPhotosTab;
  final bool showOwnedCoverPriceField;
  final String trackingSectionTitle;
  final String ownedPhysicalTrackingSectionTitle;
  final String ownedDigitalTrackingSectionTitle;
  final String ownedDigitalTrackingHint;
  final String ownershipReferenceTitle;
  final String ownedBundleLabel;
  final String ownedPhysicalGradingSectionTitle;
  final String ownedDigitalGradingSectionTitle;
  final String ownedDigitalGradingHint;
  final String keyToggleLabel;
  final String keyReasonLabel;
  final List<LibraryEditTabSpec> ownedTabs;
  final List<LibraryEditTabSpec> trackedTabs;
  final List<LibraryEditTabSpec> catalogTabs;

  @override
  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  }) {
    final tabs = context.isOwned
        ? ownedTabs
        : context.isTrackingOnly || context.hasWishlistContext
            ? trackedTabs
            : catalogTabs;
    if (context.scope == LibraryEditScope.media) {
      const mediaTabs = {
        'main',
        'cover',
        'synopsis',
        'custom',
        'read_history',
      };
      return tabs.where((tab) => mediaTabs.contains(tab.id)).toList();
    }
    if (context.scope == LibraryEditScope.release) {
      const releaseTabs = {
        'details',
        'value',
        'personal',
        'sold',
        'custom',
        'read_history',
        'photos'
      };
      return tabs.where((tab) => releaseTabs.contains(tab.id)).toList();
    }
    return tabs;
  }

  @override
  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  }) {
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
      showsOwnedGradingSection: showOwnedGradingSection && context.isOwned,
      usesOwnedMainArtworkLayout: useOwnedMainArtworkLayout && context.isOwned,
      usesDetailsTab: useDetailsTab,
      usesArtworkCoverTab: useArtworkCoverTab,
      usesArtworkPhotosTab: useArtworkPhotosTab && context.isOwned,
      showsOwnedCoverPriceField: showOwnedCoverPriceField,
      trackingSectionTitle: context.isOwned
          ? context.isDigitalFormat
              ? ownedDigitalTrackingSectionTitle
              : ownedPhysicalTrackingSectionTitle
          : trackingSectionTitle,
      trackingSectionHint: context.isOwned && context.isDigitalFormat
          ? ownedDigitalTrackingHint
          : null,
      ownershipReferenceTitle: ownershipReferenceTitle,
      ownedBundleLabel: ownedBundleLabel,
      ownedGradingSectionTitle: context.isDigitalFormat
          ? ownedDigitalGradingSectionTitle
          : ownedPhysicalGradingSectionTitle,
      ownedGradingSectionHint:
          context.isDigitalFormat ? ownedDigitalGradingHint : null,
      keyToggleLabel: keyToggleLabel,
      keyReasonLabel: keyReasonLabel,
    );
  }
}
