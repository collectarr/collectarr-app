import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _itemAnchor = 'item';
const _editionAnchor = 'edition';
const _variantAnchor = 'variant';
const _bundleReleaseAnchor = 'bundle_release';

String? libraryHierarchyContractDiagnosticLabel(LibraryProjectionView item) {
  final kind = item.source.mediaKind;
  if (kind.isUnknown) return null;
  return libraryKindRegistrationForKind(kind)
      .hierarchy
      .contractDiagnosticLabel(item);
}

String libraryVolumeDisplayValue(double? volumeNumber) {
  if (volumeNumber == null) {
    return '-';
  }
  final rounded = volumeNumber.roundToDouble();
  if ((volumeNumber - rounded).abs() < 1e-9) {
    return rounded.toInt().toString();
  }
  return volumeNumber.toString();
}

String libraryVolumeLabel(double? volumeNumber) =>
    'Vol. ${libraryVolumeDisplayValue(volumeNumber)}';

String? libraryOwnedReferenceLabel(
  OwnedItemSummary? ownedItem, {
  String? mediaType,
}) {
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  return _libraryReferenceLabel(
    libraryTargetScopeForCatalogRef(ownedItem?.targetRef),
    itemLabel:
        'Owned as ${labels.labelFor('item', fallback: 'Media').toLowerCase()}',
    editionLabel:
        'Owned as ${labels.labelFor('edition', fallback: 'Edition').toLowerCase()}',
    variantLabel:
        'Owned as ${labels.labelFor('variant', fallback: 'Physical release').toLowerCase()}',
    bundleLabel:
        'Owned as ${labels.labelFor('bundle', fallback: 'Bundle').toLowerCase()}',
  );
}

String? libraryWishlistReferenceLabel(
  WishlistItem? wishlistItem, {
  String? mediaType,
}) {
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  return _libraryReferenceLabel(
    libraryTargetScopeForCatalogRef(wishlistItem?.catalogRef),
    itemLabel:
        'Wishlisted as ${labels.labelFor('item', fallback: 'Media').toLowerCase()}',
    editionLabel:
        'Wishlisted as ${labels.labelFor('edition', fallback: 'Edition').toLowerCase()}',
    variantLabel:
        'Wishlisted as ${labels.labelFor('variant', fallback: 'Physical release').toLowerCase()}',
    bundleLabel:
        'Wishlisted as ${labels.labelFor('bundle', fallback: 'Bundle').toLowerCase()}',
  );
}

