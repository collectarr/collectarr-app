import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_physical_media_formats.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';

LibraryOwnedFormatHint resolveTvOwnedFormatHint(
  LibraryAddCatalogTransport item,
) {
  final transport = item.mapTransport((transport) => transport);
  final format = transport.physicalFormat;
  return (
    format: format,
    label: transport.physicalFormatLabel ??
        format ??
        (item.titleExtension ?? transport.editionTitle)?.trim(),
  );
}

bool? resolveTvOwnedDigitalFlag(
  OwnedItemSummary? ownedItem,
  List<CatalogEditionDto> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: ownedItem?.isDigital,
    editionId: catalogRefEditionId(ownedItem?.targetRef),
    variantId: catalogRefVariantId(ownedItem?.targetRef),
    editions: editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? tvPhysicalMediaFormats : formats,
  );
}
