import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/settings/ebay_search_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('automatic listing filter respects collection status', () {
    expect(EbaySearchFilter.automatic.soldOnlyFor(isWishlisted: true), isFalse);
    expect(EbaySearchFilter.automatic.soldOnlyFor(isWishlisted: false), isTrue);
    for (final wishlisted in [true, false]) {
      expect(
          EbaySearchFilter.all.soldOnlyFor(isWishlisted: wishlisted), isFalse);
      expect(
          EbaySearchFilter.sold.soldOnlyFor(isWishlisted: wishlisted), isTrue);
    }
  });

  test('regional search preserves query, category and sold filter', () {
    final uri = buildEbaySearchUri(
      query: '  Artist & Album  ',
      categoryPath: '/sch/11233/i.html',
      soldOnly: true,
      region: EbayRegion.gb,
    )!;
    expect(uri.host, 'www.ebay.co.uk');
    expect(uri.path, '/sch/11233/i.html');
    expect(uri.queryParameters, {'_nkw': 'Artist & Album', 'LH_Sold': '1'});
    expect(buildEbaySearchUri(query: '  ', region: EbayRegion.de), isNull);
    expect(
        buildEbaySearchUri(query: 'Album')!
            .queryParameters
            .containsKey('LH_Sold'),
        isFalse);
    expect(buildEbaySearchUri(query: 'Album', region: EbayRegion.beFr)!.host,
        'www.befr.ebay.be');
  });
}
