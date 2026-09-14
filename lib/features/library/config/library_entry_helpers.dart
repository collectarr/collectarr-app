import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String? libraryHierarchyContractDiagnosticLabel(LibraryProjectionView item) {
  final kind = item.source.mediaKind;
  if (kind.isUnknown) return null;
  return libraryKindRegistrationForKind(kind)
      .hierarchy
      .contractDiagnosticLabel(item);
}

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
  required CatalogMediaKind kind,
  required List<LibraryWorkspaceReleaseSummary> releases,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final labels = _libraryReferenceLabelsForKind(kind);
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
  return libraryKindRegistrationForKind(sourceRef.kind).catalogTarget.resolve(
        sourceRef,
        LibraryCatalogTargetSelection(
          referenceType: LibraryAddReferenceType.edition,
          firstId: _normalizedEntryAnchorId(releaseNode.releaseId),
          secondId: _normalizedEntryAnchorId(
            _preferredReleaseVariantId(releaseNode.release),
          ),
        ),
      );
}

LibraryCatalogTargetLevel? libraryTargetScopeForCatalogRef(
  CatalogEntityRef? ref,
) {
  if (ref == null) {
    return null;
  }
  final parts =
      libraryKindRegistrationForKind(ref.kind).catalogTarget.parts(ref);
  if (parts.groupId != null) return LibraryCatalogTargetLevel.group;
  if (parts.secondId != null) return LibraryCatalogTargetLevel.second;
  if (parts.firstId != null) return LibraryCatalogTargetLevel.first;
  return LibraryCatalogTargetLevel.root;
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
  LibraryCatalogTargetLevel? level, {
  required String itemLabel,
  required String editionLabel,
  required String variantLabel,
  required String bundleLabel,
}) {
  return switch (level) {
    LibraryCatalogTargetLevel.root => itemLabel,
    LibraryCatalogTargetLevel.first => editionLabel,
    LibraryCatalogTargetLevel.second => variantLabel,
    LibraryCatalogTargetLevel.group => bundleLabel,
    null => null,
  };
}

LibraryPresentationLabels _libraryReferenceLabelsForMediaType(
    String? mediaType) {
  return _libraryReferenceLabelsForKind(catalogMediaKindFromValue(mediaType));
}

LibraryPresentationLabels _libraryReferenceLabelsForKind(
    CatalogMediaKind kind) {
  return libraryKindRegistrationForKind(kind).presentation.referenceLabels;
}

String? _preferredReleaseVariantId(LibraryWorkspaceReleaseSummary release) {
  for (final variant in release.variants) {
    if (variant.isPrimary) {
      return variant.id;
    }
  }
  return release.variants.isEmpty ? null : release.variants.first.id;
}

String? buildOwnedCopyLabelFromWorkspaceReleases(
  OwnedItemSummary? item,
  List<LibraryWorkspaceReleaseSummary> releases,
  int index, {
  String? collectionValue,
}) {
  if (item == null) return null;
  final parts = <String>['Copy ${index + 1}'];
  final targetParts = libraryKindRegistrationForKind(item.ref.kind)
      .catalogTarget
      .parts(item.targetRef);
  final releaseId = targetParts.firstId;
  final variantId = targetParts.secondId;
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

String? _normalizedEntryAnchorId(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
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
