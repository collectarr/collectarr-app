import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
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

bool itemHasMissingCover(LibraryMetadataItem item) {
  return item.coverImageUrl == null || item.coverImageUrl!.trim().isEmpty;
}

bool itemHasMissingDetails(LibraryMetadataItem item) {
  return (item.publisher == null || item.publisher!.trim().isEmpty) ||
      item.releaseDate == null ||
      (item.synopsis == null || item.synopsis!.trim().isEmpty);
}

bool libraryShowsTrackData(Object? mediaType) {
  return collectarrLibraryTypes
          .byKind(mediaType)
          ?.capabilities
          .showsTrackData ??
      false;
}

bool libraryShowsSynopsis(Object? mediaType) {
  return collectarrLibraryTypes.byKind(mediaType)?.capabilities.showsSynopsis ??
      false;
}

String? libraryHierarchyContractDiagnosticLabel(LibraryWorkspaceEntry entry) {
  final seriesTitle = entry.series?.seriesTitle?.trim();
  if (seriesTitle == null || seriesTitle.isEmpty) {
    return 'Missing series title';
  }
  if (entry.browseScope != LibraryBrowserScope.title) {
    final variant = entry.variant?.trim();
    if (variant == null || variant.isEmpty) {
      return 'Missing release variant';
    }
  }
  return null;
}

bool libraryShowsReadingQueue(Object? mediaType) {
  final type = collectarrLibraryTypes.byKind(mediaType);
  if (type == null) {
    return false;
  }
  return type.trackingProfile.name == readingTrackingProfile.name;
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
    itemLabel: labels.ownedAsItem,
    editionLabel: labels.ownedAsEdition,
    variantLabel: labels.ownedAsVariant,
    bundleLabel: labels.ownedAsBundle,
  );
}

String? libraryWishlistReferenceLabel(
  WishlistItem? wishlistItem, {
  String? mediaType,
}) {
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  return _libraryReferenceLabel(
    wishlistItem?.personalAnchor,
    itemLabel: labels.wishlistedAsItem,
    editionLabel: labels.wishlistedAsEdition,
    variantLabel: labels.wishlistedAsVariant,
    bundleLabel: labels.wishlistedAsBundle,
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
  final segments = <String>[labels.itemScope];
  final normalizedBundleId = bundleReleaseId?.trim();
  if (normalizedBundleId != null && normalizedBundleId.isNotEmpty) {
    segments.add(labels.bundleHierarchy);
    return segments;
  }
  final resolved = _resolveLibraryReferenceRelease(
    editionId: editionId,
    variantId: variantId,
    editions: editions,
  );
  final editionTitle = resolved.edition?.title.trim();
  if (editionTitle != null && editionTitle.isNotEmpty) {
    segments.add('${labels.editionHierarchy}: $editionTitle');
  }
  final variantName = resolved.variant?.name.trim();
  if (variantName != null && variantName.isNotEmpty) {
    segments.add('${labels.variantHierarchy}: $variantName');
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

({CatalogEdition? edition, CatalogVariant? variant})
    resolveLibraryEntryReferenceRelease(
  LibraryWorkspaceEntry entry,
) {
  return resolveLibraryReferenceRelease(
    editionId: entry.referenceEditionId,
    variantId: entry.referenceVariantId,
    editions: entry.editions,
  );
}

List<String> libraryReferencePlatforms(LibraryWorkspaceEntry entry) {
  final resolved = resolveLibraryEntryReferenceRelease(entry);
  final values = <String>[];
  final variantPlatform = resolved.variant?.platform?.trim();
  if (variantPlatform != null && variantPlatform.isNotEmpty) {
    values.add(variantPlatform);
  }
  final rawPlatforms = entry.game?.platforms ?? entry.rawPlatforms;
  for (final platform in rawPlatforms ?? const <String>[]) {
    final normalized = platform.trim();
    if (normalized.isEmpty || values.contains(normalized)) {
      continue;
    }
    values.add(normalized);
  }
  return values;
}

String? resolveLibraryOwnedItemId(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
) {
  return ownedItem?.id ?? entry.ownedItemId;
}

({
  String? anchorType,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) resolveLibraryMutationAnchor({
  LibraryWorkspaceEntry? entry,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
}) {
  final editionId = _normalizedEntryAnchorId(
    ownedItem?.editionId ??
        wishlistItem?.editionId ??
        entry?.referenceEditionId,
  );
  final variantId = _normalizedEntryAnchorId(
    ownedItem?.variantId ??
        wishlistItem?.variantId ??
        entry?.referenceVariantId,
  );
  final bundleReleaseId = _normalizedEntryAnchorId(
    ownedItem?.bundleReleaseId ??
        wishlistItem?.bundleReleaseId ??
        entry?.referenceBundleReleaseId,
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
    PersonalItemAnchorType.item => labels.itemScope,
    PersonalItemAnchorType.edition => labels.editionScope,
    PersonalItemAnchorType.variant => labels.variantScope,
    PersonalItemAnchorType.bundleRelease => labels.bundleScope,
    null => null,
  };
}

LibraryReferenceLabels _libraryReferenceLabelsForMediaType(String? mediaType) {
  return collectarrLibraryTypes
          .byKind(mediaType)
          ?.presentation
          .referenceLabels ??
      const LibraryReferenceLabels();
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
  );
  if (variantFlag != null) {
    return variantFlag;
  }

  final editionFlag = digitalPhysicalMediaFormatFlag(
    matchedEdition?.physicalFormat,
    label: matchedEdition?.physicalFormatLabel ?? matchedEdition?.title,
  );
  if (editionFlag != null) {
    return editionFlag;
  }

  return digitalPhysicalMediaFormatFlag(
    fallbackFormat,
    label: fallbackLabel,
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
