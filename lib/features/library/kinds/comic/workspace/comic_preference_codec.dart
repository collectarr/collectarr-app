import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class ComicPreferenceCodec
    implements LibraryWorkspacePreferenceCodec<ComicKind> {
  const ComicPreferenceCodec();

  static const Map<String, LibraryFieldId<ComicKind, Object?>> _columnMap = {
    'status': ComicFieldIds.status,
    'comic.status': ComicFieldIds.status,
    'cover': ComicFieldIds.cover,
    'comic.cover': ComicFieldIds.cover,
    'series': ComicFieldIds.series,
    'comic.series': ComicFieldIds.series,
    'title': ComicFieldIds.title,
    'comic.title': ComicFieldIds.title,
    'number': ComicFieldIds.issueNumber,
    'issue_number': ComicFieldIds.issueNumber,
    'comic.number': ComicFieldIds.issueNumber,
    'comic.issue_number': ComicFieldIds.issueNumber,
    'publisher': ComicFieldIds.publisher,
    'comic.publisher': ComicFieldIds.publisher,
    'release_date': ComicFieldIds.releaseDate,
    'comic.release_date': ComicFieldIds.releaseDate,
    'barcode': ComicFieldIds.barcode,
    'comic.barcode': ComicFieldIds.barcode,
    'rating': ComicFieldIds.rating,
    'comic.rating': ComicFieldIds.rating,
    'condition': ComicFieldIds.condition,
    'comic.condition': ComicFieldIds.condition,
    'price': ComicFieldIds.pricePaid,
    'price_paid': ComicFieldIds.pricePaid,
    'comic.price': ComicFieldIds.pricePaid,
    'comic.price_paid': ComicFieldIds.pricePaid,
    'location': ComicFieldIds.location,
    'comic.location': ComicFieldIds.location,
    'wishlist': ComicFieldIds.wishlist,
    'comic.wishlist': ComicFieldIds.wishlist,
    'updated': ComicFieldIds.updatedAt,
    'updated_at': ComicFieldIds.updatedAt,
    'comic.updated': ComicFieldIds.updatedAt,
    'comic.updated_at': ComicFieldIds.updatedAt,
    'added': ComicFieldIds.addedAt,
    'added_at': ComicFieldIds.addedAt,
    'comic.added': ComicFieldIds.addedAt,
    'comic.added_at': ComicFieldIds.addedAt,
    'read_status': ComicFieldIds.readStatus,
    'comic.read_status': ComicFieldIds.readStatus,
    'grade': ComicFieldIds.grade,
    'comic.grade': ComicFieldIds.grade,
    'key_comic': ComicFieldIds.keyComic,
    'comic.key_comic': ComicFieldIds.keyComic,
  };

  static const Map<String, LibrarySortId<ComicKind>> _sortMap = {
    'series': ComicSortIds.series,
    'comic.series': ComicSortIds.series,
    'number': ComicSortIds.issueNumber,
    'issue_number': ComicSortIds.issueNumber,
    'comic.number': ComicSortIds.issueNumber,
    'comic.issue_number': ComicSortIds.issueNumber,
    'publisher': ComicSortIds.publisher,
    'comic.publisher': ComicSortIds.publisher,
    'status': ComicSortIds.status,
    'comic.status': ComicSortIds.status,
    'title': ComicSortIds.title,
    'comic.title': ComicSortIds.title,
    'release_date': ComicSortIds.releaseDate,
    'comic.release_date': ComicSortIds.releaseDate,
    'rating': ComicSortIds.rating,
    'comic.rating': ComicSortIds.rating,
    'price': ComicSortIds.pricePaid,
    'price_paid': ComicSortIds.pricePaid,
    'comic.price': ComicSortIds.pricePaid,
    'comic.price_paid': ComicSortIds.pricePaid,
    'updated': ComicSortIds.updatedAt,
    'updated_at': ComicSortIds.updatedAt,
    'comic.updated': ComicSortIds.updatedAt,
    'comic.updated_at': ComicSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<ComicKind, Object?>> _groupMap = {
    'series': ComicGroupIds.series,
    'comic.series': ComicGroupIds.series,
    'publisher': ComicGroupIds.publisher,
    'comic.publisher': ComicGroupIds.publisher,
    'location': ComicGroupIds.location,
    'comic.location': ComicGroupIds.location,
    'condition': ComicGroupIds.condition,
    'comic.condition': ComicGroupIds.condition,
    'rating': ComicGroupIds.rating,
    'comic.rating': ComicGroupIds.rating,
    'creator': ComicGroupIds.creator,
    'comic.creator': ComicGroupIds.creator,
    'character': ComicGroupIds.character,
    'comic.character': ComicGroupIds.character,
    'story_arc': ComicGroupIds.storyArc,
    'comic.story_arc': ComicGroupIds.storyArc,
  };

  @override
  LibraryFieldId<ComicKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<ComicKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<ComicKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<ComicKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
