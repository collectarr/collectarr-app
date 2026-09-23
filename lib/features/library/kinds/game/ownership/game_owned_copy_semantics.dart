import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryOwnedFormatHint resolveGameOwnedFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.gameCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}

bool? resolveGameOwnedDigitalFlag(
  OwnedItemSummary? ownedItem,
  List<LibraryAddReleaseOption> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: ownedItem?.isDigital,
    editionId: _gameEditionId(ownedItem?.targetRef),
    variantId: _gameReleaseId(ownedItem?.targetRef),
    releases: editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? gamePhysicalMediaFormats : formats,
  );
}

String? _gameEditionId(CatalogEntityRef? ref) =>
    switch (ref?.entityType.apiValue) {
      'edition' => ref?.id,
      'release' => ref?.parentId,
      _ => null,
    };

String? _gameReleaseId(CatalogEntityRef? ref) =>
    ref?.entityType.apiValue == 'release' ? ref?.id : null;
