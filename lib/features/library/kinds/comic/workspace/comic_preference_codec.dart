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
    return super.decodeColumn(persisted);
  }
}
