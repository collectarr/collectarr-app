import 'package:collectarr_app/features/library/generic/sort_dialog.dart';
import 'package:collectarr_app/features/library/generic/sort_preset_store.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/features/library/ui/primitives/field_selection.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('empty sort edit saves its initial first field and direction',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    List<LibrarySortRule>? result;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
          onPressed: () async {
            result = await showLibrarySortDialog(
                context: context,
                type: const MusicRegistration(),
                showFavorites: false,
                currentRules: const [
                  LibrarySortRule(column: 'music.title', ascending: false),
                  LibrarySortRule(column: 'music.artist', ascending: true),
                ]);
          },
          child: const Text('Open')),
    ))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove sort field').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove sort field').first);
    await tester.pumpAndSettle();
    expect(find.byType(LibrarySelectedFieldRow), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(result,
        const [LibrarySortRule(column: 'music.title', ascending: false)]);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('native sort lists only saved favorites with edit and delete',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = LibrarySortPresetStore(const MusicRegistration());
    await store.saveFavorites(const [
      LibrarySortPreset(
        id: 'custom-title',
        label: 'My title order',
        rules: [LibrarySortRule(column: 'music.title', ascending: true)],
      )
    ]);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showLibrarySortDialog(
              context: context,
              type: const MusicRegistration(),
              currentRules: const [
                LibrarySortRule(column: 'music.title', ascending: true),
              ],
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('My title order'), findsOneWidget);
    expect(find.text('Latest release'), findsNothing);
    expect(find.byTooltip('Edit My title order'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit My title order'));
    await tester.pumpAndSettle();
    expect(find.text('Select Sort Fields'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('My title order'), findsOneWidget);
    expect(
        tester
            .widget<IconButton>(find.byWidgetPredicate((widget) =>
                widget is IconButton &&
                widget.tooltip == 'Delete My title order'))
            .onPressed,
        isNull);
    expect(find.text('My title order'), findsOneWidget);
    expect((await store.read()).single.label, 'My title order');
    await tester.tap(find.byTooltip('Save sort favorite'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'New favorite');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect(find.text('New favorite'), findsOneWidget);
    expect((await store.read()).map((preset) => preset.label),
        ['My title order', 'New favorite']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('native sort opens as a page and returns the chosen order',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    List<LibrarySortRule>? result;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () async => result = await showLibrarySortDialog(
                            context: context,
                            type: const MusicRegistration(),
                            currentRules: const [
                              LibrarySortRule(
                                  column: 'music.title', ascending: true)
                            ]),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(MobilePage), findsOneWidget);
    expect(tester.widget<MobilePage>(find.byType(MobilePage)).title,
        'Select Sort Order');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(find.byType(MobilePage), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest First'));
    await tester.pumpAndSettle();
    expect(result,
        const [LibrarySortRule(column: 'music.title', ascending: false)]);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));

  testWidgets('reassign keeps declared categories without sorting favorites',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    List<LibrarySortRule>? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      result = await showLibrarySortDialog(
                          context: context,
                          type: const MusicRegistration(),
                          title: 'Re-Assign Index Values',
                          confirmLabel: 'OK',
                          showFavorites: false,
                          availableColumns: [
                            for (final sort in libraryKindWorkspaceForKind(
                                    const MusicRegistration().kind)
                                .libraryEntryFields
                                .sorts)
                              sort.id.value
                          ],
                          currentRules: const [
                            LibrarySortRule(
                                column: 'music.title', ascending: true)
                          ]);
                    },
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Sorting favorites'), findsNothing);
    await tester.tap(find.text('Main'));
    await tester.pumpAndSettle();
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Loan'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Earliest');
    await tester.pumpAndSettle();
    expect(find.text('Recording'), findsOneWidget);
    expect(find.text('Main'), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result,
        const [LibrarySortRule(column: 'music.title', ascending: true)]);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('sort field search can be cleared and used again',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                    body: TextButton(
                  onPressed: () => showLibrarySortDialog(
                      context: context,
                      type: const MusicRegistration(),
                      currentRules: const [
                        LibrarySortRule(column: 'music.title', ascending: true)
                      ]),
                  child: const Text('Sort'),
                )))));
    await tester.tap(find.text('Sort'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<AccentDialogHeader>(find.byType(AccentDialogHeader))
            .accent,
        const MusicRegistration().identity.accent);
    final search = find.descendant(
        of: find.byType(LibraryFieldSelectionSearch),
        matching: find.byType(TextField));
    await tester.enterText(search, 'Barcode');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('available-sort-music.barcode')),
        findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    await tester.enterText(search, 'Release Date');
    await tester.pumpAndSettle();
    expect(find.text('Barcode'), findsNothing);
    expect(find.byKey(const ValueKey('available-sort-music.release_date')),
        findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(700, 650));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Sorting favorites'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Sorting favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Latest release'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('selected-sort-music.release_date')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Select Sort Fields'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  testWidgets(
      'sort fields reorder, change direction and save in priority order',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    List<LibrarySortRule>? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      result = await showLibrarySortDialog(
                          context: context,
                          type: const MusicRegistration(),
                          currentRules: const [
                            LibrarySortRule(
                                column: 'music.title', ascending: true),
                            LibrarySortRule(
                                column: 'music.artist', ascending: true)
                          ]);
                    },
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final title = find.byKey(const ValueKey('selected-sort-music.title'));
    final artist = find.byKey(const ValueKey('selected-sort-music.artist'));
    expect(tester.getSize(title).height, 31);
    await tester.tap(find.descendant(of: artist, matching: find.text('ASC')));
    await tester.pumpAndSettle();
    final start = tester.getCenter(
        find.byKey(const ValueKey('selected-sort-music.artist-handle')));
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(0, -8));
    await tester.pump();
    await gesture.moveTo(tester.getTopLeft(title) + const Offset(12, 2));
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(artist).dy, lessThan(tester.getTopLeft(title).dy));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(result, const [
      LibrarySortRule(column: 'music.artist', ascending: false),
      LibrarySortRule(column: 'music.title', ascending: true)
    ]);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('sort dialog keeps both lists usable on a 350px window',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(350, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => showLibrarySortDialog(
                            context: context,
                            type: const MusicRegistration(),
                            currentRules: const [
                              LibrarySortRule(
                                  column: 'music.artist', ascending: true)
                            ]),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('selected-sort-music.artist')),
        findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
