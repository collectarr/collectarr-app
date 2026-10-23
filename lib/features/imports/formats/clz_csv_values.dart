import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/library/config/library_import_capability.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';

const _months = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

/// One CSV record whose columns were mapped to a kind's destination fields.
///
/// CLZ writes the column labels of the chosen column set as the header row, so
/// the destination keys come from the user's (usually auto-detected) mapping.
final class ClzCsvRecord {
  const ClzCsvRecord._(this._values, this.number,
      [this.customFields = const {}]);

  final Map<String, String> _values;

  /// Columns the user chose to import as custom fields, keyed by header.
  final Map<String, String?> customFields;

  /// The loan described by the Loaned To, Loan Date and Due Date columns.
  /// A loan needs a borrower; without a Loan Date it is lent on the due date
  /// or, failing that, on the day of the export record's modification.
  CollectionImportLoan? get loan {
    final borrower = text('loaned_to');
    if (borrower == null) return null;
    final lent = date('loan_date', 'Loan Date')?.asDateTime;
    final due = date('loan_due_date', 'Due Date')?.asDateTime;
    final lentDate = lent ?? due ?? instant('modified_date', 'Modified Date');
    if (lentDate == null) {
      throw LibraryImportFormatException(
          'Record $number is loaned to "$borrower" without a Loan Date.');
    }
    return CollectionImportLoan(
        borrowerName: borrower, lentDate: lentDate, dueDate: due);
  }

  /// One-based record number, used in error messages.
  final int number;

  String? text(String key) {
    final value = _values[key];
    return value == null || value.isEmpty ? null : value;
  }

  /// CLZ writes list values as "A | B"; other exports use the selected
  /// delimiter.
  List<String> list(String key, String delimiter) {
    final value = text(key);
    if (value == null) return const [];
    final separator = value.contains(' | ') ? '|' : delimiter;
    return [
      for (final part in value.split(separator))
        if (part.trim().isNotEmpty) part.trim()
    ];
  }

  /// Accepts CLZ's "Nov 14, 2014" as well as YYYY, YYYY-MM and YYYY-MM-DD.
  PartialDate? date(String key, String field) =>
      parseClzCsvDate(text(key), field: field, record: number);

  bool? boolean(String key, String field) {
    final value = text(key)?.toLowerCase();
    return switch (value) {
      null || '' => null,
      'yes' || 'true' || '1' || 'y' => true,
      'no' || 'false' || '0' || 'n' => false,
      _ => throw LibraryImportFormatException(
          'Record $number has an invalid $field "$value". Use Yes or No.'),
    };
  }

  int? integer(String key, String field, {int min = 0, int? max}) {
    final value = text(key);
    if (value == null) return null;
    final result = int.tryParse(value);
    if (result == null || result < min || (max != null && result > max)) {
      throw LibraryImportFormatException(
          'Record $number has an invalid $field "$value".');
    }
    return result;
  }

  int? money(String key, String field) {
    final value = text(key);
    if (value == null) return null;
    final amount = value.replaceFirst(RegExp(r'^[\$€£]\s*'), '');
    final match = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$').firstMatch(amount);
    if (match == null) {
      throw LibraryImportFormatException(
          'Record $number has an invalid $field "$value".');
    }
    return int.parse(match[1]!) * 100 +
        int.parse((match[2] ?? '').padRight(2, '0'));
  }

  /// Added and modified dates are exported as calendar days.
  DateTime? instant(String key, String field) => date(key, field)?.asDateTime;

  String? get collectionStatus => switch (text('collection_status')) {
        null => null,
        'On Wish List' || 'Wish List' => 'Wish List',
        'In Collection' => 'In Collection',
        'On Order' => 'On Order',
        'For Sale' => 'For Sale',
        'Sold' => 'Sold',
        'Not in Collection' => 'Not in Collection',
        final value => throw LibraryImportFormatException(
            'Record $number has an unsupported collection status "$value".'),
      };
}

/// Maps raw rows to [ClzCsvRecord]s after checking the mapping.
List<ClzCsvRecord> readClzCsvRecords(
  List<List<String>> rows, {
  required Map<int, String> mappings,
  List<String> headers = const [],
}) {
  if (rows.isEmpty) {
    throw const LibraryImportFormatException('The file has no data rows.');
  }
  if (!mappings.values.contains('title')) {
    throw const LibraryImportFormatException(
        'Map a column to Title before importing.');
  }
  final fixed = {
    for (final mapping in mappings.entries)
      if (mapping.value != importCustomFieldMappingKey)
        mapping.key: mapping.value
  };
  if (fixed.values.toSet().length != fixed.length) {
    throw const LibraryImportFormatException(
        'Map each destination field only once.');
  }
  return [
    for (var index = 0; index < rows.length; index++)
      ClzCsvRecord._(
          {
            for (final mapping in fixed.entries)
              mapping.value: _cell(rows[index], mapping.key, index + 1).trim()
          },
          index + 1,
          {
            for (final mapping in mappings.entries)
              if (mapping.value == importCustomFieldMappingKey)
                _customName(headers, mapping.key):
                    _cell(rows[index], mapping.key, index + 1).trim()
          })
  ];
}

String _customName(List<String> headers, int column) =>
    column < headers.length && headers[column].trim().isNotEmpty
        ? headers[column].trim()
        : 'Column ${column + 1}';

String _cell(List<String> row, int column, int record) {
  if (column < 0 || column >= row.length) {
    throw LibraryImportFormatException(
        'Record $record is missing a mapped column.');
  }
  return row[column];
}

PartialDate? parseClzCsvDate(String? value,
    {required String field, int? record}) {
  if (value == null || value.trim().isEmpty) return null;
  final text = value.trim();
  final where = record == null ? '' : 'Record $record has an invalid ';
  LibraryImportFormatException invalid() => LibraryImportFormatException(
      '${where.isEmpty ? 'Invalid ' : where}$field "$value". '
      'Use "Nov 14, 2014", YYYY, YYYY-MM or YYYY-MM-DD.');
  final named = RegExp(r'^([A-Za-z]{3})[a-z]*\.?\s+(\d{1,2}),\s*(\d{4})$')
      .firstMatch(text);
  final iso = RegExp(r'^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$').firstMatch(text);
  final int year;
  final int? month;
  final int? day;
  if (named != null) {
    month = _months[named[1]!.toLowerCase()];
    if (month == null) throw invalid();
    day = int.parse(named[2]!);
    year = int.parse(named[3]!);
  } else if (iso != null) {
    year = int.parse(iso[1]!);
    month = iso[2] == null ? null : int.parse(iso[2]!);
    day = iso[3] == null ? null : int.parse(iso[3]!);
  } else {
    throw invalid();
  }
  if (year < 1 ||
      (month != null && (month < 1 || month > 12)) ||
      (day != null &&
          (day < 1 || day > DateTime.utc(year, month! + 1, 0).day))) {
    throw invalid();
  }
  return PartialDate(year: year, month: month, day: day);
}
