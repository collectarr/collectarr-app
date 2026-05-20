import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders profile labels and reports storage values',
      (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaTrackingStatusField(
            profile: comicTrackingProfile,
            value: 'reading',
            label: 'Read status',
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('Reading'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read').last);
    await tester.pumpAndSettle();

    expect(selected, 'Read');
  });
}
