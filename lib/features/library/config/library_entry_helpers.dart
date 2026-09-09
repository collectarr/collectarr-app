import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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

String? libraryHierarchyContractDiagnosticLabel(LibraryProjectionView item) {
  final kind = item.source.catalogItem?.mediaKind;
  if (kind == null) {
    return null;
  }
  return libraryKindModuleForKind(kind).hierarchy.contractDiagnosticLabel(item);
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
    libraryPersonalAnchorForCatalogRef(wishlistItem?.catalogRef)?.type,
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
  final anchorType = ownedItem?.personalAnchor ??
      libraryPersonalAnchorForCatalogRef(wishlistItem?.catalogRef)?.type;
  return _referenceScopeLabelForAnchor(anchorType, mediaType: mediaType);
}

String? libraryReferenceFormatLabel({
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
  required List<CatalogEditionDto> editions,
  String? fallbackFormatLabel,
}) {
  final anchorType = ownedItem?.personalAnchor ??
      libraryPersonalAnchorForCatalogRef(wishlistItem?.catalogRef)?.type;
  if (anchorType == PersonalItemAnchorType.bundleRelease) {
    return null;
  }
  final resolved = _resolveLibraryReferenceRelease(
    editionId: ownedItem?.anchor?.editionId ??
        _catalogRefEditionId(wishlistItem?.catalogRef),
    variantId: ownedItem?.anchor?.variantId ??
        _catalogRefVariantId(wishlistItem?.catalogRef),
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
  final catalogItem = item.source.catalogItem;
  return resolveLibraryReferenceRelease(
    editionId: releaseNode?.releaseId,
    variantId: releaseNode != null
        ? preferredVideoEditionVariantId(releaseNode.edition)
        : null,
    editions: catalogItem == null ? const [] : catalogItem.editions,
  );
}

String? resolveLibraryOwnedItemId(
  LibraryProjectionView item,
  OwnedItem? ownedItem,
) {
  return ownedItem?.id ?? item.source.ownedItem?.id;
}

OwnedItemRef? resolveLibraryOwnedItemRef(
  LibraryProjectionView item,
  OwnedItem? ownedItem,
) {
  return ownedItem?.ref ?? item.source.ownedRef;
}

PersonalItemAnchor? resolveLibraryMutationAnchor({
  LibraryProjectionView? item,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
}) {
  final existingAnchor = ownedItem?.anchor ??
      libraryPersonalAnchorForCatalogRef(wishlistItem?.catalogRef);
  if (existingAnchor != null) {
    return existingAnchor;
  }

  final releaseNode = item?.node is LibraryReleaseNodeRef
      ? (item!.node as LibraryReleaseNodeRef)
      : null;
  if (releaseNode == null) {
    return null;
  }
  return PersonalItemAnchor.fromRaw(
    editionId: _normalizedEntryAnchorId(releaseNode.releaseId),
    variantId: _normalizedEntryAnchorId(
      preferredVideoEditionVariantId(releaseNode.edition),
    ),
  );
}

PersonalItemAnchor? libraryPersonalAnchorForCatalogRef(CatalogEntityRef? ref) {
  if (ref == null) {
    return null;
  }
  return switch (ref.entityType) {
    CatalogEntityType.edition => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.edition.apiValue,
        editionId: ref.id,
      ),
    CatalogEntityType.release => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.variant.apiValue,
        variantId: ref.id,
      ),
    CatalogEntityType.bundleRelease => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.bundleRelease.apiValue,
        bundleReleaseId: ref.id,
      ),
    _ => PersonalItemAnchor.fromRaw(
        anchorType: PersonalItemAnchorType.item.apiValue,
      ),
  };
}

String? _catalogRefEditionId(CatalogEntityRef? ref) {
  return ref?.entityType == CatalogEntityType.edition ? ref?.id : null;
}

String? _catalogRefVariantId(CatalogEntityRef? ref) {
  return ref?.entityType == CatalogEntityType.release ? ref?.id : null;
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

LibraryPresentationLabels _libraryReferenceLabelsForMediaType(
    String? mediaType) {
  return libraryKindModuleForKind(catalogMediaKindFromValue(mediaType))
      .presentation
      .referenceLabels;
}

String buildOwnedCopyLabel(
  OwnedItem item,
  List<CatalogEditionDto> editions,
  int index, {
  required LibraryOwnedDigitalFlagResolver digitalFlagResolver,
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
    OwnedItem item, List<CatalogEditionDto> editions) {
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
  OwnedItem item,
  List<CatalogEditionDto> editions,
) {
  return _resolveLibraryReferenceRelease(
    editionId: item.anchor?.editionId,
    variantId: item.anchor?.variantId,
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
