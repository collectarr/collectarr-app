import 'package:collectarr_app/core/fonts/system_font_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SystemFontLoader can load Gilroy if present or report status safely', () async {
    final result = await SystemFontLoader.loadSystemGilroy();
    expect(result, isA<bool>());
    expect(SystemFontLoader.isGilroyLoaded, equals(result));
  });
}
