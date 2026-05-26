/// Declares which fields appear in the **Media** section of the edit dialog
/// (the abstract work: title, publisher, release date, etc.).
///
/// Each media kind provides its own instance with appropriate labels.
class MediaEditFields {
  const MediaEditFields({
    this.numberLabel = 'Number',
    this.publisherLabel = 'Publisher',
    this.showPageCount = false,
    this.showImprint = false,
    this.showSeriesGroup = false,
  });

  /// Print media (comics, manga, books) share page count, imprint, and
  /// series group fields. Use this constructor as a shorthand.
  const MediaEditFields.print({
    required String numberLabel,
    String publisherLabel = 'Publisher',
  }) : this(
          numberLabel: numberLabel,
          publisherLabel: publisherLabel,
          showPageCount: true,
          showImprint: true,
          showSeriesGroup: true,
        );

  /// Label for the edition/volume/issue number field.
  final String numberLabel;

  /// Label for the publisher/studio/label field.
  final String publisherLabel;

  /// Whether to show page count (books, comics, manga).
  final bool showPageCount;

  /// Whether to show the imprint field (books, comics, manga).
  final bool showImprint;

  /// Whether to show the series group field (books, comics, manga).
  final bool showSeriesGroup;
}

/// Declares which fields appear in the **Release details** section of the
/// edit dialog (a specific edition/variant: barcode, physical format, etc.).
///
/// Release fields are shown only when the ownership anchor targets a specific
/// release (edition, variant, or bundle) — not the abstract media work.
/// For catalog-only items (no ownership) they are always visible.
class ReleaseEditFields {
  const ReleaseEditFields({
    this.editionTitleLabel = 'Edition title',
    this.variantLabel = 'Variant',
    this.barcodeLabel = 'Barcode',
    this.showPhysicalFormat = true,
  });

  /// Label for the variant/format/edition field.
  final String variantLabel;

  /// Label for the edition title field.
  final String editionTitleLabel;

  /// Label for the barcode/UPC/ISBN field.
  final String barcodeLabel;

  /// Whether to show the physical format dropdown.
  final bool showPhysicalFormat;
}
