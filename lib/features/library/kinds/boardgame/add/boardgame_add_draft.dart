import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BoardgameAddDraft extends LibraryAddKindDraft {
  const BoardgameAddDraft();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => const BoardgameOwnedDetailsDraft();
}

typedef BoardGameAddDraft = BoardgameAddDraft;
