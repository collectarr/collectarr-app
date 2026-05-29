import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('group mode dropdown exposes favorites and folders sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: moviesLibraryConfig,
            selectedMode: LibraryGroupMode.releaseYear,
            availableModes: libraryGroupModesForType(moviesLibraryConfig),
            initialPinnedModes: const {LibraryGroupMode.director},
            sidebarVisible: true,
            hasSidebarVisibilityToggle: true,
          ),
        ),
      ),
    );

    expect(find.text('No folders'), findsOneWidget);
    expect(find.text('Manage Favorites'), findsOneWidget);
    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Edition'), findsOneWidget);
    expect(find.text('Cast & Crew'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Director'), findsWidgets);
    expect(find.text('Format'), findsNothing);
    expect(find.text('Release Year'), findsWidgets);
    expect(find.text('Audience Rating'), findsOneWidget);
    expect(find.text('Movie / TV Series'), findsOneWidget);
    expect(find.text('Studios'), findsOneWidget);

    final editionHeader = find.widgetWithText(InkWell, 'Edition');
    await tester.ensureVisible(editionHeader);
    await tester.tap(editionHeader);
    await tester.pumpAndSettle();

    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Audio Tracks'), findsOneWidget);
    expect(find.text('Edition Release Date'), findsOneWidget);
  });
}