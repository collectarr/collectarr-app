import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generated cover displays media title and item number',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 120,
          height: 170,
          child: LibraryCoverImage(
            title: 'The Amazing Spider-Man, Vol. 4',
            itemNumber: '15A',
          ),
        ),
      ),
    );

    expect(find.text('The Amazing Spider-Man\nVol. 4'), findsOneWidget);
    expect(find.text('#15A'), findsOneWidget);
  });
}
