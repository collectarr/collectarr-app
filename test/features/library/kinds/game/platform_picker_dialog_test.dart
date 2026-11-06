import 'package:collectarr_app/features/library/kinds/game/add/platform_picker_dialog.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('platforms are grouped by generation, newest first', () {
    final groups = gamePlatformPickerGroups('Neo Geo');
    expect(
        groups.first, ['PlayStation 5', 'Xbox Series X', 'Nintendo Switch 2']);
    expect(groups[2].first, 'PC');
    expect(groups.last, contains('Neo Geo'));
    expect(groups.expand((group) => group).toSet().length,
        groups.expand((group) => group).length);
  });

  testWidgets('Pick Platform stars favorites and returns the choice',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? chosen = 'unset';
    // No platform icons loaded by the user, without a database.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        listValueImageProvider.overrideWith((ref, key) => Stream.value(null))
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                chosen = await showGamePlatformPicker(context, selected: ''),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Pick Platform'), findsOneWidget);
    expect(find.text('All platforms'), findsOneWidget);

    await tester.tap(
        find.byKey(const ValueKey('game-platform-favorite-PlayStation 4')));
    await tester.pumpAndSettle();
    expect(find.text('PlayStation 4'), findsNWidgets(2));
    final prefs = await SharedPreferences.getInstance();
    expect(
        prefs.getStringList('game.add.platformFavorites'), ['PlayStation 4']);

    await tester.enterText(
        find.byKey(const ValueKey('game-platform-picker-search')), 'cube');
    await tester.pump();
    expect(find.text('GameCube'), findsOneWidget);
    expect(find.text('PC'), findsNothing);
    await tester.tap(find.text('GameCube'));
    await tester.pumpAndSettle();
    expect(chosen, 'GameCube');
  });
}
