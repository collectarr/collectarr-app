import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/edit/edition_selection_helpers.dart';

class LibraryOwnedAnchorSelectionState {
  const LibraryOwnedAnchorSelectionState({
    required this.anchorType,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.selectedBundleReleaseId,
    required this.selectedTrackingEditionId,
    required this.selectedTrackingVariantId,
  });

  final String anchorType;
  final String? selectedEditionId;
  final String? selectedVariantId;
  final String? selectedBundleReleaseId;
  final String? selectedTrackingEditionId;
  final String? selectedTrackingVariantId;
}

class LibraryWishlistAnchorSelectionState {
  const LibraryWishlistAnchorSelectionState({
    required this.anchorType,
    required this.selectedEditionId,
    required this.selectedVariantId,
    required this.selectedBundleReleaseId,
  });

  final String anchorType;
  final String? selectedEditionId;
  final String? selectedVariantId;
  final String? selectedBundleReleaseId;
}

LibraryOwnedAnchorSelectionState resolveOwnedAnchorSelectionState({
  required String anchorType,
  required List<CatalogEdition> editions,
  required String? selectedEditionId,
  required String? selectedVariantId,
  required String? editionTitle,
  required String? variantName,
  required List<String> availableBundleReleaseIds,
}) {
  if (anchorType == PersonalItemAnchorType.variant.apiValue) {
    final editionSelection = resolveLibraryEditionSelection(
      editions,
      editionId: selectedEditionId,
      variantId: selectedVariantId,
      editionTitle: editionTitle,
      variantName: variantName,
    );
    return LibraryOwnedAnchorSelectionState(
      anchorType: anchorType,
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: editionSelection.variant?.id,
      selectedBundleReleaseId: null,
      selectedTrackingEditionId: editionSelection.edition?.id,
      selectedTrackingVariantId: editionSelection.variant?.id,
    );
  }

  if (anchorType == PersonalItemAnchorType.edition.apiValue) {
    final editionSelection = resolveLibraryEditionSelection(
      editions,
      editionId: selectedEditionId,
      variantId: selectedVariantId,
      editionTitle: editionTitle,
      variantName: variantName,
    );
    return LibraryOwnedAnchorSelectionState(
      anchorType: anchorType,
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: null,
      selectedBundleReleaseId: null,
      selectedTrackingEditionId: editionSelection.edition?.id,
      selectedTrackingVariantId: null,
    );
  }

  if (anchorType == PersonalItemAnchorType.bundleRelease.apiValue) {
    return LibraryOwnedAnchorSelectionState(
      anchorType: anchorType,
      selectedEditionId: null,
      selectedVariantId: null,
      selectedBundleReleaseId:
          availableBundleReleaseIds.isEmpty ? null : availableBundleReleaseIds.first,
      selectedTrackingEditionId: null,
      selectedTrackingVariantId: null,
    );
  }

  return LibraryOwnedAnchorSelectionState(
    anchorType: anchorType,
    selectedEditionId: null,
    selectedVariantId: null,
    selectedBundleReleaseId: null,
    selectedTrackingEditionId: null,
    selectedTrackingVariantId: null,
  );
}

LibraryWishlistAnchorSelectionState resolveWishlistAnchorSelectionState({
  required String anchorType,
  required List<CatalogEdition> editions,
  required String? selectedEditionId,
  required String? selectedVariantId,
  required String? editionTitle,
  required String? variantName,
  required List<String> availableBundleReleaseIds,
}) {
  if (anchorType == PersonalItemAnchorType.variant.apiValue) {
    final editionSelection = resolveLibraryEditionSelection(
      editions,
      editionId: selectedEditionId,
      variantId: selectedVariantId,
      editionTitle: editionTitle,
      variantName: variantName,
    );
    return LibraryWishlistAnchorSelectionState(
      anchorType: anchorType,
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: editionSelection.variant?.id,
      selectedBundleReleaseId: null,
    );
  }

  if (anchorType == PersonalItemAnchorType.edition.apiValue) {
    final editionSelection = resolveLibraryEditionSelection(
      editions,
      editionId: selectedEditionId,
      variantId: selectedVariantId,
      editionTitle: editionTitle,
      variantName: variantName,
    );
    return LibraryWishlistAnchorSelectionState(
      anchorType: anchorType,
      selectedEditionId: editionSelection.edition?.id,
      selectedVariantId: null,
      selectedBundleReleaseId: null,
    );
  }

  if (anchorType == PersonalItemAnchorType.bundleRelease.apiValue) {
    return LibraryWishlistAnchorSelectionState(
      anchorType: anchorType,
      selectedEditionId: null,
      selectedVariantId: null,
      selectedBundleReleaseId:
          availableBundleReleaseIds.isEmpty ? null : availableBundleReleaseIds.first,
    );
  }

  return LibraryWishlistAnchorSelectionState(
    anchorType: anchorType,
    selectedEditionId: null,
    selectedVariantId: null,
    selectedBundleReleaseId: null,
  );
}

String? normalizeLibrarySelectionId(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}