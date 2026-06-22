import 'package:collectarr_app/core/utils/image_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeNetworkImageUrl', () {
    test('returns null for OpenLibrary invalid id sentinel', () {
      expect(
        normalizeNetworkImageUrl('https://covers.openlibrary.org/b/id/-1-L.jpg'),
        isNull,
      );
    });

    test('keeps valid OpenLibrary cover id', () {
      expect(
        normalizeNetworkImageUrl('https://covers.openlibrary.org/b/id/12345-L.jpg'),
        'https://covers.openlibrary.org/b/id/12345-L.jpg',
      );
    });
  });
}
