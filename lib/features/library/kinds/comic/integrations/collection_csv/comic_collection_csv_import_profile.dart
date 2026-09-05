import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Typed Comic interpretation of a CSV row at the file boundary.
///
/// This is intentionally not the canonical Comic media/owned model. It is a
/// wire-format DTO used by the legacy Collection import host before the row is
/// handed to the remaining generic mutation pipeline.
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
  final int? coverPriceCents;
  final String? rawOrSlabbed;
  final String? gradingCompany;
  final String? graderNotes;
  final String? signedBy;
  final String? labelType;
  final String? certificationNumber;
  final bool keyComic;
  final String? keyReason;
}

/// Comic's CLZ/CSV parser and semantic aliases.
///
/// CSV mechanics remain in Collection. All Comic-specific interpretation is
/// kept here so a future Comic import action can consume this profile without
/// reviving the generic semantic union row.
final class ComicCollectionCsvImportProfile {
  const ComicCollectionCsvImportProfile();

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
    'Quantity',
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
    final index = _headerIndex(header);
    if (!_isComicRow(index, header, values)) return null;

    return ComicCollectionCsvImportRow(
      itemId: _value(index, values, 'item_id'),
      kind: _optionalValue(index, values, 'kind'),
      title: _optionalValue(index, values, 'title'),
      issueNumber: _optionalValue(index, values, 'item_number'),
      variantDescription: _optionalValue(index, values, 'variant'),
      editionTitle: _optionalValue(index, values, 'edition_title'),
      physicalFormat: _optionalValue(index, values, 'physical_format'),
      physicalFormatLabel:
          _optionalValue(index, values, 'physical_format_label'),
      publisher: _optionalValue(index, values, 'publisher'),
      releaseDate: _parseDate(_value(index, values, 'release_date')),
      barcode: _optionalValue(index, values, 'barcode'),
      coverPriceCents: _moneyCents(
        _value(index, values, 'cover_price_cents'),
      ),
      rawOrSlabbed: _optionalValue(index, values, 'raw_or_slabbed'),
      gradingCompany: _optionalValue(index, values, 'grading_company'),
      graderNotes: _optionalValue(index, values, 'grader_notes'),
      signedBy: _optionalValue(index, values, 'signed_by'),
      labelType: _optionalValue(index, values, 'label_type'),
      certificationNumber:
          _optionalValue(index, values, 'certification_number'),
      keyComic: _boolValue(index, values, 'key_comic'),
      keyReason: _optionalValue(index, values, 'key_reason'),
    );
  }

  Map<String, int> _headerIndex(List<String> header) {
    final index = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      index[_canonicalColumn(header[i])] = i;
    }
    return index;
  }

  bool _isComicRow(
    Map<String, int> index,
    List<String> header,
    List<String> values,
  ) {
    final kind = _optionalValue(index, values, 'kind')?.toLowerCase();
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
      (column) => comicHeaderSignals.contains(_normalizeColumn(column)),
    );
  }

  String _canonicalColumn(String value) {
    final normalized = _normalizeColumn(value);
    if (columnAliases.containsKey(normalized)) return normalized;
    for (final entry in columnAliases.entries) {
      if (entry.value.any(
        (alias) => _normalizeColumn(alias) == normalized,
      )) {
        return entry.key;
      }
    }
    return normalized;
  }

  String _value(Map<String, int> index, List<String> values, String column) {
    final valueIndex = index[_normalizeColumn(column)];
    if (valueIndex == null || valueIndex >= values.length) return '';
    return values[valueIndex];
  }

  String? _optionalValue(
    Map<String, int> index,
    List<String> values,
    String column,
  ) {
    final value = _value(index, values, column).trim();
    return value.isEmpty ? null : value;
  }

  bool _boolValue(Map<String, int> index, List<String> values, String column) {
    return switch (_value(index, values, column).trim().toLowerCase()) {
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

  String _normalizeColumn(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
