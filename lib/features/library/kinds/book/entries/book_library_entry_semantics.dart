import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/book_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveBookEntryFormatHint(
  CatalogSearchCandidate item,
) {
  final metadata = item.kindCapability.mapTransport(
    (transport) => BookCatalogMetadata.fromJson(transport.kindData),
  );
  final format = metadata.physicalFormat;
  return (
    format: format,
    label: format ??
        (item.bookCatalogFields.titleExtension ?? metadata.editionTitle)
            ?.trim(),
  );
}

bool? resolveBookEntryDigitalFlag(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: libraryEntry?.isDigital,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? bookPhysicalMediaFormats : formats,
  );
}
