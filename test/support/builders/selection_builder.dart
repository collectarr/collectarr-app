import 'package:collectarr_app/features/library/selection/commands.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace_contributors.dart';
import 'package:collectarr_app/features/library/selection/action.dart';
import 'package:collectarr_app/features/library/selection/context.dart';
import 'library_entry_builder.dart';
import 'workspace_item_builder.dart';

List<ResolvedLibrarySelectionAction> testSelectionActions(
        LibrarySelectionCallbacks commands,
        {CatalogMediaKind kind = CatalogMediaKind.music,
        bool owned = true}) =>
    resolveLibrarySelectionActions(
      current: () => LibrarySelectionActionContext(
          commands: commands,
          selection: LibrarySelectionContext([
            for (var i = 0; i < 2; i++)
              testLibraryWorkspaceSource(
                  itemId: 'item-$i',
                  kind: kind.apiValue,
                  libraryEntry: owned
                      ? testLibraryEntry(
                          kind: kind.apiValue,
                          id: 'entry-$i',
                          itemId: 'item-$i')
                      : null),
          ])),
      contributions: (kind) =>
          libraryToolbarForKind(kind)?.selectionActions ?? const [],
    );

LibrarySelectionCallbacks testSelectionCommands(
        {LibrarySelectionCommand? edit,
        LibrarySelectionCommand? remove,
        LibrarySelectionCommand? merge}) =>
    (
      onClearSelection: () {},
      onSelectAll: () {},
      onBulkEdit: edit,
      onPrintToPdf: null,
      onExportCsvTxt: null,
      onExportXml: null,
      onMerge: merge,
      onBulkDuplicate: null,
      onBulkLoan: null,
      onTransferFieldData: null,
      onBulkUpdateValues: null,
      onBulkUpdateKeyInfo: null,
      onBulkMoveToEntry: null,
      onBulkMoveToWishlist: null,
      onMoveToCollection: null,
      onBulkRemove: remove,
      onBulkRefreshMetadata: null,
    );
