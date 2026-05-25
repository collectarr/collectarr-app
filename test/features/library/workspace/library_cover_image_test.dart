import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX9kAAAAASUVORK5CYII=';

void main() {
  testWidgets('narrow interactive covers keep the hover cue compact', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 84,
              height: 126,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBase64: 'AAECAw==',
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture
        .moveTo(tester.getCenter(find.byType(LibraryInteractiveCover)));
    await tester.pumpAndSettle();

    expect(find.text('Open cover'), findsNothing);
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide interactive covers still show the full hover label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 320,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBase64: 'AAECAw==',
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture
        .moveTo(tester.getCenter(find.byType(LibraryInteractiveCover)));
    await tester.pumpAndSettle();

    expect(find.text('Open cover'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ultra narrow interactive covers do not overflow on hover', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 50,
              height: 70,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBase64: 'AAECAw==',
              ),
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture
        .moveTo(tester.getCenter(find.byType(LibraryInteractiveCover)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

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

  testWidgets('interactive covers open and close fullscreen preview on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 270,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBase64: _tinyPngBase64,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryInteractiveCover));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('secondary cover control can be disabled for shelf covers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 270,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBase64: _tinyPngBase64,
                ownedItemId: 'owned-1',
                enableFullscreen: false,
                enableSecondaryControl: false,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Back cover'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'View back'), findsNothing);
  });
}
