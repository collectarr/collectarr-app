import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_fields.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryOwnedFormatHint resolveBoardGameOwnedFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.kindCapability.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.boardGameCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}

bool? resolveBoardGameOwnedDigitalFlag(
  CollectionItemSummary? collectionItem,
  List<LibraryAddReleaseOption> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: collectionItem?.isDigital,
    editionId: null,
    variantId: null,
    releases: editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? boardGamePhysicalMediaFormats : formats,
  );
}
