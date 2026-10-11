import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:xml/xml.dart';

/// A typed export of complete local entries, including nested catalog data.
String encodeLibraryEntriesXml(Iterable<LibraryEntryRecord> entries) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  void value(Object? data) {
    switch (data) {
      case Map():
        builder.attribute('type', 'object');
        for (final entry in data.entries) {
          builder.element('field', nest: () {
            builder.attribute('name', entry.key.toString());
            value(entry.value);
          });
        }
      case Iterable():
        builder.attribute('type', 'array');
        for (final item in data) {
          builder.element('value', nest: () => value(item));
        }
      case null:
        builder.attribute('type', 'null');
      default:
        builder.attribute(
            'type',
            data is bool
                ? 'boolean'
                : data is num
                    ? 'number'
                    : 'text');
        builder.text(data.toString());
    }
  }

  builder.element('collectarr', nest: () {
    for (final entry in entries) {
      builder.element('item', nest: () => value(entry.toKindJson()));
    }
  });
  return builder.buildDocument().toXmlString(pretty: true);
}
