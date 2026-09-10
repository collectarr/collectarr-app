import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/edit/anchor_selection_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CatalogEditionDto buildEdition() {
    return const CatalogEditionDto(
      id: 'edition-hc',
      title: 'Hardcover',
      variants: [
        CatalogVariantDto(
          id: 'variant-main',
          name: 'Main Cover',
          isPrimary: true,
        ),
        CatalogVariantDto(
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
      anchorType: 'variant',
      editions: [buildEdition()],
      selectedEditionId: 'edition-hc',
      selectedVariantId: 'variant-alt',
      editionTitle: null,
      variantName: null,
      availableBundleReleaseIds: const ['bundle-1'],
    );

    expect(state.anchorType, 'variant');
    expect(state.selectedEditionId, 'edition-hc');
    expect(state.selectedVariantId, 'variant-alt');
    expect(state.selectedBundleReleaseId, isNull);
    expect(state.selectedTrackingEditionId, 'edition-hc');
    expect(state.selectedTrackingVariantId, 'variant-alt');
  });

  test('owned bundle anchor clears edition and tracking ids', () {
    final state = resolveOwnedAnchorSelectionState(
      anchorType: 'bundle_release',
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
}
