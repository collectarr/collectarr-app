import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_fields.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

LibraryOwnedFormatHint resolveMusicOwnedFormatHint(
  CatalogSearchCandidate item,
) {
  final transport = item.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.musicCatalogFields.titleExtension ?? transport.editionTitle)
            ?.trim(),
  );
}

bool? resolveMusicOwnedDigitalFlag(
  OwnedItemSummary? ownedItem,
  List<LibraryAddReleaseOption> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: ownedItem?.isDigital,
    editionId: _musicEditionId(ownedItem?.targetRef),
    variantId: _musicReleaseId(ownedItem?.targetRef),
    releases: editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? musicPhysicalMediaFormats : formats,
  );
}

String? _musicEditionId(CatalogEntityRef? ref) =>
    switch (ref?.entityType.apiValue) {
      'edition' => ref?.id,
      'release' => ref?.parentId,
      _ => null,
    };

String? _musicReleaseId(CatalogEntityRef? ref) =>
    ref?.entityType.apiValue == 'release' ? ref?.id : null;
