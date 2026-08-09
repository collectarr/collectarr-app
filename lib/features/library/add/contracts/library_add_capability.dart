import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';

abstract interface class LibraryAddCapability<TDraft extends LibraryAddKindDraft> {
  CatalogMediaKind get kind;

  TDraft createInitialDraft();

  AddOwnedItemCommand buildCommand(
    CatalogItem item,
    LibraryAddCommonDraft common,
    TDraft draft,
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
    CatalogItem item,
    LibraryAddCommonDraft common,
    TDraft draft,
  ) {
    return AddOwnedItemCommand(
      catalogRef: CatalogEntityRef(
        kind: item.kind,
        entityType: CatalogEntityType.work,
        id: item.id,
      ),
      common: common.toOwnedItemCommonDraft(),
      details: draft.toOwnedDetailsDraft(),
    );
  }
}

class LibraryAddCapabilityRegistry {
  LibraryAddCapabilityRegistry._();
  static final LibraryAddCapabilityRegistry instance = LibraryAddCapabilityRegistry._();

  final Map<CatalogMediaKind, LibraryAddCapability> _capabilities = {
    CatalogMediaKind.comic: StandardLibraryAddCapability<ComicAddDraft>(
      kind: CatalogMediaKind.comic,
      initialDraftBuilder: () => const ComicAddDraft(),
    ),
    CatalogMediaKind.movie: StandardLibraryAddCapability<VideoAddDraft>(
      kind: CatalogMediaKind.movie,
      initialDraftBuilder: () => const VideoAddDraft(),
    ),
    CatalogMediaKind.game: StandardLibraryAddCapability<GameAddDraft>(
      kind: CatalogMediaKind.game,
      initialDraftBuilder: () => const GameAddDraft(),
    ),
    CatalogMediaKind.music: StandardLibraryAddCapability<MusicAddDraft>(
      kind: CatalogMediaKind.music,
      initialDraftBuilder: () => const MusicAddDraft(),
    ),
    CatalogMediaKind.book: StandardLibraryAddCapability<BookAddDraft>(
      kind: CatalogMediaKind.book,
      initialDraftBuilder: () => const BookAddDraft(),
    ),
    CatalogMediaKind.boardgame: StandardLibraryAddCapability<BoardGameAddDraft>(
      kind: CatalogMediaKind.boardgame,
      initialDraftBuilder: () => const BoardGameAddDraft(),
    ),
  };

  LibraryAddCapability getForKind(CatalogMediaKind kind) {
    return _capabilities[kind] ??
        StandardLibraryAddCapability<GenericAddDraft>(
          kind: CatalogMediaKind.unknown,
          initialDraftBuilder: () => const GenericAddDraft(),
        );
  }
}
