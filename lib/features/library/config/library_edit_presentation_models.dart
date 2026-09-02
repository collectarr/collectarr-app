import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';

class LibraryEditPresentationContext {
  const LibraryEditPresentationContext({
    required this.isOwned,
    required this.isTrackingOnly,
    required this.hasTrackingContext,
    required this.hasWishlistContext,
    required this.isDigitalFormat,
    required this.hasPhysicalFormats,
    required this.hasEditionAnchors,
    required this.hasBundleReleaseAnchors,
    required this.hasCustomFields,
    this.scope = LibraryEditScope.media,
  });

  final bool isOwned;
  final bool isTrackingOnly;
  final bool hasTrackingContext;
  final bool hasWishlistContext;
  final bool isDigitalFormat;
  final bool hasPhysicalFormats;
  final bool hasEditionAnchors;
  final bool hasBundleReleaseAnchors;
  final bool hasCustomFields;
  final LibraryEditScope scope;
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

class LibraryEditFooterSpec {
  const LibraryEditFooterSpec({
    this.label,
    this.fieldIds = const [],
  });

  final String? label;
  final List<String> fieldIds;
}

class LibraryEditPresentationState {
  const LibraryEditPresentationState({
    required this.showsOwnershipReferenceSection,
    required this.usesOwnedMainArtworkLayout,
    required this.usesDetailsTab,
    required this.usesArtworkCoverTab,
    required this.usesArtworkPhotosTab,
    required this.trackingSectionTitle,
    this.trackingSectionHint,
    required this.ownershipReferenceTitle,
    required this.ownedBundleLabel,
  });

  final bool showsOwnershipReferenceSection;
  final bool usesOwnedMainArtworkLayout;
  final bool usesDetailsTab;
  final bool usesArtworkCoverTab;
  final bool usesArtworkPhotosTab;
  final String trackingSectionTitle;
  final String? trackingSectionHint;
  final String ownershipReferenceTitle;
  final String ownedBundleLabel;
}

abstract class LibraryEditPresentationBuilder {
  const LibraryEditPresentationBuilder();

  List<LibraryEditTabSpec> buildTabs({
    required LibraryEditPresentationContext context,
  });

  List<String> buildTabSectionIds({
    required LibraryEditPresentationContext context,
    required String tabId,
  });

  LibraryEditFooterSpec buildFooter({
    required LibraryEditPresentationContext context,
  });

  LibraryEditPresentationState build({
    required LibraryEditPresentationContext context,
  });

  Widget? buildCustomTabView({
    required String tabId,
    required BuildContext context,
    required LibraryEditDraft draft,
    required Color accent,
    required LibraryEditScope scope,
    required LibraryMetadataItem item,
    required VoidCallback markDirty,
  }) =>
      null;
}

class LibraryEditPresentation {
  const LibraryEditPresentation({
    required this.builder,
    this.mediaBuilder,
    this.releaseBuilder,
  });

  final LibraryEditPresentationBuilder builder;
  final LibraryEditPresentationBuilder? mediaBuilder;
  final LibraryEditPresentationBuilder? releaseBuilder;

  LibraryEditPresentationBuilder builderForScope(LibraryEditScope scope) {
    return switch (scope) {
      LibraryEditScope.media => mediaBuilder ?? builder,
      LibraryEditScope.release => releaseBuilder ?? builder,
      LibraryEditScope.all => builder,
    };
  }
}
