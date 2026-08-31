import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_unsupported_pane.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/widgets.dart';

abstract interface class LibraryAddCapability<
    TDraft extends LibraryAddKindDraft> {
  CatalogMediaKind get kind;

  TDraft createInitialDraft();
  LibraryKindAddDraft createManualDraft();

  Widget buildManualPane(
    BuildContext context,
    LibraryAddManualPaneRequest request,
  );

  LibraryAddHeaderBuilder? get headerBuilder;
  LibraryAddModeBarBuilder? get modeBarBuilder;
  LibraryAddPreviewPaneBuilder? get previewPaneBuilder;
  LibraryAddSearchPaneBuilder? get searchPaneBuilder;
  LibraryAddBottomBarBuilder? get bottomBarBuilder;

  List<LibraryAddAdvancedFilterField> Function(LibraryAddModeBarRequest request)?
      get advancedFilterFieldsBuilder;
  Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      get advancedFiltersBuilder;

  Widget? buildPreviewPane(
    BuildContext context,
    LibraryAddPreviewPaneRequest request,
  );

  AddOwnedItemCommand buildCommand(
    LibraryMetadataItem item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft,
  );
}

class _EmptyKindAddDraft implements LibraryKindAddDraft {
  const _EmptyKindAddDraft();
  @override
  void dispose() {}
}

class StandardLibraryAddCapability<TDraft extends LibraryAddKindDraft>
    implements LibraryAddCapability<TDraft> {
  const StandardLibraryAddCapability({
    required this.kind,
    required this.initialDraftBuilder,
    this.manualDraftBuilder,
    this.manualPaneBuilder,
    this.headerBuilder,
    this.modeBarBuilder,
    this.previewPaneBuilder,
    this.searchPaneBuilder,
    this.bottomBarBuilder,
    this.advancedFilterFieldsBuilder,
    this.advancedFiltersBuilder,
  });

  @override
  final CatalogMediaKind kind;
  final TDraft Function() initialDraftBuilder;
  final LibraryKindAddDraft Function()? manualDraftBuilder;
  final Widget Function(BuildContext context, LibraryAddManualPaneRequest request)?
      manualPaneBuilder;
  @override
  final LibraryAddHeaderBuilder? headerBuilder;
  @override
  final LibraryAddModeBarBuilder? modeBarBuilder;
  @override
  final LibraryAddPreviewPaneBuilder? previewPaneBuilder;
  @override
  final LibraryAddSearchPaneBuilder? searchPaneBuilder;
  @override
  final LibraryAddBottomBarBuilder? bottomBarBuilder;
  @override
  final List<LibraryAddAdvancedFilterField> Function(LibraryAddModeBarRequest request)?
      advancedFilterFieldsBuilder;
  @override
  final Widget Function(BuildContext context, LibraryAddModeBarRequest request)?
      advancedFiltersBuilder;

  @override
  TDraft createInitialDraft() => initialDraftBuilder();

  @override
  LibraryKindAddDraft createManualDraft() =>
      manualDraftBuilder?.call() ?? const _EmptyKindAddDraft();

  @override
  Widget buildManualPane(
    BuildContext context,
    LibraryAddManualPaneRequest request,
  ) {
    if (manualPaneBuilder != null) {
      return manualPaneBuilder!(context, request);
    }
    return LibraryAddUnsupportedManualPane(request: request);
  }

  @override
  Widget? buildPreviewPane(
    BuildContext context,
    LibraryAddPreviewPaneRequest request,
  ) {
    return previewPaneBuilder?.call(context, request);
  }

  @override
  AddOwnedItemCommand buildCommand(
    LibraryMetadataItem item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft,
  ) {
    final effectiveDraft = draft is TDraft ? draft : createInitialDraft();
    return AddOwnedItemCommand(
      catalogRef: CatalogEntityRef(
        kind: kind.apiValue,
        entityType: CatalogEntityType.ownedCopy,
        id: item.id,
      ),
      common: common.toOwnedItemCommonDraft(),
      details: effectiveDraft.toOwnedDetailsDraft(),
    );
  }
}
