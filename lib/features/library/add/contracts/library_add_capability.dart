import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

abstract interface class LibraryAddCapability<
    TDraft extends LibraryAddKindDraft> {
  CatalogMediaKind get kind;

  TDraft createInitialDraft();

  AddOwnedItemCommand buildCommand(
    LibraryMetadataItem item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft,
  );
}

class StandardLibraryAddCapability<TDraft extends LibraryAddKindDraft>
    implements LibraryAddCapability<TDraft> {
  const StandardLibraryAddCapability({
    required this.kind,
    required this.initialDraftBuilder,
  });

  @override
  final CatalogMediaKind kind;
  final TDraft Function() initialDraftBuilder;

  @override
  TDraft createInitialDraft() => initialDraftBuilder();

  @override
  AddOwnedItemCommand buildCommand(
    LibraryMetadataItem item,
    LibraryAddCommonDraft common,
    LibraryAddKindDraft draft,
  ) {
    final effectiveDraft = draft is TDraft ? draft : createInitialDraft();
    return AddOwnedItemCommand(
      catalogRef: CatalogEntityRef(
        kind: item.kind,
        entityType: CatalogEntityType.work,
        id: item.id,
      ),
      common: common.toOwnedItemCommonDraft(),
      details: effectiveDraft.toOwnedDetailsDraft(),
    );
  }
}
