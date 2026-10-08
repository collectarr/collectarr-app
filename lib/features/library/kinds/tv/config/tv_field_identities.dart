import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Canonical TV field facts shared by Add and workspace.
abstract final class TvFieldIdentities {
  static const barcodeId = 'tv.barcode';
  static const barcodeLabel = 'Barcode';

  static const barcode = LibraryKindFieldMetadata(
    id: barcodeId,
    label: barcodeLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'barcode',
    searchable: true,
    editable: true,
  );
}
