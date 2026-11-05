import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';
import 'package:collectarr_app/features/settings/kind_settings_controls.dart';
import 'package:collectarr_app/features/library/providers/nav_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('kind editors override and reset independently within Games',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(kindSettingsProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            home: Scaffold(
                body: ListView(children: const [
          KindSettingsControls(kind: CatalogMediaKind.game),
          KindSettingsControls(kind: CatalogMediaKind.gameToy)
        ])))));
    await tester.pumpAndSettle();
    expect(find.text('Inherited shared setting'), findsNWidgets(2));
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    final values = container.read(kindSettingsProvider).requireValue;
    expect(values.resolve(trailerVideosSetting, kind: CatalogMediaKind.game),
        false);
    expect(values.resolve(trailerVideosSetting, kind: CatalogMediaKind.gameToy),
        true);
    expect(find.text('Overridden for this kind'), findsOneWidget);
    await tester.tap(find.text('Use shared setting / Reset override'));
    await tester.pumpAndSettle();
    expect(find.text('Inherited shared setting'), findsNWidgets(2));
  });
  testWidgets(
      'shared defaults disappear when all compatible modules are disabled',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(kindSettingsProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child:
            const MaterialApp(home: Scaffold(body: KindSettingsControls()))));
    await tester.pumpAndSettle();
    expect(find.text('Shared Defaults'), findsOneWidget);
    await container.read(libraryNavPreferencesProvider.notifier).setKindVisible(
        'game', false,
        availableKinds: ['music', 'comic', 'game']);
    await tester.pumpAndSettle();
    expect(find.text('Shared Defaults'), findsNothing);
  });
}
