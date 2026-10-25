import 'package:collectarr_app/features/library/kinds/game/edit/game_market_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('A PriceCharting ID opens its product page', () {
    expect(gamePriceChartingUri(' 57416 ').toString(),
        'https://www.pricecharting.com/game/57416');
  });

  test('No PriceCharting link without a numeric ID', () {
    expect(gamePriceChartingUri(null), isNull);
    expect(gamePriceChartingUri(''), isNull);
    expect(gamePriceChartingUri('god-of-war'), isNull);
  });
}
