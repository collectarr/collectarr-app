import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_status_button.dart';
import 'package:collectarr_app/features/library/add/shell/library_add_dialog_theme.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_actions.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('action text overrides retain the current application family',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildLibraryTheme(),
        home: Scaffold(
          body: Wrap(children: [
            DialogActionButtons.cancel(onPressed: () {}),
            DialogActionButtons.save(onPressed: () {}),
            OutlinedButton(
                style: libraryAddOutlinedButtonStyle(),
                onPressed: () {},
                child: const Text('Add outlined')),
            FilledButton(
                style: libraryAddFilledButtonStyle(),
                onPressed: () {},
                child: const Text('Add filled')),
            LibraryAddStatusButton(
                collectionStatus: LibraryCollectionStatusScope.inCollection,
                onAdd: () {},
                onStatusChanged: (_) {}),
            LibraryToolbarPrimaryActions(
                addLabel: 'Add Albums',
                onAdd: () {},
                onScanBarcode: () {},
                onRefreshMetadata: () {},
                addBackgroundColor: Colors.orange,
                addForegroundColor: Colors.white),
          ]),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    for (final label in [
      'Cancel',
      'Save',
      'Add outlined',
      'Add filled',
      'Add to Collection',
      'Add Albums',
    ]) {
      final paragraph = tester.renderObject<RenderParagraph>(find.descendant(
          of: find.text(label), matching: find.byType(RichText)));
      expect(paragraph.text.style!.fontFamily, appFontFamily, reason: label);
      expect(paragraph.text.style!.fontSize,
          label == 'Add to Collection' ? 16 : 14,
          reason: label);
    }
  });

  testWidgets('plain editor popup items retain the active application family',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: editDialogTheme(),
      home: Scaffold(
          body: PopupMenuButton<int>(
        itemBuilder: (_) => [
          const PopupMenuItem(value: 1, child: Text('Disc 2')),
        ],
        child: const Text('Move tracks'),
      )),
    ));
    await tester.tap(find.text('Move tracks'));
    await tester.pumpAndSettle();
    final paragraph = tester.renderObject<RenderParagraph>(find.descendant(
        of: find.text('Disc 2'), matching: find.byType(RichText)));
    expect(paragraph.text.style!.fontFamily, appFontFamily);
    expect(paragraph.text.style!.fontSize, 14);
  });
}
