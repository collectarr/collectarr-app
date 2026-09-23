import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_fields.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryOwnedFormatHint resolveBoardGameOwnedFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.mapTransport((transport) => transport);
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
  OwnedItemSummary? ownedItem,
  List<LibraryAddReleaseOption> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: ownedItem?.isDigital,
    editionId: _boardGameEditionId(ownedItem?.targetRef),
    variantId: _boardGameReleaseId(ownedItem?.targetRef),
    releases: editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? boardGamePhysicalMediaFormats : formats,
  );
}

String? _boardGameEditionId(CatalogEntityRef? ref) =>
    switch (ref?.entityType.apiValue) {
      'edition' => ref?.id,
      'release' => ref?.parentId,
      _ => null,
    };

String? _boardGameReleaseId(CatalogEntityRef? ref) =>
    ref?.entityType.apiValue == 'release' ? ref?.id : null;
