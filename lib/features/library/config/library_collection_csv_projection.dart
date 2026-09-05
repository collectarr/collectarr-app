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
