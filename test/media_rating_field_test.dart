import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
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
    expect(find.text('Rating'), findsOneWidget);
    expect(find.text('8/100'), findsOneWidget);
  });
}
