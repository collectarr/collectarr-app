import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicAddDraft extends LibraryAddKindDraft {
  const MusicAddDraft({
    this.grade = 'Ungraded',
    this.media = const [],
    this.signedBy,
  });

  final String? grade;
  final List<MusicEntryDiscDetails> media;
  final String? signedBy;

  MusicAddDraft copyWith({
    Object? grade = _musicAddDraftUnset,
    List<MusicEntryDiscDetails>? media,
    Object? signedBy = _musicAddDraftUnset,
  }) =>
      MusicAddDraft(
        grade: identical(grade, _musicAddDraftUnset)
            ? this.grade
            : grade as String?,
        media: media ?? this.media,
        signedBy: identical(signedBy, _musicAddDraftUnset)
            ? this.signedBy
            : signedBy as String?,
      );

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  JsonEncodable toEntryDetailsDraft() => MusicEntryDetailsDraft(
        media: media,
        signedBy: signedBy,
      );
}

const Object _musicAddDraftUnset = Object();
