import 'package:collectarr_app/features/library/ui/primitives/fixed_select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const slab = LinearGradient(colors: [Color(0xffdde4f4), Color(0xff90b2de)]);

  Future<List<String?>> pump(WidgetTester tester, String? value) async {
    final picked = <String?>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: LibraryFixedSelectField(
            label: 'Label Type',
            value: value,
            options: const [
              (value: 'Universal Grade', background: slab),
              (value: 'Other', background: null),
            ],
            onChanged: picked.add,
          ),
        ),
      ),
    ));
    return picked;
  }

  testWidgets('picks a built-in value and None clears it', (tester) async {
    final picked = await pump(tester, null);
    await tester.tap(find.byType(LibraryMenuSelectField<String>));
    await tester.pumpAndSettle();
    expect(find.text('None'), findsOneWidget);
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LibraryMenuSelectField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();
    expect(picked, ['Other', null]);
  });

  testWidgets('paints the field in a slab label colours', (tester) async {
    await pump(tester, 'Universal Grade');
    final painted = tester
        .widgetList<DecoratedBox>(find.descendant(
            of: find.byType(LibraryMenuSelectField<String>),
            matching: find.byType(DecoratedBox)))
        .map((box) => (box.decoration as BoxDecoration).gradient);
    expect(painted, contains(slab));
  });
}
