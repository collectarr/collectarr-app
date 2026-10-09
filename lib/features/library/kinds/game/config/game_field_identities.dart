import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Canonical Game field facts shared by forms and workspace.
abstract final class GameFieldIdentities {
  static const franchiseId = 'game.franchise';
  static const franchiseLabel = 'Franchise';
  static const releaseDateId = 'game.release_date';
  static const releaseDateLabel = 'Release Date';
  static const barcodeId = 'game.barcode';
  static const barcodeLabel = 'Barcode';

  static const franchise = LibraryKindFieldMetadata(
    id: franchiseId,
    label: franchiseLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'franchise',
    searchable: true,
    groupable: true,
    editable: true,
  );
  static const releaseDate = LibraryKindFieldMetadata(
    id: releaseDateId,
    label: releaseDateLabel,
    valueType: LibraryFieldValueType.partialDate,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'release_date_parts',
    sortable: true,
    editable: true,
  );
  static const barcode = LibraryKindFieldMetadata(
    id: barcodeId,
    label: barcodeLabel,
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'barcode',
    searchable: true,
    sortable: true,
    editable: true,
  );

  static const all = <LibraryKindFieldMetadata>[
    franchise,
    releaseDate,
    barcode
  ];
}
