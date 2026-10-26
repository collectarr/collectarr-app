import 'dart:ui' show PointerDeviceKind;

import 'package:collectarr_app/features/library/kinds/music/forms/disc_tab_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'disc hover and close hover are separate and close does not select',
      (tester) async {
    var selected = 0;
    var removed = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
      child: MusicDiscTabButton(
          number: 1,
          selected: false,
          onPressed: () => selected++,
          onRemove: () => removed++),
    ))));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Disc #1')));
    await tester.pumpAndSettle();
    final tab =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect((tab.decoration as BoxDecoration).color, const Color(0xff383838));
    final close = find.byKey(const ValueKey('music-disc-close-1'));
    await mouse.moveTo(tester.getCenter(close));
    await tester.pumpAndSettle();
    expect(tester.widget<Icon>(find.byIcon(Icons.close)).color,
        const Color(0xffff625c));
    await tester.tap(close);
    expect(removed, 1);
    expect(selected, 0);
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(tester.widget<Icon>(find.byIcon(Icons.close)).color,
        const Color(0xffd43f3a));
    expect(tester.takeException(), isNull);
    await mouse.removePointer();
  });
}
