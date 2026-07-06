import 'package:collectarr_app/features/library/ui/library_panel_header.dart';
import 'package:collectarr_app/features/library/ui/library_section_state_message.dart';
import 'package:collectarr_app/features/library/ui/library_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LibrarySurface renders shared chrome pieces', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibrarySurface(
            header: LibraryPanelHeader.bar(
              title: 'Title',
              subtitle: 'Subtitle',
              count: 3,
            ),
            body: SizedBox(
              height: 20,
              child: LibrarySectionStateMessage(message: 'Hello'),
            ),
            footer: SizedBox(height: 12),
          ),
        ),
      ),
    );

    expect(find.text('Title (3)'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
}
