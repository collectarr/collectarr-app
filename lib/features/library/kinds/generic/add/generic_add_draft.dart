import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class GenericAddDraft extends LibraryAddKindDraft {
  const GenericAddDraft();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.unknown;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => const GenericOwnedDetailsDraft();
}
