import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InspectorTrackList', () {
    testWidgets('renders tracks with position, title, and duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorTrackList(
              accent: Colors.blue,
              tracks: const [
                CatalogTrack(title: 'Track One', position: 1, durationSeconds: 180),
                CatalogTrack(title: 'Track Two', position: 2, durationSeconds: 245),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Track One'), findsOneWidget);
      expect(find.text('Track Two'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3:00'), findsOneWidget);
      expect(find.text('4:05'), findsOneWidget);
      expect(find.text('2 tracks (7:05)'), findsOneWidget);
    });

    testWidgets('shows total duration including hours for long albums', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorTrackList(
              accent: Colors.blue,
              tracks: const [
                CatalogTrack(title: 'Long Track', position: 1, durationSeconds: 3661),
              ],
            ),
          ),
        ),
      );

      expect(find.text('1 tracks (1:01:01)'), findsOneWidget);
    });

    testWidgets('omits duration when tracks have no durationSeconds', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorTrackList(
              accent: Colors.blue,
              tracks: const [
                CatalogTrack(title: 'No Duration', position: 1),
              ],
            ),
          ),
        ),
      );

      expect(find.text('1 tracks'), findsOneWidget);
      expect(find.textContaining('('), findsNothing);
    });

    testWidgets('uses trackCount override for header label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorTrackList(
              accent: Colors.blue,
              trackCount: 15,
              tracks: const [
                CatalogTrack(title: 'Only One Cached', position: 1, durationSeconds: 60),
              ],
            ),
          ),
        ),
      );

      expect(find.text('15 tracks (1:00)'), findsOneWidget);
    });

    testWidgets('renders without cover image when coverUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorTrackList(
              accent: Colors.blue,
              tracks: const [
                CatalogTrack(title: 'A Track', position: 1),
              ],
            ),
          ),
        ),
      );

      expect(find.text('A Track'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('InspectorTrackListUnavailable', () {
    testWidgets('shows fallback message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InspectorTrackListUnavailable(trackCount: 10, accent: Colors.blue),
          ),
        ),
      );

      expect(find.textContaining('Track'), findsWidgets);
    });
  });
}
