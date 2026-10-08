import 'package:collectarr_app/features/library/generic/projection_item.dart';

/// A column whose meaning and value are supplied by an owning library kind.
class ExportColumnDefinition {
  const ExportColumnDefinition({
    required this.id,
    required this.label,
    required this.getValue,
    this.defaultVisible = true,
    this.includeInPdf = true,
    this.pdfLabel,
    this.pdfGetValue,
    this.pdfWidthFlex,
    this.pdfDefaultVisible,
    this.pdfOrder,
  });

  final String id;
  final String label;
  final String Function(LibraryProjectionView item) getValue;
  final bool defaultVisible;
  final bool includeInPdf;
  final String? pdfLabel;
  final String Function(LibraryProjectionView item)? pdfGetValue;
  final double? pdfWidthFlex;
  final bool? pdfDefaultVisible;
  final int? pdfOrder;
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
    this.includeInPdf = true,
    this.pdfLabel,
    this.pdfGetValue,
    this.pdfWidthFlex,
    this.pdfDefaultVisible,
    this.pdfOrder,
  });

  final String id;
  final String label;
  final String Function(LibraryExportChildRow row) getValue;
  final bool defaultVisible;
  final bool includeInPdf;
  final String? pdfLabel;
  final String Function(LibraryExportChildRow row)? pdfGetValue;
  final double? pdfWidthFlex;
  final bool? pdfDefaultVisible;
  final int? pdfOrder;
}

/// Kind-owned export labels, fields, and child-row projection.
///
/// CSV/TXT and PDF fields come from the kind. Encoding, preview, print layout,
/// column selection, and file handling stay in the shared reports feature.
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
    this.pdfItemTitle,
    this.pdfChildTitle,
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
  final String? pdfItemTitle;
  final String? pdfChildTitle;

  List<ExportColumnDefinition> get pdfItemColumns {
    final columns = [
      for (var index = 0; index < itemColumns.length; index++)
        if (itemColumns[index].includeInPdf) (index, itemColumns[index]),
    ];
    columns.sort(
        (a, b) => (a.$2.pdfOrder ?? a.$1).compareTo(b.$2.pdfOrder ?? b.$1));
    return [for (final entry in columns) entry.$2];
  }

  List<LibraryExportChildColumnDefinition> get pdfChildColumns {
    final columns = [
      for (var index = 0; index < childColumns.length; index++)
        if (childColumns[index].includeInPdf) (index, childColumns[index]),
    ];
    columns.sort(
        (a, b) => (a.$2.pdfOrder ?? a.$1).compareTo(b.$2.pdfOrder ?? b.$1));
    return [for (final entry in columns) entry.$2];
  }

  bool get supportsChildList =>
      childLabel != null && childFileName != null && childRowsBuilder != null;

  List<LibraryExportChildRow> childRowsFor(
    List<LibraryProjectionView> items,
  ) =>
      childRowsBuilder?.call(items) ?? const [];
}
