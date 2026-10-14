import 'package:collectarr_app/core/fonts/font_weight.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('normal font slots select the intended face with Light present',
      (tester) async {
    // Use bundled OFL fonts. No installed, proprietary or user font is needed.
    Future<Uint8List> asset(String name) async {
      final data =
          await rootBundle.load('assets/fonts/PlusJakartaSans-$name.ttf');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }

    Future<void> load(String alias, Uint8List bytes) =>
        (FontLoader(alias)..addFont(Future.value(ByteData.sublistView(bytes))))
            .load();

    double width(String alias, FontWeight weight) {
      final painter = TextPainter(
          text: TextSpan(
              text: 'List Vertical Cards Horizontal Cards Covers Shelves',
              style: TextStyle(
                  fontFamily: alias, fontSize: 14, fontWeight: weight)),
          textDirection: TextDirection.ltr)
        ..layout();
      final result = painter.width;
      painter.dispose();
      return result;
    }

    final regular = await asset('Regular');
    final semiBold = await asset('SemiBold');
    const reference = 'Font contract isolated SemiBold';
    const mixed = 'Font contract mixed family';
    await load(reference, semiBold);
    await load(mixed, fontBytesAtWeight(semiBold, 400));
    await load(mixed, fontBytesAtWeight(semiBold, 500));
    await load(mixed, fontBytesAtWeight(regular, 300));
    await load(mixed, semiBold);
    await load(mixed, await asset('Bold'));
    final expected = width(reference, FontWeight.w600);
    for (final slot in [FontWeight.w400, FontWeight.w500]) {
      expect(width(mixed, slot), closeTo(expected, 0.001),
          reason: 'Normal text must select SemiBold outlines, not Light.');
    }
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Text('Vertical Cards',
                style: TextStyle(fontFamily: mixed, fontSize: 14)))));
    expect(tester.takeException(), isNull);
  });
}
