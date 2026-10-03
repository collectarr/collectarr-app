import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

String? libraryHierarchyContractDiagnosticLabel(LibraryProjectionView item) {
  final kind = item.source.mediaKind;
  if (kind.isUnknown) return null;
  return libraryHierarchyForKind(kind).contractDiagnosticLabel(item);
}

/// Returns tracking state owned by the local entry represented by [item].
List<TrackingSummary> libraryTrackingSummariesForItem(
  LibraryProjectionView item,
  Map<LibraryEntryRef, List<TrackingSummary>> summariesByRef, {
  LibraryEntrySummary? libraryEntry,
}) {
  final entryRef = libraryEntry?.ref ?? item.source.libraryEntryRef;
  if (entryRef == null) return const <TrackingSummary>[];
  return summariesByRef[entryRef] ??
      const <TrackingSummary>[];
}

String? libraryLibraryEntryReferenceLabel(
  LibraryEntrySummary? libraryEntry, {
  String? mediaType,
}) {
  if (libraryEntry == null) return null;
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  return 'Owned ${labels.labelFor('item', fallback: 'item').toLowerCase()}';
}

String? libraryWishlistReferenceLabel(
  WishlistItem? wishlistItem, {
  String? mediaType,
}) {
  if (wishlistItem == null) return null;
  final labels = _libraryReferenceLabelsForMediaType(mediaType);
  return 'Wishlisted as '
      '${labels.labelFor('item', fallback: 'Media').toLowerCase()}';
}

/// Returns the kind-entry card projection consumed by shared workspace chrome.
/// The host renders only these structural values; it never reads semantic
/// fields from an erased workspace DTO.
LibraryCardPresentation libraryCardPresentationForEntry(
  LibraryProjectionView item, {
  bool coverFocused = false,
}) {
  return libraryPresentationForKind(item.source.mediaKind)
      .buildCardPresentation(
    item,
    coverFocused: coverFocused,
  );
}

LibraryEntryRef? resolveLibraryEntryRef(
  LibraryProjectionView item,
  LibraryEntrySummary? libraryEntry,
) {
  return libraryEntry?.ref ?? item.source.libraryEntryRef;
}

LibraryEntryRef? resolveLibraryEntrySummaryRef(
  LibraryProjectionView item,
  LibraryEntrySummary? libraryEntry,
) {
  return libraryEntry?.ref ?? item.source.libraryEntryRef;
}

CatalogEntityRef? resolveLibraryMutationTargetFromSummary({
  LibraryProjectionView? item,
  LibraryEntrySummary? libraryEntry,
  WishlistItem? wishlistItem,
}) {
  if (libraryEntry != null) {
    return libraryEntry.ref.localCatalogItemRef;
  }
  final wishlistTarget = wishlistItem?.catalogRef;
  if (wishlistTarget != null) {
    return CatalogEntityRef(
      kind: wishlistTarget.kind,
      entityType: CatalogEntityTypeId.catalogItem,
      id: wishlistTarget.id,
    );
  }
  return item?.source.catalogRef;
}

TrackingSummary? resolveActiveTrackingSummary(
  List<TrackingSummary> entries,
  LibraryEntrySummary? activeLibraryEntry,
) {
  if (activeLibraryEntry == null) return null;
  for (final entry in entries) {
    if (entry.libraryEntryRef == activeLibraryEntry.ref) return entry;
  }
  return null;
}

LibraryPresentationLabels _libraryReferenceLabelsForMediaType(
    String? mediaType) {
  return _libraryReferenceLabelsForKind(
    catalogMediaKindFromApiValue(mediaType),
  );
}

LibraryPresentationLabels _libraryReferenceLabelsForKind(
    CatalogMediaKind kind) {
  return libraryPresentationForKind(kind).referenceLabels;
}

String? buildLibraryEntryContextLabel(
  LibraryEntrySummary? item, {
  String? collectionValue,
}) {
  if (item == null) return null;
  final parts = <String>[];
  if (item.isDigital == true) parts.add('Digital');
  final collectionLabel = collectionValue?.trim();
  if (collectionLabel != null && collectionLabel.isNotEmpty) {
    parts.add(collectionLabel);
  }
  if (item.purchaseDate case final date?) {
    parts.add(formatNullableDate(date) ?? '');
  }
  return parts.where((value) => value.isNotEmpty).join('  ·  ');
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
