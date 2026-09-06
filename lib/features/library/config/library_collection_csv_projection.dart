import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/metadata_search_query.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';

/// Structural cells contributed by a kind to the collection CSV host.
///
/// The collection feature owns the CSV wire layout and file mechanics. A kind
/// owns the meaning of the cells it contributes. The lists are deliberately
/// positional because the format is a serialization boundary, not a domain
/// model shared by kinds.
abstract interface class LibraryCollectionCsvProjection {
  CatalogMediaKind get kind;

  String catalogDisplayTitle(CatalogItem item);

  String catalogDisplaySubtitle(CatalogItem item);

  bool catalogMatchesBarcode(CatalogItem item, String normalizedBarcode);

  /// The complete CLZ-compatible header for a single-kind export.

  ///
  /// A null value means that the generic host should keep its transitional
  /// header. The header is a wire-format concern, so owning it here keeps
  /// kind-specific labels and columns out of Collection.
  List<String>? get clzFriendlyHeader;

  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  });

  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  });

  Map<String, List<String>> get columnAliases;

  List<String> catalogCells(LibraryEntry entry);

  List<String> ownedCellsBeforeQuantity(
    LibraryEntry entry, {
    required bool clzFriendly,
  });

  List<String> ownedCellsAfterIndex(
    LibraryEntry entry, {
    required bool clzFriendly,
  });
}

/// Optional kind-owned decoder for the positional owned cells emitted by a
/// collection CSV projection.
///
/// The Collection host may carry these cells through its transitional row
/// model, but it must not interpret their meaning. Kinds that currently have
/// semantic owned cells implement this contract next to their CSV profile.
abstract interface class LibraryCollectionCsvOwnedDetailsDecoder {
  OwnedItemDetails? decodeOwnedDetails(List<String> cells);
}

/// Structural presentation helpers for the collection CSV boundary.
///
/// The helpers intentionally consume the positional cells produced by the
/// owning projection. This keeps the common import UI independent of kind
/// payload keys while allowing every projection to share the same wire-level
/// presentation rules.
mixin LibraryCollectionCsvProjectionPresentation {
  List<String> catalogCells(LibraryEntry entry);

  /// Presents a catalog item using the kind-owned catalog cells.
  ///
  /// This is intentionally derived from [catalogCells], rather than reading
  /// the transport payload. The collection host may render the result without
  /// learning what an item number means for any particular kind.
  String catalogDisplayTitle(CatalogItem item) {
    final cells = catalogCells(
      LibraryEntry(itemId: item.id, catalogItem: item),
    );
    final title = cells.elementAtOrNull(2) ?? item.title;
    final itemNumber = cells.elementAtOrNull(3) ?? '';
    if (itemNumber.trim().isEmpty) {
      return title;
    }
    return '$title #$itemNumber';
  }

  /// Presents the non-title catalog summary using kind-owned cells.
  String catalogDisplaySubtitle(CatalogItem item) {
    final cells = catalogCells(
      LibraryEntry(itemId: item.id, catalogItem: item),
    );
    return [
      if ((cells.elementAtOrNull(4) ?? '').trim().isNotEmpty)
        cells.elementAtOrNull(4),
      if ((cells.elementAtOrNull(8) ?? '').trim().isNotEmpty)
        cells.elementAtOrNull(8),
      if (item.releaseYear != null) item.releaseYear!.toString(),
      if ((cells.elementAtOrNull(10) ?? '').trim().isNotEmpty)
        cells.elementAtOrNull(10),
    ].join(' | ');
  }

  /// Matches the normalized barcode cell projected by the owning kind.
  bool catalogMatchesBarcode(CatalogItem item, String normalizedBarcode) {
    final cells = catalogCells(
      LibraryEntry(itemId: item.id, catalogItem: item),
    );
    final itemBarcode = cells.elementAtOrNull(10);
    return itemBarcode != null &&
        MetadataSearchQuery.normalizeBarcode(itemBarcode) == normalizedBarcode;
  }
}

const libraryCollectionCsvCatalogCellCount = 11;
const libraryCollectionCsvOwnedCellCount = 9;
