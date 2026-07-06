import 'dart:convert';

import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_constants.dart';

const _tinyPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX9kAAAAASUVORK5CYII=';

void main() {
  testWidgets('narrow interactive covers keep the hover cue compact', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 84,
              height: 126,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode('AAECAw=='),
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
    await pumpUntilSettled(tester);

    expect(find.text('Fullscreen'), findsNothing);
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide interactive covers still show the full hover label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 320,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode('AAECAw=='),
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
    await pumpUntilSettled(tester);

    expect(find.text('Fullscreen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ultra narrow interactive covers do not overflow on hover', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 50,
              height: 70,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode('AAECAw=='),
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
    await pumpUntilSettled(tester);

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
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 270,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode(_tinyPngBase64),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryInteractiveCover));
    await pumpUntilSettled(tester);

    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await pumpUntilSettled(tester);

    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('tapping empty preview area closes fullscreen preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode(_tinyPngBase64),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryInteractiveCover));
    await pumpUntilSettled(tester);

    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tapAt(const Offset(140, 400));
    await pumpUntilSettled(tester);
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets(
      'preview shows Front/Back badges when dual covers do not fit side-by-side',
      (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 220);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 270,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode(_tinyPngBase64),
                secondaryLocalBytes: base64Decode(_tinyPngBase64),
                enableSecondaryControl: true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryInteractiveCover));
    await pumpUntilSettled(tester);

    expect(find.widgetWithText(FilledButton, 'Front'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Back'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await pumpUntilSettled(tester);
  });

  testWidgets(
      'preview hides Front/Back badges when dual covers fit side-by-side', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2200, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 330,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode(_tinyPngBase64),
                secondaryLocalBytes: base64Decode(_tinyPngBase64),
                enableSecondaryControl: true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(LibraryInteractiveCover));
    await pumpUntilSettled(tester);

    expect(find.widgetWithText(FilledButton, 'Front'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Back'), findsNothing);

    await tester.tapAt(const Offset(8, 8));
    await pumpUntilSettled(tester);
  });

  testWidgets('secondary cover control can be disabled for shelf covers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 270,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode(_tinyPngBase64),
                ownedItemId: 'owned-1',
                enableFullscreen: false,
                enableSecondaryControl: false,
              ),
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.widgetWithText(FilledButton, 'Back cover'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'View back'), findsNothing);
  });

  testWidgets('hover cue can be disabled for inspector covers', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 320,
              child: LibraryInteractiveCover(
                title: 'The Hobbit',
                localBytes: base64Decode('AAECAw=='),
                enableHoverCue: false,
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
    await pumpUntilSettled(tester);

    expect(find.byType(AnimatedOpacity), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
