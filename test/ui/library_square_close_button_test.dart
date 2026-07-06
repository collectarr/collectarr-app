import 'package:collectarr_app/ui/library_square_close_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('library square close button renders a square outlined control',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LibrarySquareCloseButton(
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    final size = tester.getSize(find.byType(LibrarySquareCloseButton));
    expect(size.width, 32);
    expect(size.height, 32);

    await tester.tap(find.byType(OutlinedButton));
    expect(tapped, isTrue);
  });
}
