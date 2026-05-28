import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CatalogEdition buildEdition() {
    return const CatalogEdition(
      id: 'edition-hc',
      title: 'Hardcover',
      variants: [
        CatalogVariant(
          id: 'variant-main',
          name: 'Main Cover',
          isPrimary: true,
        ),
        CatalogVariant(
          id: 'variant-alt',
          name: 'Alt Cover',
        ),
      ],
    );
  }

  test('normalizeLibrarySelectionId trims and nulls blanks', () {
    expect(normalizeLibrarySelectionId('  bundle-1  '), 'bundle-1');
    expect(normalizeLibrarySelectionId('   '), isNull);
    expect(normalizeLibrarySelectionId(null), isNull);
  });

  test('owned variant anchor keeps resolved edition and variant in sync', () {
    final state = resolveOwnedAnchorSelectionState(
      anchorType: PersonalItemAnchorType.variant.apiValue,
      editions: [buildEdition()],
      selectedEditionId: 'edition-hc',
      selectedVariantId: 'variant-alt',
      editionTitle: null,
      variantName: null,
      availableBundleReleaseIds: const ['bundle-1'],
    );

    expect(state.anchorType, PersonalItemAnchorType.variant.apiValue);
    expect(state.selectedEditionId, 'edition-hc');
    expect(state.selectedVariantId, 'variant-alt');
    expect(state.selectedBundleReleaseId, isNull);
    expect(state.selectedTrackingEditionId, 'edition-hc');
    expect(state.selectedTrackingVariantId, 'variant-alt');
  });

  test('owned bundle anchor clears edition and tracking ids', () {
    final state = resolveOwnedAnchorSelectionState(
      anchorType: PersonalItemAnchorType.bundleRelease.apiValue,
      editions: [buildEdition()],
      selectedEditionId: 'edition-hc',
      selectedVariantId: 'variant-alt',
      editionTitle: null,
      variantName: null,
      availableBundleReleaseIds: const ['bundle-1', 'bundle-2'],
    );

    expect(state.selectedEditionId, isNull);
    expect(state.selectedVariantId, isNull);
    expect(state.selectedBundleReleaseId, 'bundle-1');
    expect(state.selectedTrackingEditionId, isNull);
    expect(state.selectedTrackingVariantId, isNull);
  });

  test('wishlist edition anchor clears variant but preserves resolved edition', () {
    final state = resolveWishlistAnchorSelectionState(
      anchorType: PersonalItemAnchorType.edition.apiValue,
      editions: [buildEdition()],
      selectedEditionId: null,
      selectedVariantId: 'variant-main',
      editionTitle: 'Hardcover',
      variantName: 'Main Cover',
      availableBundleReleaseIds: const ['bundle-1'],
    );

    expect(state.anchorType, PersonalItemAnchorType.edition.apiValue);
    expect(state.selectedEditionId, 'edition-hc');
    expect(state.selectedVariantId, isNull);
    expect(state.selectedBundleReleaseId, isNull);
  });
}