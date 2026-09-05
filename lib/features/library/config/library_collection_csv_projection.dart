import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';

/// Structural cells contributed by a kind to the collection CSV host.
///
/// The collection feature owns the CSV wire layout and file mechanics. A kind
/// owns the meaning of the cells it contributes. The lists are deliberately
/// positional because the format is a serialization boundary, not a domain
/// model shared by kinds.
abstract interface class LibraryCollectionCsvProjection {
  CatalogMediaKind get kind;

  /// The complete CLZ-compatible header for a single-kind export.
  ///
  /// A null value means that the generic host should keep its transitional
  /// header. The header is a wire-format concern, so owning it here keeps
  /// kind-specific labels and columns out of Collection.
  List<String>? get clzFriendlyHeader;

  /// Parses a kind-owned catalog segment from an external CSV row.
  ///
  /// The returned cells are already normalized for the generic legacy import
  /// adapter. Null means that this projection does not own the row.
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  });

  /// Parses a kind-owned owned-copy segment from an external CSV row.
  ///
  /// This is a serialization-boundary bridge only. The kind performs typed
  /// interpretation before returning the normalized cells.
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  });

  /// Aliases contributed by the kind's external CSV integrations.
  ///
  /// Keys are canonical wire-column names. Values are human-facing or
  /// provider-facing aliases accepted by the generic CSV reader.
  Map<String, List<String>> get columnAliases;

  /// Returns the 11 catalog cells in the canonical Collection CSV order.
  List<String> catalogCells(LibraryEntry entry);

  /// Returns kind-specific cells that precede quantity in the CLZ layout.
  ///
  /// The generic host owns the placement of universal columns. This hook is
  /// needed because the legacy CLZ layout places one kind-owned cell before
  /// quantity while the canonical layout places it after index.
  List<String> ownedCellsBeforeQuantity(
    LibraryEntry entry, {
    required bool clzFriendly,
  });

  /// Returns kind-specific cells that follow index in either layout.
  List<String> ownedCellsAfterIndex(
    LibraryEntry entry, {
    required bool clzFriendly,
  });
}

const libraryCollectionCsvCatalogCellCount = 11;
const libraryCollectionCsvOwnedCellCount = 9;
