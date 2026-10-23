import 'package:collectarr_app/features/library/details/library_trailer_visibility.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('trailer sections follow Show trailer videos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
            home: LibraryTrailerVisibility(child: Text('Trailer')))));
    await tester.pumpAndSettle();
    expect(find.text('Trailer'), findsOneWidget);

    await container
        .read(uiPreferencesProvider.notifier)
        .setShowInspectorTrailers(false);
    await tester.pumpAndSettle();
    expect(find.text('Trailer'), findsNothing);
    expect(
        (await SharedPreferences.getInstance())
            .getBool(UiPreferencesStore.showInspectorTrailersKey),
        isFalse);
  });
}
