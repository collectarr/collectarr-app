import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('native sort favorites can be removed and saved from a page',
      (tester) async {
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
                            initialPinnedIds: {favorite.id}),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(MobilePage), findsOneWidget);
    expect(find.text(favorite.label), findsWidgets);
    await tester.tap(find.byTooltip('Favorite actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Add Favorite'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(result, isEmpty);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));
}
