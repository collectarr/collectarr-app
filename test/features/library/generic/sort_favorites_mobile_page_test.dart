import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('native sort favorites preserve the last editable favorite',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final favorite =
        librarySortFavoritesForType(const MusicRegistration()).first;
    Set<String>? result;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () async => result =
                        await showSortFavoritesManagerDialog(
                            context: context,
                            type: const MusicRegistration(),
                            favorites: [favorite],
                            initialPinnedIds: {favorite.id},
                            currentRules: favorite.rules,
                            onSortSelected: (_) {}),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(MobilePage), findsOneWidget);
    expect(find.text(favorite.label), findsWidgets);
    await tester.tap(find.byTooltip('Favorite actions'));
    await tester.pumpAndSettle();
    expect(find.text('Remove'), findsNothing);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Add Built-in Favorite'), findsNothing);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(result, {favorite.id});
  }, variant: TargetPlatformVariant({TargetPlatform.android}));
}
