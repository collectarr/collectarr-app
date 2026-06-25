import 'package:flutter/material.dart';
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
    this.scope = LibraryEditScope.all,
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
  });

  final String id;
  final IconData icon;
  final String label;
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
    required this.showsOwnedGradingSection,
    required this.usesOwnedMainArtworkLayout,
    required this.usesDetailsTab,
    required this.usesArtworkCoverTab,
    required this.usesArtworkPhotosTab,
    required this.showsOwnedCoverPriceField,
    required this.trackingSectionTitle,
    this.trackingSectionHint,
    required this.ownershipReferenceTitle,
    required this.ownedBundleLabel,
    required this.ownedGradingSectionTitle,
    this.ownedGradingSectionHint,
    required this.keyToggleLabel,
    required this.keyReasonLabel,
  });

  final bool showsOwnershipReferenceSection;
  final bool showsOwnedGradingSection;
  final bool usesOwnedMainArtworkLayout;
  final bool usesDetailsTab;
  final bool usesArtworkCoverTab;
  final bool usesArtworkPhotosTab;
  final bool showsOwnedCoverPriceField;
  final String trackingSectionTitle;
  final String? trackingSectionHint;
  final String ownershipReferenceTitle;
  final String ownedBundleLabel;
  final String ownedGradingSectionTitle;
  final String? ownedGradingSectionHint;
  final String keyToggleLabel;
  final String keyReasonLabel;
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
}

class LibraryEditPresentation {
  const LibraryEditPresentation({required this.builder});

  final LibraryEditPresentationBuilder builder;
}
