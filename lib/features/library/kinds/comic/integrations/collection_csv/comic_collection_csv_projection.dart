import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';

/// Comic's semantic contribution to the generic collection CSV host.
///
/// Collection owns the file format, while Comic owns how its issue, variant,
/// publishing, grading, signature, and key-issue values are represented in
/// that format. The returned lists are serialization cells, not Comic domain
/// objects, so the type-erased boundary exists only at export.
final class ComicCollectionCsvProjection
    implements LibraryCollectionCsvProjection {
  const ComicCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Map<String, List<String>> get columnAliases => _columnAliases;

  @override
  List<String> catalogCells(LibraryEntry entry) {
    final catalog = entry.catalogItem;
    final comic =
        catalog == null ? null : ComicCoreMapper.fromCatalogItem(catalog);
    return [
      entry.itemId,
      catalog?.kind ?? '',
      comic?.title ?? catalog?.title ?? '',
      comic?.issueNumber ?? '',
      comic?.variantDescription ?? comic?.variant ?? '',
      comic?.editionTitle ?? '',
      comic?.physicalFormat ?? '',
      comic?.physicalFormatLabel ?? '',
      comic?.publisher ?? '',
      _formatDate(comic?.releaseDate ?? comic?.coverDate),
      comic?.barcode ?? '',
    ];
  }

  @override
  List<String> ownedCellsBeforeQuantity(
    LibraryEntry entry, {
    required bool clzFriendly,
  }) {
    final owned = ComicOwnedItemLegacyAdapter.tryFromLegacy(entry.ownedItem);
    final details = owned?.details;
    if (!clzFriendly) return const [];
    return [_formatMoney(details?.coverPriceCents, clzFriendly: true)];
  }

  @override
  List<String> ownedCellsAfterIndex(
    LibraryEntry entry, {
    required bool clzFriendly,
  }) {
    final owned = ComicOwnedItemLegacyAdapter.tryFromLegacy(entry.ownedItem);
    final details = owned?.details;
    return [
      if (!clzFriendly)
        _formatMoney(details?.coverPriceCents, clzFriendly: false),
      details?.rawOrSlabbed ?? '',
      details?.gradingCompany ?? '',
      details?.graderNotes ?? '',
      details?.signedBy ?? '',
      details?.labelType ?? '',
      details?.certificationNumber ?? '',
      details == null ? '' : details.keyComic.toString(),
      details?.keyReason ?? '',
    ];
  }

  String _formatMoney(int? cents, {required bool clzFriendly}) {
    if (cents == null) return '';
    if (!clzFriendly) return cents.toString();
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '$sign$whole.$fraction';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }

  static const _columnAliases = <String, List<String>>{
    'item_id': ['Core ComicID', 'ComicID'],
    'item_number': ['Issue', 'Issue No.', 'Issue Number'],
    'raw_or_slabbed': ['Raw / Slabbed', 'Grade Status'],
    'grading_company': ['Grading Company'],
    'grader_notes': ['Grader Notes'],
    'label_type': ['Label Type'],
    'certification_number': [
      'Certification Number',
      'Cert Number',
      'Cert #',
    ],
    'key_comic': ['Key Comic'],
    'key_reason': ['Key Reason'],
  };
}
