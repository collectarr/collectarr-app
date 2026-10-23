import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:xml/xml.dart';

/// XML mechanics only: each inventory owns its external type and field mapping.
List<ClzXmlRecord> readClzWebRecords(String source,
    {required String section, required String list, required String record}) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source);
  } on XmlException catch (error) {
    throw LibraryImportFormatException('Malformed XML: ${error.message}');
  }
  final root = document.rootElement;
  if (root.name.local != 'collectorz') {
    throw const LibraryImportFormatException('Expected a CLZ Web XML export.');
  }
  final records = root
          .getElement('data')
          ?.getElement(section)
          ?.getElement(list)
          ?.findElements(record)
          .toList() ??
      <XmlElement>[];
  if (records.isEmpty) {
    throw const LibraryImportFormatException(
        'No records found in this CLZ export.');
  }
  return List.unmodifiable(records.map(ClzXmlRecord.new));
}

final class ClzXmlRecord {
  const ClzXmlRecord(this.element);
  final XmlElement element;
  XmlElement? node(String path) {
    XmlElement? value = element;
    for (final part in path.split('/')) {
      value = value?.getElement(part);
    }
    return value;
  }

  String? text(String path) {
    final value = node(path);
    if (value == null) return null;
    final result = (value.getElement('displayname') ?? value).innerText.trim();
    return result.isEmpty ? null : result;
  }

  List<String> values(String container, String item) => [
        for (final value
            in node(container)?.findElements(item) ?? <XmlElement>[])
          if (ClzXmlRecord(value).text('displayname') ?? value.innerText.trim()
              case final name when name.isNotEmpty)
            name,
      ];
  int? integer(String path, {int min = 0, int? max}) {
    final value = text(path);
    if (value == null) return null;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < min || (max != null && parsed > max)) {
      throw LibraryImportFormatException('Invalid $path: "$value".');
    }
    return parsed;
  }

  bool? boolean(String path) {
    final value = node(path);
    if (value == null) return null;
    final raw = value.getAttribute('boolvalue') ?? text(path);
    return switch (raw?.toLowerCase()) {
      null => null,
      '1' || 'true' || 'yes' => true,
      '0' || 'false' || 'no' => false,
      _ => throw LibraryImportFormatException('Invalid boolean $path: "$raw".'),
    };
  }

  int? money(String path) {
    final value = text(path);
    if (value == null) return null;
    final raw = value.replaceFirst(RegExp(r'^[\$\u20ac\u00a3]\s*'), '');
    final match = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$').firstMatch(raw);
    if (match == null) {
      throw LibraryImportFormatException('Invalid $path: "$value".');
    }
    return int.parse(match[1]!) * 100 +
        int.parse((match[2] ?? '').padRight(2, '0'));
  }

  PartialDate? date(String path) {
    final value = node(path);
    if (value == null || value.innerText.trim().isEmpty) return null;
    final parts = ClzXmlRecord(value);
    int? number(String key) {
      final number = parts.integer(key, max: key == 'year' ? 9999 : 31);
      return number == 0 ? null : number;
    }

    var year = number('year');
    var month = number('month');
    var day = number('day');
    if (year == null &&
        month == null &&
        day == null &&
        (value.getElement('year') != null ||
            value.getElement('month') != null ||
            value.getElement('day') != null) &&
        parts.text('date') == null) {
      return null;
    }
    if (year == null && month == null && day == null) {
      final raw = parts.text('date') ??
          parts.text('displayname') ??
          value.innerText.trim();
      final match = RegExp(r'^(\d{4})?(?:[/-](\d{1,2})?)?(?:[/-](\d{1,2})?)?$')
          .firstMatch(raw);
      if (match == null) {
        throw LibraryImportFormatException('Invalid $path: "$raw".');
      }
      int? component(int index) {
        final part = int.tryParse(match[index] ?? '');
        return part == 0 ? null : part;
      }

      year = component(1);
      month = component(2);
      day = component(3);
    }
    if ((year != null && (year < 1 || year > 9999)) ||
        (month != null && (month < 1 || month > 12)) ||
        (day != null &&
            (day < 1 ||
                day >
                    (month == null
                        ? 31
                        : DateTime.utc(year ?? 2000, month + 1, 0).day)))) {
      throw LibraryImportFormatException('Invalid calendar date in $path.');
    }
    final result = PartialDate(year: year, month: month, day: day);
    return result.isEmpty ? null : result;
  }

  DateTime? instant(String path) {
    final timestamp = integer('$path/timestamp');
    return timestamp == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
  }

  void requireItemType(int expected, {required String field}) {
    final actual = integer(field);
    if (actual != expected) {
      throw const LibraryImportFormatException(
          'This XML contains another inventory type. Export one collection and import it into the matching Games, Hardware or Toys collection.');
    }
  }

  String? get collectionStatus => switch (text('collectionstatus')) {
        null => null,
        'On Wish List' || 'Wish List' => 'Wish List',
        'In Collection' => 'In Collection',
        'On Order' => 'On Order',
        'For Sale' => 'For Sale',
        'Sold' => 'Sold',
        'Not in Collection' => 'Not in Collection',
        final value => throw LibraryImportFormatException(
            'Unsupported collection status "$value".'),
      };
}
