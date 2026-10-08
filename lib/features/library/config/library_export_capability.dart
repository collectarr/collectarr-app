import 'package:collectarr_app/features/library/generic/projection_item.dart';

/// A column whose meaning and value are supplied by an owning library kind.
class ExportColumnDefinition {
  const ExportColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.defaultVisible = true,
  });

  final String id;
  final String label;
  final String Function(LibraryProjectionView item) getValue;
  final bool defaultVisible;
}

/// A child row produced by a kind for a secondary export mode.
///
/// [payload] is opaque to the reports feature. The owning kind's column
/// getters interpret it.
class LibraryExportChildRow {
  const LibraryExportChildRow({
    required this.item,
    required this.payload,
  });

  final LibraryProjectionView item;
  final Object payload;
}

/// A column for a kind-owned child-row export mode.
class LibraryExportChildColumnDefinition {
  const LibraryExportChildColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.defaultVisible = true,
  });

  final String id;
  final String label;
  final String Function(LibraryExportChildRow row) getValue;
  final bool defaultVisible;
}

/// Kind-owned export labels, fields, and child-row projection.
///
/// CSV/TXT quoting, preview, sorting, column selection, and file handling stay
/// in the shared reports feature.
class LibraryExportCapability {
  const LibraryExportCapability({
    required this.itemLabel,
    required this.itemModeLabel,
    required this.itemFileName,
    required this.defaultSortColumnId,
    required this.itemColumns,
    this.childLabel,
    this.childModeLabel,
    this.childFileName,
    this.childColumns = const [],
    this.childRowsBuilder,
  });

  final String itemLabel;
  final String itemModeLabel;
  final String itemFileName;
  final String defaultSortColumnId;
  final List<ExportColumnDefinition> itemColumns;
  final String? childLabel;
  final String? childModeLabel;
  final String? childFileName;
  final List<LibraryExportChildColumnDefinition> childColumns;
  final List<LibraryExportChildRow> Function(List<LibraryProjectionView> items)?
      childRowsBuilder;

  bool get supportsChildList =>
      childLabel != null && childFileName != null && childRowsBuilder != null;

  List<LibraryExportChildRow> childRowsFor(
    List<LibraryProjectionView> items,
  ) =>
      childRowsBuilder?.call(items) ?? const [];
}
