import 'package:collectarr_app/ui/anchored_popup_geometry.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('popup matches field width and opens below when space allows', () {
    final geometry = AnchoredPopupGeometry.fromRect(
      anchor: const Rect.fromLTWH(20, 40, 240, 34),
      overlaySize: const Size(800, 600),
    );
    expect(geometry.opensAbove, isFalse);
    expect(geometry.bounds, const Rect.fromLTWH(20, 78, 240, 320));
  });

  test('keyboard leaves popup above anchor and within safe bounds', () {
    final geometry = AnchoredPopupGeometry.fromRect(
      anchor: const Rect.fromLTWH(620, 360, 240, 34),
      overlaySize: const Size(800, 600),
      safeArea: const EdgeInsets.only(top: 24),
      viewInsets: const EdgeInsets.only(bottom: 220),
    );
    expect(geometry.opensAbove, isTrue);
    expect(geometry.bounds.left, 552);
    expect(geometry.bounds.top, greaterThanOrEqualTo(32));
    expect(geometry.bounds.bottom, 356);
    expect(geometry.bounds.right, 792);
    expect(geometry.followerAnchor, Alignment.topLeft);
  });

  testWidgets('searchable popup remains selectable above an inset keyboard',
      (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? selected;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(viewInsets: const EdgeInsets.only(bottom: 240)),
        child: child!,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Positioned(
            left: 20,
            top: 350,
            width: 240,
            child: CompactSearchDropdownFormField<String>(
              initialValue: 'one',
              items: const [
                DropdownMenuItem(value: 'one', child: Text('One')),
                DropdownMenuItem(value: 'two', child: Text('Two')),
              ],
              onChanged: (value) => selected = value,
            ),
          )
        ]),
      ),
    ));
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Two')).dy, lessThan(350));
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(selected, 'two');
    expect(tester.takeException(), isNull);
  });
}
