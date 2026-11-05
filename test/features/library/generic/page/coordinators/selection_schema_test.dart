import 'package:collectarr_app/features/library/generic/page/coordinators/context.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/collection_action_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/dialog_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/report_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/sharing_coordinator.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/selection/state.dart';
import 'package:collectarr_app/features/library/selection/bulk_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../../support/builders/library_entry_builder.dart';
import '../../../../../support/builders/workspace_item_builder.dart';

class _Page implements LibraryPageCoordinatorContext {
  _Page(this.context, Set<String> ids)
      : selection = LibrarySelectionState(enabled: true, itemIds: ids);
  @override
  final BuildContext context;
  @override
  final LibrarySelectionState selection;
  @override
  LibraryKindRegistration get type =>
      libraryKindRegistrationForKind(CatalogMediaKind.music);
  CatalogMediaKind? editedKind;
  @override
  Future<LibraryBulkEditSelection?> showBulkEditDialog(BuildContext context,
      {required LibraryKindRegistration type,
      required int selectedCount}) async {
    editedKind = type.kind;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LibraryProjection _projection(List<CatalogMediaKind> kinds) {
  final items = [
    for (final kind in kinds)
      LibraryProjectionItem.fromShelf(
          testLibraryWorkspaceSource(
              itemId: kind.apiValue,
              kind: kind.apiValue,
              libraryEntry: testLibraryEntry(kind: kind.apiValue)),
          libraryKindRegistrationForKind(kind))
  ];
  return LibraryProjection(
      allItems: items,
      filteredItems: items,
      buckets: const [],
      selectedItem: null,
      counts: const LibraryToolbarCounts());
}

LibraryPageCollectionActionCoordinator _collection(_Page page) =>
    LibraryPageCollectionActionCoordinator(page,
        showEditDialog: (_, entry) async {},
        compareMetadataWithServer: (_, {item}) async {});

void main() {
  testWidgets(
      'bulk edit uses the selected kind rather than the navigation kind',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    final projection = _projection([CatalogMediaKind.game]);
    final page = _Page(context,
        projection.filteredItems.map((item) => item.target.id).toSet());
    await _collection(page).bulkEditFlow(projection);
    expect(page.editedKind, CatalogMediaKind.game);
  });
  testWidgets(
      'schema-bound commands reject mixed kinds before dialogs or storage',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    final projection =
        _projection([CatalogMediaKind.music, CatalogMediaKind.game]);
    final page = _Page(context,
        projection.filteredItems.map((item) => item.target.id).toSet());
    await expectLater(
        _collection(page).bulkEditFlow(projection), throwsStateError);
    await expectLater(
        LibraryPageSharingCoordinator(page)
            .exportSelectedCsvTxtFlow(projection),
        throwsStateError);
    await expectLater(
        LibraryPageSharingCoordinator(page).exportSelectedXmlFlow(projection),
        throwsStateError);
    await expectLater(
        LibraryPageReportCoordinator(page).printSelectedReportFlow(projection),
        throwsStateError);
    await expectLater(
        LibraryPageDialogCoordinator(page)
            .showTransferFieldDataForSelectionFlow(projection),
        throwsStateError);
    expect(page.editedKind, null);
  });
  testWidgets('a stale selected ID is rejected before showing bulk edit',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (value) {
      context = value;
      return const SizedBox();
    })));
    final projection = _projection([CatalogMediaKind.music]);
    final page = _Page(context,
        {...projection.filteredItems.map((item) => item.target.id), 'stale'});
    await expectLater(
        _collection(page).bulkEditFlow(projection), throwsStateError);
    expect(page.editedKind, null);
  });
}
