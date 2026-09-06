import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

/// Kind-owned resolver used by generic edit/detail hosts.
///
/// The host may provide catalog-derived formats, but the callback owns the
/// meaning of a digital copy for its kind.
typedef LibraryOwnedDigitalFlagResolver = bool? Function(
  OwnedItem? ownedItem,
  List<CatalogEdition> editions, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats,
});
