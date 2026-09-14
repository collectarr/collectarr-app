import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/add/models/library_add_release_option.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';

/// Kind-owned resolver used by generic edit/detail hosts.
///
/// The host may provide catalog-derived formats, but the callback owns the
/// meaning of a digital copy for its kind.
typedef LibraryOwnedDigitalFlagResolver = bool? Function(
  OwnedItemSummary? ownedItem,
  List<LibraryAddReleaseOption> releases, {
  String? fallbackFormat,
  String? fallbackLabel,
  Iterable<PhysicalMediaFormat> formats,
});
