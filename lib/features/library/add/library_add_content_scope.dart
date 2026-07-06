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
  return item.series?.hasSeason == true;
}

bool libraryAddIsReleaseResult(LibraryMetadataItem item) {
  final series = item.series;
  if (series?.hasSeason == true) {
    return false;
  }
  final itemNumber = item.itemNumber?.trim();
  final editionTitle = item.editionTitle?.trim();
  final physicalFormat = item.physicalFormat?.trim();
  final physicalFormatLabel = item.physicalFormatLabel?.trim();
  final barcode = item.barcode?.trim();
  final variant = item.variant?.trim();
  return (itemNumber != null && itemNumber.isNotEmpty) ||
      (editionTitle != null && editionTitle.isNotEmpty) ||
      (physicalFormat != null && physicalFormat.isNotEmpty) ||
      (physicalFormatLabel != null && physicalFormatLabel.isNotEmpty) ||
      (barcode != null && barcode.isNotEmpty) ||
      (variant != null && variant.isNotEmpty);
}

