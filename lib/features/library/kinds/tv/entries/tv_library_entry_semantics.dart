import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_fields.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveTvEntryFormatHint(
  CatalogSearchCandidate item,
) {
  final metadata = item.tvCatalogFields;
  final format = metadata.physicalFormat;
  return (
    format: format,
    label: metadata.physicalFormatLabel ??
        format ??
        (metadata.titleExtension ?? metadata.editionTitle)?.trim(),
  );
}

bool? resolveTvEntryDigitalFlag(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: libraryEntry?.isDigital,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? tvPhysicalMediaFormats : formats,
  );
}
