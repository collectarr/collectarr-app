import 'package:collectarr_app/features/collection/csv/csv_mechanics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CsvWriter and CsvReader round-trip quoted values', () {
    const writer = CsvWriter(lineDelimiter: '\n');
    const reader = CsvReader();

    final encoded = writer.write([
      ['name', 'note'],
      ['The, Thing', 'line one\nline two'],
    ]);

    expect(reader.read(encoded), [
      ['name', 'note'],
      ['The, Thing', 'line one\nline two'],
    ]);
  });

  test('CsvReader strips a UTF-8 BOM from the first header cell', () {
    const reader = CsvReader();

    expect(reader.read('\ufeffname,value\nitem,1'), [
      ['name', 'value'],
      ['item', '1'],
    ]);
  });
}
