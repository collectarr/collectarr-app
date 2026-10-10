import 'package:collectarr_app/features/library/generic/column_chooser.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'Music column manager receives supported favorites and primary field',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                    body: TextButton(
                  onPressed: () => showGenericLibraryColumnChooser(
                      context: context,
                      type: const MusicRegistration(),
                      viewState: musicKindViewProfile.defaults()),
                  child: const Text('Columns'),
                )))));
    await tester.tap(find.text('Columns'));
    await tester.pumpAndSettle();
    final dialog = tester.widget<LibraryColumnChooserDialog>(
        find.byType(LibraryColumnChooserDialog));
    expect(dialog.primaryColumn, 'music.title');
    expect(dialog.columnLabel('music.cover'), 'Cover');
    expect(dialog.presets.map((preset) => preset.label),
        containsAll(['Essential', 'Reference']));
    expect(dialog.presets.map((preset) => preset.label),
        isNot(contains('Collection')));
    expect(
        find.byKey(const ValueKey('column-preset-Essential')), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
