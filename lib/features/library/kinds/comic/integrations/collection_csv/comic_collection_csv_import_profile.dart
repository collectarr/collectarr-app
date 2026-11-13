import 'package:collectarr_app/features/collection/csv/collection_csv_columns.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Typed Comic interpretation of a CSV row at the file boundary.
///
/// This is intentionally not the canonical Comic media/entry model. It is a
/// wire-format DTO used by the Collection import host before the row is
/// handed to the generic mutation pipeline.
final class ComicCollectionCsvImportRow {
  const ComicCollectionCsvImportRow({
    required this.itemId,
    this.kind,
    this.title,
    this.issueNumber,
    this.variantDescription,
    this.editionTitle,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.releaseDate,
    this.barcode,
    this.grade,
    this.coverPriceCents,
    this.rawOrSlabbed,
    this.gradingCompany,
    this.graderNotes,
    this.signedBy,
    this.labelType,
    this.certificationNumber,
    this.keyComic = false,
    this.keyReason,
  });

  final String itemId;
  final String? kind;
  final String? title;
  final String? issueNumber;
  final String? variantDescription;
  final String? editionTitle;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final DateTime? releaseDate;
  final String? barcode;
  final String? grade;
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;

  List<String> get catalogCells => [
        itemId,
        kind ?? '',
        title ?? '',
        issueNumber ?? '',
        variantDescription ?? '',
        editionTitle ?? '',
        physicalFormat ?? '',
        physicalFormatLabel ?? '',
        publisher ?? '',
        formatCollectionCsvDate(releaseDate),
        barcode ?? '',
      ];

  List<String> get entryCells => [
        grade ?? '',
        coverPriceCents?.toString() ?? '',
        rawOrSlabbed ?? '',
        gradingCompany ?? '',
        graderNotes ?? '',
        signedBy ?? '',
        labelType ?? '',
        certificationNumber ?? '',
        keyComic.toString(),
        keyReason ?? '',
      ];
}

/// Comic's CLZ/CSV parser and semantic aliases.
///
/// CSV mechanics remain in Collection. All Comic-specific interpretation is
/// kept here so a future Comic import action can consume this profile without
/// reviving the generic semantic union row.
final class ComicCollectionCsvImportProfile {
  const ComicCollectionCsvImportProfile();

  /// Canonical schema-v1 header entry by this kind's CSV integration.
  ///
  /// The same wire positions may be duplicated between kinds intentionally;
  /// Collection never interprets these labels as a shared domain schema.
  static const v1Header = <String>[
    'item_id',
    'kind',
    'title',
    'item_number',
    'variant',
    'edition_title',
    'physical_format',
    'physical_format_label',
    'publisher',
    'release_date',
    'barcode',
    'status',
    'condition',
    'grade',
    'purchase_date',
    'price_paid_cents',
    'currency',
    'notes',
    'location_id',
    'index_number',
    'cover_price_cents',
    'raw_or_slabbed',
    'grading_company',
    'grader_notes',
    'signed_by',
    'label_type',
    'certification_number',
    'key_comic',
    'key_reason',
    'rating',
    'read_status',
    'started_at',
    'finished_at',
    'tags',
    'sold_at',
    'sell_price_cents',
    'sold_to',
  ];
  static const clzFriendlyHeader = [
    'Collectarr Item ID',
    'Media Type',
    'Series',
    'Issue',
    'Variant Description',
    'Edition Title',
    'Physical Format',
    'Physical Format Label',
    'Publisher',
    'Release Date',
    'Barcode',
    'Collection Status',
    'Condition',
    'Grade',
    'Purchase Date',
    'Purchase Price',
    'Currency',
    'Cover Price',
    'Location ID',
    'Index',
    'Raw / Slabbed',
    'Grading Company',
    'Grader Notes',
    'Signed By',
    'Label Type',
    'Certification Number',
    'Key Comic',
    'Key Reason',
    'Rating',
    'Read It',
    'Started',
    'Finished',
    'Tags',
    'Notes',
    'Sold Date',
    'Sell Price',
    'Sold To',
  ];

