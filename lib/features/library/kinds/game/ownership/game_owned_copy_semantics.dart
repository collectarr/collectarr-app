import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/game_physical_media_formats.dart';

bool? resolveGameOwnedDigitalFlag(
  OwnedItem? ownedItem,
  List<CatalogEdition> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats = const [],
}) {
  return resolveDigitalMediaFormatFlag(
    explicitDigital: ownedItem?.isDigital,
    editionId: ownedItem?.anchor?.editionId,
    variantId: ownedItem?.anchor?.variantId,
    editions: editions,
    fallbackFormat: fallbackFormat,
    fallbackLabel: fallbackLabel,
    formats: formats.isEmpty ? gamePhysicalMediaFormats : formats,
  );
}
