import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_fields.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryOwnedFormatHint resolveMovieOwnedFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.kindCapability.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.movieCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}

bool? resolveMovieOwnedDigitalFlag(
  CollectionItemSummary? collectionItem,
  List<LibraryAddReleaseOption> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  if (collectionItem?.isDigital case final value?) return value;
  final catalogItem = editions.firstOrNull;
  return digitalPhysicalMediaFormatFlag(
    fallbackFormat ?? catalogItem?.formatId,
    label: fallbackLabel ?? catalogItem?.formatLabel ?? catalogItem?.title,
    formats: formats.isEmpty ? moviePhysicalMediaFormats : formats,
  );
}
