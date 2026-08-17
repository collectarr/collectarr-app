import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

class ComicPreferenceCodec
    extends IdentityLibraryWorkspacePreferenceCodec<ComicKind> {
  const ComicPreferenceCodec();

  @override
  LibraryFieldId<ComicKind, Object?>? decodeColumn(String persisted) {
    if (persisted == 'price' || persisted == 'price_paid') {
      return ComicFieldIds.pricePaid;
    }
    if (persisted == 'grade' || persisted == 'condition') {
      return ComicFieldIds.condition;
    }
    if (persisted == 'updated') {
      return ComicFieldIds.updatedAt;
    }
    return super.decodeColumn(persisted);
  }

  @override
  LibrarySortId<ComicKind>? decodeSort(String persisted) {
    if (persisted == 'grade' || persisted == 'condition') {
      return ComicSortIds.condition;
    }
    if (persisted == 'updated') {
      return ComicSortIds.updatedAt;
    }
    return super.decodeSort(persisted);
  }
}
