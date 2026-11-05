import 'package:collectarr_app/features/library/selection/action.dart';
import 'package:collectarr_app/features/library/selection/context.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace_contributors.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../support/builders/selection_builder.dart';
import '../../../support/builders/workspace_item_builder.dart';
import '../../../support/builders/library_entry_builder.dart';

void main() {
  test('kind-only actions do not leak into mixed-kind selections', () {
    final commands =
        testSelectionCommands(edit: () {}, remove: () {}, merge: () {});
    final selection = LibrarySelectionContext([
      for (final kind in [CatalogMediaKind.music, CatalogMediaKind.comic])
        testLibraryWorkspaceSource(
            itemId: kind.apiValue,
            kind: kind.apiValue,
            libraryEntry: testLibraryEntry(kind: kind.apiValue)),
    ]);
    final actions = resolveLibrarySelectionActions(
        current: () => LibrarySelectionActionContext(
            selection: selection, commands: commands),
        contributions: (kind) => libraryToolbarForKind(kind)!.selectionActions);
    expect(
        actions.any((action) =>
            action.action.id == 'music.merge' ||
            action.action.id == 'comic.keys'),
        false);
    expect(actions.singleWhere((action) => action.action.id == 'edit').enabled,
        true);
  });
  test('invocation rechecks current targets before running a stale action',
      () async {
    var calls = 0;
    final commands = testSelectionCommands(edit: () => calls++);
    var selection = LibrarySelectionContext([
      testLibraryWorkspaceSource(
          itemId: 'a',
          kind: 'music',
          libraryEntry: testLibraryEntry(kind: 'music'))
    ]);
    final actions = resolveLibrarySelectionActions(
        current: () => LibrarySelectionActionContext(
            selection: selection, commands: commands),
        contributions: (kind) => libraryToolbarForKind(kind)!.selectionActions);
    final edit = actions.singleWhere((action) => action.action.id == 'edit');
    expect(edit.enabled, true);
    selection = LibrarySelectionContext(
        [testLibraryWorkspaceSource(itemId: 'a', kind: 'music')]);
    expect(() => edit.invoke(), throwsStateError);
    expect(calls, 0);
  });
  test('a distinct contributed operation requires no changes to the renderer',
      () async {
    var calls = 0;
    final commands = testSelectionCommands(remove: () => calls++);
    final synthetic = LibrarySelectionAction(
        id: 'synthetic.check',
        label: 'Check condition',
        icon: Icons.check,
        command: (commands) => commands.onBulkRemove);
    final actions = resolveLibrarySelectionActions(
        current: () => LibrarySelectionActionContext(
            selection: LibrarySelectionContext(
                [testLibraryWorkspaceSource(itemId: 'a', kind: 'music')]),
            commands: commands),
        contributions: (_) => [synthetic]);
    expect(actions.single.action.label, 'Check condition');
    await actions.single.invoke();
    expect(calls, 1);
  });
  test('asynchronous command failures reach the caller', () async {
    final commands =
        testSelectionCommands(remove: () async => throw StateError('Rejected'));
    final actions = testSelectionActions(commands);
    await expectLater(
        actions.singleWhere((action) => action.action.id == 'remove').invoke(),
        throwsStateError);
  });
}