  static const columnAliases = <String, List<String>>{
    'item_id': [
      'Collectarr Item ID',
      'Core ComicID',
      'ComicID',
      'Core SeriesID',
    ],
    'kind': ['Media Type', 'Kind', 'Type', 'Library', 'Media Kind'],
    'title': ['Series', 'Show', 'Release', 'Full Title'],
    'item_number': [
      'Issue',
      'Issue No.',
      'Issue Number',
      'No. / Vol.',
    ],
    'variant': ['Variant Description'],
    'edition_title': ['Edition Title', 'Edition Name', 'Release Title'],
    'physical_format': [
      'Physical Format',
      'Format ID',
      'Media Format',
      'Video Format',
      'Disc Format',
    ],
    'physical_format_label': [
      'Physical Format Label',
      'Format',
      'Format Label',
      'Video Format Label',
    ],
    'publisher': [
      'Publisher',
      'Studio',
      'Network / Studio',
      'Studio / Publisher',
      'Publisher / Studio',
      'Publisher / Designer',
      'Label / Artist',
      'Publisher / Studio / Creator',
    ],
    'release_date': ['Release Date', 'Cover Date'],
    'barcode': [
      'Barcode',
      'UPC',
      'ISBN',
      'UPC / Barcode',
      'ISBN / Barcode',
      'Barcode / Catalog no.',
      'Barcode / UPC / ISBN',
    ],
    'grade': ['Grade', 'Grade and Value'],
    'cover_price_cents': ['Cover Price'],
    'raw_or_slabbed': ['Raw / Slabbed', 'Grade Status'],
    'grading_company': ['Grading Company'],
    'grader_notes': ['Grader Notes'],
    'signed_by': ['Signed By'],
    'label_type': ['Label Type'],
    'certification_number': [
      'Certification Number',
      'Cert Number',
      'Cert #',
    ],
    'key_comic': ['Key Comic'],
    'key_reason': ['Key Reason'],
  };

  ComicCollectionCsvImportRow? parseRow({
    required List<String> header,
    required List<String> values,
  }) {
    final index = collectionCsvHeaderIndex(header, columnAliases);
    if (!_isComicRow(index, header, values)) return null;

    return ComicCollectionCsvImportRow(
      itemId: collectionCsvValue(index, values, 'item_id'),
      // Comic-specific headers are sufficient to identify a CLZ row when
      // Media Type is omitted. Preserve that dispatch result in the
      // structural catalog cells so later import UI can select Comic rather
      // than falling back to an arbitrary kind.
      kind: collectionCsvOptionalValue(index, values, 'kind') ??
          CatalogMediaKind.comic.apiValue,
      title: collectionCsvOptionalValue(index, values, 'title'),
      issueNumber: collectionCsvOptionalValue(index, values, 'item_number'),
      variantDescription: collectionCsvOptionalValue(index, values, 'variant'),
      editionTitle: collectionCsvOptionalValue(index, values, 'edition_title'),
      physicalFormat:
          collectionCsvOptionalValue(index, values, 'physical_format'),
      physicalFormatLabel:
          collectionCsvOptionalValue(index, values, 'physical_format_label'),
      publisher: collectionCsvOptionalValue(index, values, 'publisher'),
      releaseDate:
          _parseDate(collectionCsvValue(index, values, 'release_date')),
      barcode: collectionCsvOptionalValue(index, values, 'barcode'),
      grade: collectionCsvOptionalValue(index, values, 'grade'),
      coverPriceCents: _moneyCents(
        collectionCsvValue(index, values, 'cover_price_cents'),
      ),
      rawOrSlabbed: collectionCsvOptionalValue(index, values, 'raw_or_slabbed'),
      gradingCompany:
          collectionCsvOptionalValue(index, values, 'grading_company'),
      graderNotes: collectionCsvOptionalValue(index, values, 'grader_notes'),
      signedBy: collectionCsvOptionalValue(index, values, 'signed_by'),
      labelType: collectionCsvOptionalValue(index, values, 'label_type'),
      certificationNumber:
          collectionCsvOptionalValue(index, values, 'certification_number'),
      keyComic: _boolValue(index, values, 'key_comic'),
      keyReason: collectionCsvOptionalValue(index, values, 'key_reason'),
    );
  }

