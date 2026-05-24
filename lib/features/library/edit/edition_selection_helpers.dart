import 'package:collectarr_app/core/models/catalog_item.dart';

class LibraryEditionSelection {
  const LibraryEditionSelection({
    required this.edition,
    required this.variant,
  });

  final CatalogEdition? edition;
  final CatalogVariant? variant;
}

LibraryEditionSelection resolveLibraryEditionSelection(
  List<CatalogEdition> editions, {
  String? editionId,
  String? editionTitle,
  String? variantId,
  String? variantName,
}) {
  final selectedEdition = _resolveEdition(
    editions,
    editionId: editionId,
    editionTitle: editionTitle,
    variantId: variantId,
    variantName: variantName,
  );
  return LibraryEditionSelection(
    edition: selectedEdition,
    variant: resolveVariantForEdition(
      selectedEdition,
      variantId: variantId,
      variantName: variantName,
    ),
  );
}

CatalogVariant? resolveVariantForEdition(
  CatalogEdition? edition, {
  String? variantId,
  String? variantName,
}) {
  if (edition == null || edition.variants.isEmpty) {
    return null;
  }
  final normalizedVariantId = _normalized(variantId);
  if (normalizedVariantId != null) {
    for (final variant in edition.variants) {
      if (variant.id == normalizedVariantId) {
        return variant;
      }
    }
  }
  final normalizedVariantName = _normalized(variantName);
  if (normalizedVariantName != null) {
    for (final variant in edition.variants) {
      if (_normalized(variant.name) == normalizedVariantName) {
        return variant;
      }
    }
  }
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant;
    }
  }
  return edition.variants.first;
}

CatalogEdition? _resolveEdition(
  List<CatalogEdition> editions, {
  String? editionId,
  String? editionTitle,
  String? variantId,
  String? variantName,
}) {
  if (editions.isEmpty) {
    return null;
  }
  final normalizedEditionId = _normalized(editionId);
  if (normalizedEditionId != null) {
    for (final edition in editions) {
      if (edition.id == normalizedEditionId) {
        return edition;
      }
    }
  }
  final normalizedEditionTitle = _normalized(editionTitle);
  if (normalizedEditionTitle != null) {
    for (final edition in editions) {
      if (_normalized(edition.title) == normalizedEditionTitle) {
        return edition;
      }
    }
  }
  final normalizedVariantId = _normalized(variantId);
  if (normalizedVariantId != null) {
    for (final edition in editions) {
      for (final variant in edition.variants) {
        if (variant.id == normalizedVariantId) {
          return edition;
        }
      }
    }
  }
  final normalizedVariantName = _normalized(variantName);
  if (normalizedVariantName != null) {
    for (final edition in editions) {
      for (final variant in edition.variants) {
        if (_normalized(variant.name) == normalizedVariantName) {
          return edition;
        }
      }
    }
  }
  for (final edition in editions) {
    if (edition.variants.any((variant) => variant.isPrimary)) {
      return edition;
    }
  }
  return editions.first;
}

String? _normalized(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed.toLowerCase();
}