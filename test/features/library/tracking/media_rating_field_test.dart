import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders rating input with configured range', (tester) async {
    final controller = TextEditingController(text: '8');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaRatingField(
            controller: controller,
            maxRating: 100,
          ),
        ),
      ),
    );

    expect(find.byType(MediaRatingField), findsOneWidget);
    expect(find.text('My Rating'), findsOneWidget);
    expect(find.text('8/100'), findsOneWidget);
  });

  testWidgets('compact rating shows ten reference stars without a counter',
      (tester) async {
    final controller = TextEditingController(text: '3');
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 578,
          child: MediaRatingField(controller: controller, compact: true),
        ),
      ),
    ));

    final stars = find.byIcon(AppIcons.star);
    expect(stars, findsNWidgets(10));
    expect(find.text('3/10'), findsNothing);
    expect(tester.widget<Icon>(stars.at(2)).color, const Color(0xFFF4B30A));
    expect(tester.widget<Icon>(stars.at(3)).color, const Color(0xFFBBBBBB));

    await tester.tap(stars.at(6));
    expect(controller.text, '7');
    await tester.tap(stars.at(6));
    expect(controller.text, '0');
  });
}
