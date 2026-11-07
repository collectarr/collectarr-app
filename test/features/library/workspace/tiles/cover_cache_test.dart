import 'package:collectarr_app/features/library/workspace/tiles/cover_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nearby widths share a decode step', () {
    expect(libraryCoverDecodeWidth('steps-a', 300), 384);
    expect(libraryCoverDecodeWidth('steps-b', 380), 384);
  });

  test('zooming out reuses the larger decode', () {
    expect(libraryCoverDecodeWidth('out', 500), 512);
    expect(libraryCoverDecodeWidth('out', 200), 512);
    expect(libraryCoverDecodeWidth('out', 128), 512);
  });

  test('a far smaller or larger need decodes again', () {
    expect(libraryCoverDecodeWidth('far', 1000), 1024);
    expect(libraryCoverDecodeWidth('far', 100), 128);
    expect(libraryCoverDecodeWidth('far', 1100), 1536);
  });
}
