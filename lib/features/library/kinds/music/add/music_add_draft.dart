import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicAddDraft extends LibraryAddKindDraft {
  const MusicAddDraft({
    this.storageDevice,
    this.storageSlot,
  });

  final String? storageDevice;
  final String? storageSlot;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  OwnedDetailsDraft toOwnedDetailsDraft() => MusicOwnedDetailsDraft(
        storageDevice: storageDevice,
        storageSlot: storageSlot,
      );
}
