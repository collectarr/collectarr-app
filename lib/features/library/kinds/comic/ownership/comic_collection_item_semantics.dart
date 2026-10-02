import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_fields.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryOwnedFormatHint resolveComicOwnedFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.kindCapability.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.comicCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}
bool? resolveComicOwnedDigitalFlag(
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
    releases: const [],
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? comicPhysicalMediaFormats : formats,
  );
}
