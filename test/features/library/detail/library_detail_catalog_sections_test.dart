import 'package:collectarr_app/features/library/config/planned_library_configs.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('detail context section renders metadata and genres', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryDetailContextSection(
            type: musicLibraryConfig,
            accent: Colors.cyan,
            entry: LibraryWorkspaceEntry(
              id: 'music-1',
              mediaType: 'music',
              title: 'Discovery',
              publisher: 'Virgin',
              releaseYear: 2001,
              trackCount: 14,
              genres: const ['House', 'Electronic'],
              updatedAt: DateTime(2026, 1, 1),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Catalog context'), findsOneWidget);
    expect(find.text('Tracks'), findsOneWidget);
    expect(find.text('Genres'), findsOneWidget);
    expect(find.text('House'), findsOneWidget);
  });

  testWidgets('detail credits section renders discovery groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryDetailCreditsSection(
            type: mangaLibraryConfig,
            accent: Colors.orange,
            entry: LibraryWorkspaceEntry(
              id: 'comic-1',
              mediaType: 'comic',
              title: 'Saga #1',
              creators: const [
                {'name': 'Brian K. Vaughan', 'role': 'Writer'},
              ],
              characters: const ['Alana'],
              storyArcs: const ['Saga'],
              updatedAt: DateTime(2026, 1, 1),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Credits & Discovery'), findsOneWidget);
    expect(find.text('Creators'), findsOneWidget);
    expect(find.textContaining('Brian K. Vaughan'), findsOneWidget);
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Story Arcs'), findsOneWidget);
  });
}