import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicAddDraft extends LibraryAddKindDraft {
  const MusicAddDraft({
    this.grade = 'Ungraded',
    this.media = const [],
  });

  final String? grade;
  final List<MusicOwnedMediumDetails> media;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  JsonEncodable toOwnedDetailsDraft() => MusicOwnedDetailsDraft(
        media: media,
      );
}