List<String> libraryReferenceHierarchySegments({
  required String mediaType,
  required List<CatalogEditionDto> editions,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  final segments = <String>[
    labels.labelFor('item', fallback: 'Media'),
  ];
  final normalizedBundleId = bundleReleaseId?.trim();
  if (normalizedBundleId != null && normalizedBundleId.isNotEmpty) {
    segments
        .add(labels.labelFor('bundle_hierarchy', fallback: 'Bundle release'));
    return segments;
  }
  final resolved = _resolveLibraryReferenceRelease(
    editionId: editionId,
    variantId: variantId,
    editions: editions,
  );
  final editionTitle = resolved.edition?.title.trim();
  if (editionTitle != null && editionTitle.isNotEmpty) {
    segments.add(
      '${labels.labelFor('edition_hierarchy', fallback: 'Edition')}: $editionTitle',
    );
  }
  final variantName = resolved.variant?.name.trim();
  if (variantName != null && variantName.isNotEmpty) {
    segments.add(
      '${labels.labelFor('variant_hierarchy', fallback: 'Physical')}: $variantName',
    );
  }
  return segments;
}

/// Returns the kind-owned card projection consumed by shared workspace chrome.
/// The host renders only these structural values; it never reads semantic
/// fields from an erased workspace DTO.
LibraryCardPresentation libraryCardPresentationForEntry(
  LibraryProjectionView item, {
  bool musicVertical = false,
}) {
  return libraryKindRegistrationForKind(item.source.mediaKind)
      .presentation
      .buildCardPresentation(
        item,
        musicVertical: musicVertical,
      );
}

List<String> libraryWorkspaceReferenceHierarchySegments({
  required String mediaType,
  required List<LibraryWorkspaceReleaseSummary> releases,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  final segments = <String>[labels.labelFor('item', fallback: 'Media')];
  final normalizedBundleId = bundleReleaseId?.trim();
  if (normalizedBundleId != null && normalizedBundleId.isNotEmpty) {
    segments.add(
      labels.labelFor('bundle_hierarchy', fallback: 'Bundle release'),
    );
    return segments;
  }
  final normalizedEditionId = editionId?.trim();
  LibraryWorkspaceReleaseSummary? release;
  if (normalizedEditionId != null && normalizedEditionId.isNotEmpty) {
    for (final candidate in releases) {
      if (candidate.id == normalizedEditionId) {
        release = candidate;
        break;
      }
    }
  }
  if (release != null && release.title.trim().isNotEmpty) {
    segments.add(
      '${labels.labelFor('edition_hierarchy', fallback: 'Edition')}: ${release.title.trim()}',
    );
  }
  final normalizedVariantId = variantId?.trim();
  if (normalizedVariantId != null && normalizedVariantId.isNotEmpty) {
    final variant = release?.variants
        .where((candidate) => candidate.id == normalizedVariantId)
        .firstOrNull;
    final variantName = variant?.name.trim();
    segments.add(
      '${labels.labelFor('variant_hierarchy', fallback: 'Physical')}: ${variantName?.isNotEmpty == true ? variantName : normalizedVariantId}',
    );
  }
  return segments;
}

({CatalogEditionDto? edition, CatalogVariantDto? variant})
    resolveLibraryReferenceRelease({
  required String? editionId,
  required String? variantId,
  required List<CatalogEditionDto> editions,
}) {
  return _resolveLibraryReferenceRelease(
    editionId: editionId,
    variantId: variantId,
    editions: editions,
  );
}

String? preferredVideoEditionVariantId(CatalogEditionDto edition) {
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return edition.variants.isEmpty ? null : edition.variants.first.id;
}

({CatalogEditionDto? edition, CatalogVariantDto? variant})
    resolveLibraryEntryReferenceRelease(
  LibraryProjectionView item,
) {
  final releaseNode = item.node is LibraryReleaseNodeRef
      ? (item.node as LibraryReleaseNodeRef)
      : null;
  return resolveLibraryReferenceRelease(
    editionId: releaseNode?.releaseId,
    variantId: releaseNode != null
        ? preferredVideoEditionVariantId(releaseNode.edition)
        : null,
    editions: releaseNode == null
        ? const []
        : <CatalogEditionDto>[releaseNode.edition],
  );
}

OwnedItemRef? resolveLibraryOwnedItemRef(
  LibraryProjectionView item,
  OwnedItemSummary? ownedItem,
) {
  return ownedItem?.ref ?? item.source.ownedRef;
}

OwnedItemRef? resolveLibraryOwnedSummaryRef(
  LibraryProjectionView item,
  OwnedItemSummary? ownedItem,
) {
  return ownedItem?.ref ?? item.source.ownedRef;
}

CatalogEntityRef? resolveLibraryMutationTargetFromSummary({
  LibraryProjectionView? item,
  OwnedItemSummary? ownedItem,
  WishlistItem? wishlistItem,
}) {
  final existingTarget = ownedItem?.targetRef ?? wishlistItem?.catalogRef;
  if (existingTarget != null) {
    return existingTarget;
  }
  final releaseNode = item?.node is LibraryReleaseNodeRef
      ? (item!.node as LibraryReleaseNodeRef)
      : null;
  if (releaseNode == null) return null;
  final sourceRef = item?.source.catalogRef;
  if (sourceRef == null) return null;
  return catalogRefForLibrarySelection(
    sourceRef,
    editionId: _normalizedEntryAnchorId(releaseNode.releaseId),
    variantId: _normalizedEntryAnchorId(
      preferredVideoEditionVariantId(releaseNode.edition),
    ),
  );
}

String? libraryTargetScopeForCatalogRef(CatalogEntityRef? ref) {
  if (ref == null) {
    return null;
  }
  return switch (ref.entityType.apiValue) {
    'edition' => _editionAnchor,
    'release' => _variantAnchor,
    'bundle_release' => _bundleReleaseAnchor,
    _ => _itemAnchor,
  };
}

TrackingRecord? resolveActiveTrackingLifecycle(
  List<TrackingRecord> entries,
  OwnedItemSummary? activeOwnedItem,
) {
  if (entries.isEmpty) {
    return null;
  }
  if (activeOwnedItem != null) {
    for (final entry in entries) {
      if (entry.ownedRef == activeOwnedItem.ref) {
        return entry;
      }
    }
  }
  for (final entry in entries) {
    if (entry.ownedRef == null) {
      return entry;
    }
  }
  return entries.first;
}

TrackingSummary? resolveActiveTrackingSummary(
  List<TrackingSummary> entries,
  OwnedItemSummary? activeOwnedItem,
) {
  if (entries.isEmpty) {
    return null;
  }
  if (activeOwnedItem != null) {
    for (final entry in entries) {
      if (entry.ownedRef == activeOwnedItem.ref) {
        return entry;
      }
    }
  }
  for (final entry in entries) {
    if (entry.ownedRef == null) {
      return entry;
    }
  }
  return entries.first;
}

class LibraryOwnedSummaryResolution {
  const LibraryOwnedSummaryResolution({
    required this.ownedItem,
    this.nextSelectedOwnedItemRef,
    this.clearNewest = false,
  });

  final OwnedItemSummary? ownedItem;
  final OwnedItemRef? nextSelectedOwnedItemRef;
  final bool clearNewest;
}

LibraryOwnedSummaryResolution resolveActiveOwnedSummary(
  List<OwnedItemSummary> ownedCopies, {
  OwnedItemSummary? fallback,
  OwnedItemRef? selectedOwnedItemRef,
  bool selectNewest = false,
}) {
  if (ownedCopies.isEmpty) {
    return LibraryOwnedSummaryResolution(ownedItem: fallback);
  }
  if (selectNewest) {
    final newest = ownedCopies.first;
    return LibraryOwnedSummaryResolution(
      ownedItem: newest,
      nextSelectedOwnedItemRef: newest.ref,
      clearNewest: true,
    );
  }
  if (selectedOwnedItemRef != null) {
    for (final item in ownedCopies) {
      if (item.ref == selectedOwnedItemRef) {
        return LibraryOwnedSummaryResolution(ownedItem: item);
      }
    }
  }
  final resolved = fallback == null
      ? ownedCopies.first
      : ownedCopies.firstWhere(
          (item) => item.ref == fallback.ref,
          orElse: () => ownedCopies.first,
        );
  return LibraryOwnedSummaryResolution(
    ownedItem: resolved,
    nextSelectedOwnedItemRef: resolved.ref,
  );
}

String buildOwnedCopySummaryLabel(OwnedItemSummary item, int index) {
  final parts = <String>['Copy ${index + 1}'];
  final quantity = item.quantity;
  if (quantity > 1) {
    parts.add('Qty $quantity');
  }
  final location = item.locationLabel?.trim();
  if (location != null && location.isNotEmpty) {
    parts.add(location);
  }
  final purchaseLabel = formatNullableDate(item.purchaseDate);
  if (purchaseLabel != null) {
    parts.add(purchaseLabel);
  }
  return parts.join('  Ã‚Â·  ');
}

String? _libraryReferenceLabel(
  String? anchor, {
  required String itemLabel,
  required String editionLabel,
  required String variantLabel,
  required String bundleLabel,
}) {
  if (anchor == _itemAnchor) return itemLabel;
  if (anchor == _editionAnchor) return editionLabel;
  if (anchor == _variantAnchor) return variantLabel;
  if (anchor == _bundleReleaseAnchor) return bundleLabel;
  return null;
}

LibraryPresentationLabels _libraryReferenceLabelsForMediaType(
    String? mediaType) {
  return libraryKindRegistrationForKind(catalogMediaKindFromValue(mediaType))
      .presentation
      .referenceLabels;
}

String buildOwnedCopyLabel(
  OwnedItemSummary item,
  List<CatalogEditionDto> editions,
  int index, {
  required LibraryOwnedDigitalFlagResolver digitalFlagResolver,
  String? collectionValue,
}) {
  final parts = <String>['Copy ${index + 1}'];
  final editionLabel = _ownedCopyEditionLabel(item, editions);
  if (editionLabel != null) {
    parts.add(editionLabel);
  }
  final copyTypeLabel = libraryOwnedCopyTypeLabel(
    item,
    editions,
    digitalFlagResolver: digitalFlagResolver,
  );
  if (copyTypeLabel != null) {
    parts.add(copyTypeLabel);
  }
  if (collectionValue != null && collectionValue.trim().isNotEmpty) {
    parts.add(collectionValue.trim());
  }
  if (item.locationLabel != null && item.locationLabel!.trim().isNotEmpty) {
    parts.add(item.locationLabel!.trim());
  }
  final purchaseLabel = formatNullableDate(item.purchaseDate);
  if (purchaseLabel != null) {
    parts.add(purchaseLabel);
  }
  return parts.join('  Ã‚Â·  ');
}

String? buildOwnedCopyLabelFromWorkspaceReleases(
  OwnedItemSummary? item,
  List<LibraryWorkspaceReleaseSummary> releases,
  int index, {
  String? collectionValue,
}) {
  if (item == null) return null;
  final parts = <String>['Copy ${index + 1}'];
  final releaseId = catalogRefEditionId(item.targetRef);
  final variantId = catalogRefVariantId(item.targetRef);
  LibraryWorkspaceReleaseSummary? release;
  if (releaseId != null) {
    release = releases.where((value) => value.id == releaseId).firstOrNull;
  }
  final releaseTitle = release?.title.trim();
  if (releaseTitle != null && releaseTitle.isNotEmpty) {
    parts.add(releaseTitle);
  }
  final variant = variantId == null
      ? null
      : release?.variants.where((value) => value.id == variantId).firstOrNull;
  final variantName = variant?.name.trim();
  if (variantName != null && variantName.isNotEmpty) {
    parts.add(variantName);
  } else {
    final format = release?.formatLabel?.trim();
    if (format != null && format.isNotEmpty) {
      parts.add(format);
    }
  }
  final collectionLabel = collectionValue?.trim();
  if (collectionLabel != null && collectionLabel.isNotEmpty) {
    parts.add(collectionLabel);
  }
  if (item.purchaseDate case final date?) {
    parts.add(formatNullableDate(date) ?? '');
  }
  return parts.where((value) => value.isNotEmpty).join('  Ã‚Â·  ');
}

String? libraryOwnedCopyTypeLabel(
  OwnedItemSummary? ownedItem,
  List<CatalogEditionDto> editions, {
  required LibraryOwnedDigitalFlagResolver digitalFlagResolver,
  String? fallbackFormat,
  String? fallbackLabel,
}) {
  final digital = digitalFlagResolver(
    ownedItem,
    editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: const [],
  );
  return ownedCopyTypeLabel(digital);
}

String? _normalizedEntryAnchorId(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String? _ownedCopyEditionLabel(
    OwnedItemSummary item, List<CatalogEditionDto> editions) {
  final matchedRelease = _resolveOwnedCopyRelease(item, editions);
  final matchedEdition = matchedRelease.edition;
  final matchedVariant = matchedRelease.variant;

  final parts = <String>[];
  final editionTitle = matchedEdition?.title.trim();
  if (editionTitle != null && editionTitle.isNotEmpty) {
    parts.add(editionTitle);
  }
  final variantName = matchedVariant?.name.trim();
  if (variantName != null &&
      variantName.isNotEmpty &&
      !parts.contains(variantName)) {
    parts.add(variantName);
  }
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' / ');
}

({CatalogEditionDto? edition, CatalogVariantDto? variant})
    _resolveOwnedCopyRelease(
  OwnedItemSummary item,
  List<CatalogEditionDto> editions,
) {
  return _resolveLibraryReferenceRelease(
    editionId: catalogRefEditionId(item.targetRef),
    variantId: catalogRefVariantId(item.targetRef),
    editions: editions,
  );
}

({CatalogEditionDto? edition, CatalogVariantDto? variant})
    _resolveLibraryReferenceRelease({
  required String? editionId,
  required String? variantId,
  required List<CatalogEditionDto> editions,
}) {
  CatalogEditionDto? matchedEdition;
  CatalogVariantDto? matchedVariant;
  if (editionId != null) {
    for (final edition in editions) {
      if (edition.id == editionId) {
        matchedEdition = edition;
        break;
      }
    }
  }
  if (variantId != null) {
    final editionPool =
        matchedEdition != null ? <CatalogEditionDto>[matchedEdition] : editions;
    for (final edition in editionPool) {
      for (final variant in edition.variants) {
        if (variant.id == variantId) {
          matchedEdition ??= edition;
          matchedVariant = variant;
          break;
        }
      }
      if (matchedVariant != null) {
        break;
      }
    }
  }
  return (edition: matchedEdition, variant: matchedVariant);
}

Set<CatalogEntityRef> watchWishlistRefs(WidgetRef ref) {
  return ref.watch(wishlistRefsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <CatalogEntityRef>{},
      );
}

String formatMoney(int? cents, String? currency) {
  if (cents == null) {
    return '';
  }
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final fraction = (absolute % 100).toString().padLeft(2, '0');
  final prefix = currency == null || currency.isEmpty ? '' : '$currency ';
  return '$prefix$sign$whole.$fraction';
}

List<String> libraryCreatorNameList(List<Map<String, dynamic>>? creators) {
  if (creators == null || creators.isEmpty) {
    return const <String>[];
  }
  final seen = <String>{};
  final values = <String>[];
  for (final creator in creators) {
    final name = creator['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      continue;
    }
    final key = name.toLowerCase();
    if (seen.add(key)) {
      values.add(name);
    }
  }
  return values;
}

List<(String, String)> libraryCreatorsGroupedByRole(
  List<Map<String, dynamic>>? creators,
) {
  if (creators == null || creators.isEmpty) {
    return const <(String, String)>[];
  }
  final grouped = <String, List<String>>{};
  for (final creator in creators) {
    final role = (creator['role']?.toString().trim().isNotEmpty == true)
        ? creator['role']!.toString().trim()
        : 'Credit';
    final name = creator['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      continue;
    }
    grouped.putIfAbsent(role, () => <String>[]).add(name);
  }
  if (grouped.isEmpty) {
    return const <(String, String)>[];
  }
  final rows = <(String, String)>[];
  final sortedRoles = grouped.keys.toList(growable: false)..sort();
  for (final role in sortedRoles) {
    final names = grouped[role]!..sort();
    rows.add((role, names.join(', ')));
  }
  return rows;
}

String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}

String? formatNullableDate(DateTime? value) {
  return value == null ? null : formatDate(value);
}

String formatLibraryTimestamp(
  DateTime? value, {
  String nullLabel = '-',
  bool includeSeconds = true,
}) {
  if (value == null) {
    return nullLabel;
  }
  final local = value.toLocal();
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  final time = includeSeconds
      ? '${twoDigits(local.hour)}:${twoDigits(local.minute)}:${twoDigits(local.second)}'
      : '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  return '${months[local.month - 1]} ${local.day}, ${local.year} $time';
}
