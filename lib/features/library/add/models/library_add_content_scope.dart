import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

enum LibraryAddContentScope { series, season, release }

bool libraryAddUsesContentScope(LibraryTypeConfig type) {
  return type.capabilities.usesSeasonHierarchy;
}

LibraryAddContentScope libraryAddContentScopeForItem(
  LibraryMetadataItem item,
) {
  if (libraryAddIsSeasonResult(item)) {
    return LibraryAddContentScope.season;
  }
  if (libraryAddIsReleaseResult(item)) {
    return LibraryAddContentScope.release;
  }
  return LibraryAddContentScope.series;
}

bool libraryAddMatchesContentScope({
  required LibraryTypeConfig type,
  required LibraryMetadataItem item,
  required bool showSeriesResults,
  required bool showSeasonResults,
  required bool showReleaseResults,
}) {
  if (!type.capabilities.usesSeasonHierarchy) {
    return libraryAddIsReleaseResult(item)
        ? showReleaseResults
        : showSeriesResults;
  }
  return switch (libraryAddContentScopeForItem(item)) {
    LibraryAddContentScope.series => showSeriesResults,
    LibraryAddContentScope.season => showSeasonResults,
    LibraryAddContentScope.release => showReleaseResults,
  };
}

bool libraryAddIsSeriesResult(LibraryMetadataItem item) {
  return !libraryAddIsSeasonResult(item) && !libraryAddIsReleaseResult(item);
}

bool libraryAddIsSeasonResult(LibraryMetadataItem item) {
  final payload = item.kindMetadata.toSyncPayload();
  return payload['season_number'] != null;
}

bool libraryAddIsReleaseResult(LibraryMetadataItem item) {
  final payload = item.kindMetadata.toSyncPayload();
  if (payload['season_number'] != null) {
    return false;
  }
  final itemNumber = payload['item_number']?.toString().trim();
  final editionTitle = payload['edition_title']?.toString().trim();
  final physicalFormat = payload['physical_format']?.toString().trim();
  final physicalFormatLabel =
      payload['physical_format_label']?.toString().trim();
  final barcode = payload['barcode']?.toString().trim();
  final variant = payload['variant']?.toString().trim();
  return (itemNumber != null && itemNumber.isNotEmpty) ||
      (editionTitle != null && editionTitle.isNotEmpty) ||
      (physicalFormat != null && physicalFormat.isNotEmpty) ||
      (physicalFormatLabel != null && physicalFormatLabel.isNotEmpty) ||
      (barcode != null && barcode.isNotEmpty) ||
      (variant != null && variant.isNotEmpty);
}
