import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Structural cells contributed by a kind to the collection CSV host.
///
/// The collection feature owns the CSV wire layout and file mechanics. A kind
/// owns the meaning of the cells it contributes. The lists are deliberately
/// positional because the format is a serialization boundary, not a domain
/// model shared by kinds.
abstract interface class LibraryCollectionCsvProjection {
  CatalogMediaKind get kind;

  String importDisplayTitle(List<String> catalogCells);

  String importDisplaySubtitle(List<String> catalogCells);

  /// Returns the kind-defined value used for title/identifier matching at the
  /// import boundary. The collection host does not call this field an issue,
  /// volume, edition or version because that meaning belongs to the kind.
  String? importPrimaryLookupValue(List<String> catalogCells);

  /// Returns the kind-defined barcode/ISBN/UPC value, when the kind supports
  /// one. The collection host only uses the normalized lookup value.
  String? importBarcode(List<String> catalogCells);

  CatalogImportSnapshot? catalogItemFromImportCells(List<String> catalogCells);

  /// The complete CLZ header for a single-kind export.

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

  List<String> catalogCells(ShelfEntry entry);

  /// Serializes the owning kind's collection-value column at the CSV boundary.
  ///
  /// The collection row intentionally has no canonical grade field. A kind
  /// decides whether and how its Owned aggregate contributes this column.
  String? ownedCollectionValue(ShelfEntry entry);

  List<String> ownedCellsBeforeQuantity(
    ShelfEntry entry, {
    required bool clzFriendly,
  });

  List<String> ownedCellsAfterIndex(
    ShelfEntry entry, {
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
  JsonEncodable? decodeOwnedDetails(List<String> cells);
}

/// Structural presentation helpers for the collection CSV boundary.
///
/// The helpers intentionally consume the positional cells produced by the
/// owning projection. This keeps the common import UI independent of kind
/// payload keys while allowing every projection to share the same wire-level
/// presentation rules.
mixin LibraryCollectionCsvProjectionPresentation {
  List<String> catalogCells(ShelfEntry entry);

  String importDisplayTitle(List<String> catalogCells) {
    final title = catalogCells.elementAtOrNull(2) ?? '';
    final itemNumber = catalogCells.elementAtOrNull(3) ?? '';
    if (title.trim().isEmpty) {
      return 'Unknown title';
    }
    if (itemNumber.trim().isEmpty) {
      return title;
    }
    return '$title #$itemNumber';
  }

  String importDisplaySubtitle(List<String> catalogCells) {
    return [
      if ((catalogCells.elementAtOrNull(4) ?? '').trim().isNotEmpty)
        catalogCells.elementAtOrNull(4),
      if ((catalogCells.elementAtOrNull(8) ?? '').trim().isNotEmpty)
        catalogCells.elementAtOrNull(8),
      if ((catalogCells.elementAtOrNull(9) ?? '').trim().isNotEmpty)
        catalogCells.elementAtOrNull(9),
      if ((catalogCells.elementAtOrNull(10) ?? '').trim().isNotEmpty)
        catalogCells.elementAtOrNull(10),
    ].join(' | ');
  }

  String? importPrimaryLookupValue(List<String> catalogCells) {
    final value = catalogCells.elementAtOrNull(3)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? importBarcode(List<String> catalogCells) {
    final value = catalogCells.elementAtOrNull(10)?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

const libraryCollectionCsvCatalogCellCount = 11;
const libraryCollectionCsvOwnedCellCount = 9;
