import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_physical_media_formats.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_values.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryOwnedItemResolution {
  const LibraryOwnedItemResolution({
    required this.ownedItem,
    this.nextSelectedOwnedItemId,
    this.clearNewest = false,
  });

  final OwnedItem? ownedItem;
  final String? nextSelectedOwnedItemId;
  final bool clearNewest;

  bool shouldScheduleSelection(
    String? currentSelectedOwnedItemId,
    bool currentSelectNewest,
  ) {
    if (ownedItem == null || nextSelectedOwnedItemId == null) {
      return false;
    }
    return nextSelectedOwnedItemId != currentSelectedOwnedItemId ||
        (clearNewest && currentSelectNewest);
  }
}

bool itemHasMissingCover(CatalogItem item) {
  return item.coverImageUrl == null || item.coverImageUrl!.trim().isEmpty;
}

bool itemHasMissingDetails(CatalogItem item) {
  final payload = item.kindMetadata.toSyncPayload();
  final publisher = (payload['publisher'] ??
      (payload['publishing'] as Map?)?['original_publisher']) as String?;
  return (publisher == null || publisher.trim().isEmpty) ||
      libraryKindReleaseDate(item) == null ||
      (item.synopsis == null || item.synopsis!.trim().isEmpty);
}

String? libraryHierarchyContractDiagnosticLabel(LibraryProjectionRuntime item) {
  final kind = item.source.catalogItem?.mediaKind;
  if (kind == null) {
    return null;
  }
  return libraryKindRuntimeForKind(kind)
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

String? libraryOwnedReferenceLabel(OwnedItem? ownedItem, {String? mediaType}) {
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  return _libraryReferenceLabel(
    ownedItem?.personalAnchor,
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
    wishlistItem?.personalAnchor,
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

String? libraryPrimaryReferenceLabel({
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
  String? mediaType,
}) {
  return libraryOwnedReferenceLabel(ownedItem, mediaType: mediaType) ??
      libraryWishlistReferenceLabel(wishlistItem, mediaType: mediaType);
}

String? libraryReferenceScopeLabel({
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
  String? mediaType,
}) {
  final anchor = ownedItem?.personalAnchor ?? wishlistItem?.personalAnchor;
  return _referenceScopeLabelForAnchor(anchor, mediaType: mediaType);
}

String? libraryReferenceFormatLabel({
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
  required List<CatalogEdition> editions,
  String? fallbackFormatLabel,
}) {
  final anchor = ownedItem?.personalAnchor ?? wishlistItem?.personalAnchor;
  if (anchor == PersonalItemAnchorType.bundleRelease) {
    return null;
  }
  final resolved = _resolveLibraryReferenceRelease(
    editionId: ownedItem?.editionId ?? wishlistItem?.editionId,
    variantId: ownedItem?.variantId ?? wishlistItem?.variantId,
    editions: editions,
  );
  final variantLabel = resolved.variant?.physicalFormatLabel?.trim();
  if (variantLabel != null && variantLabel.isNotEmpty) {
    return variantLabel;
  }
  final editionLabel = resolved.edition?.physicalFormatLabel?.trim();
  if (editionLabel != null && editionLabel.isNotEmpty) {
    return editionLabel;
  }
  final fallback = fallbackFormatLabel?.trim();
  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }
  return null;
}

List<String> libraryReferenceHierarchySegments({
  required String mediaType,
  required List<CatalogEdition> editions,
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

({CatalogEdition? edition, CatalogVariant? variant})
    resolveLibraryReferenceRelease({
  required String? editionId,
  required String? variantId,
  required List<CatalogEdition> editions,
}) {
  return _resolveLibraryReferenceRelease(
    editionId: editionId,
    variantId: variantId,
    editions: editions,
  );
}

String? preferredVideoEditionVariantId(CatalogEdition edition) {
  for (final variant in edition.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return edition.variants.isEmpty ? null : edition.variants.first.id;
}

({CatalogEdition? edition, CatalogVariant? variant})
    resolveLibraryEntryReferenceRelease(
  LibraryProjectionRuntime item,
) {
  final releaseNode = item.node is LibraryReleaseNodeRef
      ? (item.node as LibraryReleaseNodeRef)
      : null;
  final catalogItem = item.source.catalogItem;
  return resolveLibraryReferenceRelease(
    editionId: releaseNode?.releaseId,
    variantId: releaseNode != null
        ? preferredVideoEditionVariantId(releaseNode.edition)
        : null,
    editions: catalogItem == null ? const [] : libraryKindEditions(catalogItem),
  );
}

List<String> libraryReferencePlatforms(LibraryProjectionRuntime item) {
  final resolved = resolveLibraryEntryReferenceRelease(item);
  final values = <String>[];
  final variantPlatform = resolved.variant?.platform?.trim();
  if (variantPlatform != null && variantPlatform.isNotEmpty) {
    values.add(variantPlatform);
  }
  final catalogItem = item.source.catalogItem;
  final payload = catalogItem?.kindMetadata.toSyncPayload();
  final gameMap = payload?['game'];
  final rawPlatforms = (gameMap is Map
      ? gameMap['platforms']
      : payload?['platforms']) as List<dynamic>?;
  for (final platform in rawPlatforms ?? const <dynamic>[]) {
    final normalized = platform?.toString().trim() ?? '';
    if (normalized.isEmpty || values.contains(normalized)) {
      continue;
    }
    values.add(normalized);
  }
  return values;
}

String? resolveLibraryOwnedItemId(
  LibraryProjectionRuntime item,
  OwnedItem? ownedItem,
) {
  return ownedItem?.id ?? item.source.ownedItem?.id;
}

({
  String? anchorType,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) resolveLibraryMutationAnchor({
  LibraryProjectionRuntime? item,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
}) {
  final releaseNode = item?.node is LibraryReleaseNodeRef
      ? (item!.node as LibraryReleaseNodeRef)
      : null;
  final editionId = _normalizedEntryAnchorId(
    ownedItem?.editionId ?? wishlistItem?.editionId ?? releaseNode?.releaseId,
  );
  final variantId = _normalizedEntryAnchorId(
    ownedItem?.variantId ??
        wishlistItem?.variantId ??
        (releaseNode != null
            ? preferredVideoEditionVariantId(releaseNode.edition)
            : null),
  );
  final bundleReleaseId = _normalizedEntryAnchorId(
    ownedItem?.bundleReleaseId ?? wishlistItem?.bundleReleaseId,
  );
  return (
    anchorType: resolvePersonalItemAnchorType(
      anchorType: ownedItem?.anchorType ?? wishlistItem?.anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    ),
    editionId: editionId,
    variantId: variantId,
    bundleReleaseId: bundleReleaseId,
  );
}

TrackingEntry? resolveActiveTrackingEntry(
  List<TrackingEntry> entries,
  OwnedItem? activeOwnedItem,
) {
  if (entries.isEmpty) {
    return null;
  }
  if (activeOwnedItem != null) {
    for (final entry in entries) {
      if (entry.ownedItemId == activeOwnedItem.id) {
        return entry;
      }
    }
  }
  for (final entry in entries) {
    if (entry.ownedItemId == null) {
      return entry;
    }
  }
  return entries.first;
}

LibraryOwnedItemResolution resolveActiveOwnedItem(
  List<OwnedItem> ownedCopies, {
  OwnedItem? fallback,
  String? selectedOwnedItemId,
  bool selectNewest = false,
}) {
  if (ownedCopies.isEmpty) {
    return LibraryOwnedItemResolution(ownedItem: fallback);
  }
  if (selectNewest) {
    final newest = ownedCopies.first;
    return LibraryOwnedItemResolution(
      ownedItem: newest,
      nextSelectedOwnedItemId: newest.id,
      clearNewest: true,
    );
  }
  if (selectedOwnedItemId != null) {
    for (final item in ownedCopies) {
      if (item.id == selectedOwnedItemId) {
        return LibraryOwnedItemResolution(ownedItem: item);
      }
    }
  }
  final resolved = fallback != null
      ? ownedCopies.firstWhere(
          (item) => item.id == fallback.id,
          orElse: () => ownedCopies.first,
        )
      : ownedCopies.first;
  return LibraryOwnedItemResolution(
    ownedItem: resolved,
    nextSelectedOwnedItemId: resolved.id,
  );
}

String? _libraryReferenceLabel(
  PersonalItemAnchorType? anchor, {
  required String itemLabel,
  required String editionLabel,
  required String variantLabel,
  required String bundleLabel,
}) {
  return switch (anchor) {
    PersonalItemAnchorType.item => itemLabel,
    PersonalItemAnchorType.edition => editionLabel,
    PersonalItemAnchorType.variant => variantLabel,
    PersonalItemAnchorType.bundleRelease => bundleLabel,
    null => null,
  };
}

String? _referenceScopeLabelForAnchor(
  PersonalItemAnchorType? anchor, {
  String? mediaType,
}) {
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  return switch (anchor) {
    PersonalItemAnchorType.item => labels.labelFor('item', fallback: 'Media'),
    PersonalItemAnchorType.edition =>
      labels.labelFor('edition', fallback: 'Edition'),
    PersonalItemAnchorType.variant =>
      labels.labelFor('variant', fallback: 'Physical release'),
    PersonalItemAnchorType.bundleRelease =>
      labels.labelFor('bundle', fallback: 'Bundle'),
    null => null,
  };
}

LibraryReferenceLabels _libraryReferenceLabelsForMediaType(String? mediaType) {
  return libraryKindRuntimeForKind(catalogMediaKindFromValue(mediaType))
      .presentation
      .referenceLabels;
}

String buildOwnedCopyLabel(
  OwnedItem item,
  List<CatalogEdition> editions,
  int index,
) {
  final parts = <String>['Copy ${index + 1}'];
  final editionLabel = _ownedCopyEditionLabel(item, editions);
  if (editionLabel != null) {
    parts.add(editionLabel);
  }
  final copyTypeLabel = libraryOwnedCopyTypeLabel(item, editions);
  if (copyTypeLabel != null) {
    parts.add(copyTypeLabel);
  }
  if (item.condition != null && item.condition!.trim().isNotEmpty) {
    parts.add(item.condition!.trim());
  }
  if (item.grade != null && item.grade!.trim().isNotEmpty) {
    parts.add(item.grade!.trim());
  }
  if (item.locationId != null && item.locationId!.trim().isNotEmpty) {
    parts.add(item.locationId!.trim());
  }
  final purchaseLabel = formatNullableDate(item.purchaseDate);
  if (purchaseLabel != null) {
    parts.add(purchaseLabel);
  }
  return parts.join('  ·  ');
}

String? libraryOwnedCopyTypeLabel(
  OwnedItem? ownedItem,
  List<CatalogEdition> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
}) {
  final digital = resolveOwnedDigitalFlag(
    ownedItem,
    editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
  );
  return ownedCopyTypeLabel(digital);
}

bool? resolveOwnedDigitalFlag(
  OwnedItem? ownedItem,
  List<CatalogEdition> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
}) {
  if (ownedItem == null) {
    return null;
  }
  if (ownedItem.isDigital != null) {
    return ownedItem.isDigital;
  }

  final matchedRelease = _resolveOwnedCopyRelease(ownedItem, editions);
  final matchedEdition = matchedRelease.edition;
  final matchedVariant = matchedRelease.variant;

  final variantFlag = digitalPhysicalMediaFormatFlag(
    matchedVariant?.physicalFormat,
    label: matchedVariant?.physicalFormatLabel ?? matchedVariant?.name,
    formats: allKnownPhysicalMediaFormats,
  );
  if (variantFlag != null) {
    return variantFlag;
  }

  final editionFlag = digitalPhysicalMediaFormatFlag(
    matchedEdition?.physicalFormat,
    label: matchedEdition?.physicalFormatLabel ?? matchedEdition?.title,
    formats: allKnownPhysicalMediaFormats,
  );
  if (editionFlag != null) {
    return editionFlag;
  }

  return digitalPhysicalMediaFormatFlag(
    fallbackFormat,
    label: fallbackLabel,
    formats: allKnownPhysicalMediaFormats,
  );
}

String? _normalizedEntryAnchorId(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String? _ownedCopyEditionLabel(OwnedItem item, List<CatalogEdition> editions) {
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

({CatalogEdition? edition, CatalogVariant? variant}) _resolveOwnedCopyRelease(
  OwnedItem item,
  List<CatalogEdition> editions,
) {
  return _resolveLibraryReferenceRelease(
    editionId: item.editionId,
    variantId: item.variantId,
    editions: editions,
  );
}

({CatalogEdition? edition, CatalogVariant? variant})
    _resolveLibraryReferenceRelease({
  required String? editionId,
  required String? variantId,
  required List<CatalogEdition> editions,
}) {
  CatalogEdition? matchedEdition;
  CatalogVariant? matchedVariant;
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
        matchedEdition != null ? <CatalogEdition>[matchedEdition] : editions;
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

Set<String> watchWishlistIds(WidgetRef ref) {
  return ref.watch(wishlistIdsProvider).maybeWhen(
        data: (ids) => ids,
        orElse: () => const <String>{},
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
