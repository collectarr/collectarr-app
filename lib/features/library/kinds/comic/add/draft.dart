export 'manual_draft.dart';
export 'schema.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/add/models/kind_draft.dart';
import '../domain/comic_personal_data.dart';
import '../entries/details_codec.dart';
import 'package:flutter/foundation.dart';

/// Comics owns the personal state collected by Value, Personal and the footer.
@immutable
final class ComicAddDraft extends LibraryAddKindDraft {
  const ComicAddDraft({this.personal = const ComicPersonalData()});

  /// Grade starts empty, as in the reference.
  final ComicPersonalData personal;

  ComicAddDraft copyWith({ComicPersonalData? personal}) =>
      ComicAddDraft(personal: personal ?? this.personal);

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  JsonEncodable toEntryDetailsDraft() =>
      const ComicEntryDetailsCodec().draftFromDetails(personal.details);
}
