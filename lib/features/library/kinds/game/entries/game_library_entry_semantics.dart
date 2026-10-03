import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryEntryFormatHint resolveGameEntryFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.kindCapability.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.gameCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}

bool? resolveGameEntryDigitalFlag(
  LibraryEntrySummary? libraryEntry, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: libraryEntry?.isDigital,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? gamePhysicalMediaFormats : formats,
  );
}
