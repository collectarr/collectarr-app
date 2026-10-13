import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/reports/library_xml_export.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  test('XML preserves nested values, boolean types, IDs and escaped text', () {
    final record = LibraryEntryRecord(
        id: 'entry',
        kind: CatalogMediaKind.music,
        catalogData: {
          'title': 'A & B <Live>',
          'discs': [
            {
              'id': 'disc',
              'is_live': true,
              'recording_locations': ['Abbey & Road', 'Wembley'],
              'credits': <Object?>[],
              'tracks': <Object?>[]
            }
          ]
        },
        personalData: {'quantity': 2},
        updatedAt: DateTime.utc(2026));
    final document = XmlDocument.parse(encodeLibraryEntriesXml([record]));
    expect(document.findAllElements('item'), hasLength(1));
    final fields = document.findAllElements('field').toList();
    expect(
        fields
            .firstWhere((field) => field.getAttribute('name') == 'title')
            .innerText,
        'A & B <Live>');
    final live =
        fields.firstWhere((field) => field.getAttribute('name') == 'is_live');
    expect(live.getAttribute('type'), 'boolean');
    expect(live.innerText, 'true');
    expect(
        fields
            .where((field) => field.getAttribute('name') == 'id')
            .map((field) => field.innerText),
        containsAll(['entry', 'disc']));
    expect(
        fields
            .firstWhere(
                (field) => field.getAttribute('name') == 'recording_locations')
            .getAttribute('type'),
        'array');
  });
}
