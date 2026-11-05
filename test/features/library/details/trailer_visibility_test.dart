import 'package:collectarr_app/features/settings/kind_settings_provider.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/details/trailer_visibility.dart';
import 'package:collectarr_app/features/settings/kind_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('mixed-kind trailer sections resolve their own preferences',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(kindSettingsProvider.future);
    await container
        .read(kindSettingsProvider.notifier)
        .setOverride(trailerVideosSetting, CatalogMediaKind.game, false);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
            home: Column(children: [
          LibraryTrailerVisibility(
              kind: CatalogMediaKind.game, child: Text('Game trailer')),
          LibraryTrailerVisibility(
              kind: CatalogMediaKind.gameToy, child: Text('Toy trailer')),
        ]))));
    await tester.pumpAndSettle();
    expect(find.text('Game trailer'), findsNothing);
    expect(find.text('Toy trailer'), findsOneWidget);
    await container
        .read(kindSettingsProvider.notifier)
        .reset(trailerVideosSetting, CatalogMediaKind.game);
    await tester.pumpAndSettle();
    expect(find.text('Game trailer'), findsOneWidget);
  });
}