  bool _isComicRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind =
        collectionCsvOptionalValue(index, values, 'kind')?.toLowerCase();
    if (kind != null) {
      return catalogMediaKindFromValue(kind) == CatalogMediaKind.comic;
    }

    // CLZ exports often omit Media Type. These aliases are unambiguous enough
    // to identify a Comic row without interpreting any payload map.
    const comicHeaderSignals = {
      'core_comicid',
      'comicid',
      'core_seriesid',
      'issue',
      'issue_no',
      'issue_number',
      'variant_description',
      'cover_price',
      'raw_slabbed',
      'grade_status',
      'grading_company',
      'key_comic',
      'key_reason',
    };
    return header.any(
      (column) =>
          comicHeaderSignals.contains(normalizeCollectionCsvColumn(column)),
    );
  }

  bool _boolValue(Map<String, int> index, List<String> values, String column) {
    return switch (
        collectionCsvValue(index, values, column).trim().toLowerCase()) {
      '1' || 'true' || 'yes' || 'y' => true,
      _ => false,
    };
  }

  int? _moneyCents(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final asInt = int.tryParse(trimmed);
    if (asInt != null) return asInt;
    final parsed = double.tryParse(_normalizeMoney(trimmed));
    return parsed == null ? null : (parsed * 100).round();
  }

  String _normalizeMoney(String value) {
    final isNegative = value.contains('-') ||
        (value.trim().startsWith('(') && value.trim().endsWith(')'));
    final numeric = value.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (numeric.isEmpty) return '';
    final decimalSeparatorIndex = _decimalSeparatorIndex(numeric);
    final buffer = StringBuffer();
    for (var i = 0; i < numeric.length; i++) {
      final char = numeric[i];
      if (char == '.' || char == ',') {
        if (decimalSeparatorIndex != null && i == decimalSeparatorIndex) {
          buffer.write('.');
        }
      } else {
        buffer.write(char);
      }
    }
    final normalized = buffer.toString();
    return isNegative ? '-$normalized' : normalized;
  }

  int? _decimalSeparatorIndex(String value) {
    final lastComma = value.lastIndexOf(',');
    final lastDot = value.lastIndexOf('.');
    final separatorIndex = lastComma > lastDot ? lastComma : lastDot;
    if (separatorIndex < 0) return null;
    final separator = value[separatorIndex];
    final separatorCount =
        RegExp(RegExp.escape(separator)).allMatches(value).length;
    final digitsAfter = value.length - separatorIndex - 1;
    if (separatorCount > 1) return null;
    if (lastComma >= 0 && lastDot >= 0) return separatorIndex;
    if (digitsAfter == 1 || digitsAfter == 2) return separatorIndex;
    return null;
  }

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      return DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    final yearFirst =
        RegExp(r'^(\d{4})[/-](\d{1,2})[/-](\d{1,2})$').firstMatch(trimmed);
    if (yearFirst != null) {
      return _validDate(
        int.parse(yearFirst.group(1)!),
        int.parse(yearFirst.group(2)!),
        int.parse(yearFirst.group(3)!),
      );
    }
    final shortDate =
        RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$').firstMatch(trimmed);
    if (shortDate == null) return null;
    final first = int.parse(shortDate.group(1)!);
    final second = int.parse(shortDate.group(2)!);
    final rawYear = shortDate.group(3)!;
    final year = rawYear.length == 4
        ? int.parse(rawYear)
        : (int.parse(rawYear) >= 70
            ? 1900 + int.parse(rawYear)
            : 2000 + int.parse(rawYear));
    final month = first > 12 ? second : first;
    final day = first > 12 ? first : second;
    return _validDate(year, month, day);
  }

  DateTime? _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }
}
