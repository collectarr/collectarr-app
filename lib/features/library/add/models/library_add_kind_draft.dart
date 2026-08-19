import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class LibraryAddKindDraft {
  const LibraryAddKindDraft();

  CatalogMediaKind get kind;
  OwnedDetailsDraft toOwnedDetailsDraft();
}
