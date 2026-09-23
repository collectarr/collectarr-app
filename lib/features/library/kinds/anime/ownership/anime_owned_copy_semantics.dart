import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_fields.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryOwnedFormatHint resolveAnimeOwnedFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.animeCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}

bool? resolveAnimeOwnedDigitalFlag(
  OwnedItemSummary? ownedItem,
  List<LibraryAddReleaseOption> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: ownedItem?.isDigital,
    editionId: _animeEditionId(ownedItem?.targetRef),
    variantId: _animeReleaseId(ownedItem?.targetRef),
    releases: editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? animePhysicalMediaFormats : formats,
  );
}

String? _animeEditionId(CatalogEntityRef? ref) =>
    switch (ref?.entityType.apiValue) {
      'edition' => ref?.id,
      'release' => ref?.parentId,
      _ => null,
    };

String? _animeReleaseId(CatalogEntityRef? ref) =>
    ref?.entityType.apiValue == 'release' ? ref?.id : null;
