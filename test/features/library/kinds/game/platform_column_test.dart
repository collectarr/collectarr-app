import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/column_chooser.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/table/column_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final kind in [CatalogMediaKind.game, CatalogMediaKind.gameHardware]) {
    test('${kind.name} platform icon stays first and ignores saved widths', () {
      final workspace = libraryKindWorkspaceForKind(kind);
      final fields = workspace.workspaceFields;
      final icon = fields.columns.singleWhere((column) => column.alwaysVisible);
      expect(icon.resolvedDisplayName, isEmpty);
      expect(icon.cellPadding, EdgeInsets.zero);
      for (final favorite in libraryPresentationForKind(kind).columnFavorites) {
        final selected = {
          for (final id in favorite.columns)
            if (id != icon.id.value) fields.decodeColumnId(id),
        };
        final columns = workspace.orderedTableColumns(selected);
        expect(columns.first, icon.id);
        expect(columns.where((id) => id == icon.id), hasLength(1));
        expect(
            workspace.tableWidthForColumns(selected, {}),
            columns.fold<double>(
                0, (width, id) => width + workspace.tableColumnWidth(id, {})));
      }
      expect(workspace.tableColumnWidth(icon.id, {icon.id: 400}), 24);
      expect(workspace.tableColumnWidth(icon.id, {icon.id: 1}), 24);
    });
  }

  testWidgets(
      'platform icon is absent from field selection and saved favorites',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final type = libraryKindRegistrationForKind(CatalogMediaKind.game);
    SharedPreferences.setMockInitialValues({
      type.identity.preferenceKey('table_column_presets'): jsonEncode([
        {
          'id': 'saved',
          'label': 'Saved columns',
          'columns': ['game.platform_icon', 'game.title']
        },
      ]),
    });
    final saved = await LibraryColumnPresetStore(type).read();
    expect(saved.single.columns, {'game.title'});
    Set<String>? result;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showGenericLibraryColumnChooser(
          context: context,
          type: type,
          viewState: libraryViewProfileForKind(type.kind).defaults(),
        ),
        child: const Text('Open columns'),
      ),
    ))));
    await tester.tap(find.text('Open columns'));
    await tester.pumpAndSettle();
    final chooser = tester.widget<LibraryColumnChooserDialog>(
        find.byType(LibraryColumnChooserDialog));
    expect(chooser.availableColumns, isNot(contains('game.platform_icon')));
    expect(chooser.selectedColumns, isNot(contains('game.platform_icon')));
    expect(
        chooser.presets
            .every((preset) => !preset.columns.contains('game.platform_icon')),
        isTrue);
    expect(find.text('Platform Icon'), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result, isNot(contains('game.platform_icon')));
    final workspace = libraryKindWorkspaceForKind(type.kind);
    expect(
        workspace
            .orderedTableColumns({
              for (final id in result!)
                workspace.workspaceFields.decodeColumnId(id)
            })
            .first
            .value,
        'game.platform_icon');
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
