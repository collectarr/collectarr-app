import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class GenericAddDraft extends LibraryAddKindDraft {
  const GenericAddDraft();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.unknown;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => const GenericOwnedDetailsDraft();
}
