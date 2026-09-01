import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class ComicFieldIds {
  static const status = LibraryFieldId<ComicKind, String?>('comic.status');
  static const cover = LibraryFieldId<ComicKind, String?>('comic.cover');
  static const series = LibraryFieldId<ComicKind, String?>('comic.series');
  static const title = LibraryFieldId<ComicKind, String>('comic.title');
  static const issueNumber =
      LibraryFieldId<ComicKind, String?>('comic.issue_number');
  static const publisher =
      LibraryFieldId<ComicKind, String?>('comic.publisher');
  static const releaseDate =
      LibraryFieldId<ComicKind, DateTime?>('comic.release_date');
  static const barcode = LibraryFieldId<ComicKind, String?>('comic.barcode');
  static const rating = LibraryFieldId<ComicKind, int?>('comic.rating');
  static const condition =
      LibraryFieldId<ComicKind, String?>('comic.condition');
  static const pricePaid = LibraryFieldId<ComicKind, int?>('comic.price_paid');
  static const location = LibraryFieldId<ComicKind, String?>('comic.location');
  static const wishlist = LibraryFieldId<ComicKind, bool>('comic.wishlist');
  static const updatedAt =
      LibraryFieldId<ComicKind, DateTime>('comic.updated_at');
  static const addedAt = LibraryFieldId<ComicKind, DateTime?>('comic.added_at');
  static const readStatus =
      LibraryFieldId<ComicKind, String?>('comic.read_status');
  static const grade = LibraryFieldId<ComicKind, String?>('comic.grade');
  static const keyComic = LibraryFieldId<ComicKind, bool>('comic.key_comic');
  static const keyReason =
      LibraryFieldId<ComicKind, String?>('comic.key_reason');
  static const keyCategory =
      LibraryFieldId<ComicKind, String?>('comic.key_category');
  static const keySeverity =
      LibraryFieldId<ComicKind, String?>('comic.key_severity');
  static const rawOrSlabbed =
      LibraryFieldId<ComicKind, String?>('comic.raw_or_slabbed');
  static const gradingCompany =
      LibraryFieldId<ComicKind, String?>('comic.grading_company');
  static const graderNotes =
      LibraryFieldId<ComicKind, String?>('comic.grader_notes');
  static const signedBy = LibraryFieldId<ComicKind, String?>('comic.signed_by');
  static const labelType =
      LibraryFieldId<ComicKind, String?>('comic.label_type');
  static const customLabel =
      LibraryFieldId<ComicKind, String?>('comic.custom_label');
  static const pageQuality =
      LibraryFieldId<ComicKind, String?>('comic.page_quality');
  static const certificationNumber =
      LibraryFieldId<ComicKind, String?>('comic.certification_number');
  static const coverPrice =
      LibraryFieldId<ComicKind, int?>('comic.cover_price');
  static const lastBagBoardDate =
      LibraryFieldId<ComicKind, DateTime?>('comic.last_bag_board_date');

  // Rich Comic Metadata Fields
  static const writer = LibraryFieldId<ComicKind, String?>('comic.writer');
  static const artist = LibraryFieldId<ComicKind, String?>('comic.artist');
  static const coverArtist =
      LibraryFieldId<ComicKind, String?>('comic.cover_artist');
  static const imprint = LibraryFieldId<ComicKind, String?>('comic.imprint');
  static const variant = LibraryFieldId<ComicKind, String?>('comic.variant');
  static const pageCount = LibraryFieldId<ComicKind, int?>('comic.page_count');
}

abstract final class ComicSortIds {
  static const series = LibrarySortId<ComicKind>('comic.series');
  static const issueNumber = LibrarySortId<ComicKind>('comic.issue_number');
  static const publisher = LibrarySortId<ComicKind>('comic.publisher');
  static const status = LibrarySortId<ComicKind>('comic.status');
  static const title = LibrarySortId<ComicKind>('comic.title');
  static const releaseDate = LibrarySortId<ComicKind>('comic.release_date');
  static const condition = LibrarySortId<ComicKind>('comic.condition');
  static const rating = LibrarySortId<ComicKind>('comic.rating');
  static const pricePaid = LibrarySortId<ComicKind>('comic.price_paid');
  static const updatedAt = LibrarySortId<ComicKind>('comic.updated_at');
}

abstract final class ComicGroupIds {
  static const series = LibraryGroupId<ComicKind, String?>('comic.series');
  static const publisher =
      LibraryGroupId<ComicKind, String?>('comic.publisher');
  static const location = LibraryGroupId<ComicKind, String?>(
    'comic.location',
    semantic: LibraryGroupSemantic.location,
  );
  static const condition =
      LibraryGroupId<ComicKind, String?>('comic.condition');
  static const rating = LibraryGroupId<ComicKind, int?>('comic.rating');
  static const creator = LibraryGroupId<ComicKind, String?>('comic.creator');
  static const character =
      LibraryGroupId<ComicKind, String?>('comic.character');
  static const storyArc = LibraryGroupId<ComicKind, String?>('comic.story_arc');
  static const imprint = LibraryGroupId<ComicKind, String?>('comic.imprint');
  static const writer = LibraryGroupId<ComicKind, String?>('comic.writer');
  static const artist = LibraryGroupId<ComicKind, String?>('comic.artist');
}

abstract final class ComicFacetIds {
  static const publisher = LibraryFacetId<ComicKind, String>('comic.publisher');
  static const genre = LibraryFacetId<ComicKind, String>('comic.genre');
  static const character = LibraryFacetId<ComicKind, String>('comic.character');
  static const storyArc = LibraryFacetId<ComicKind, String>('comic.story_arc');
  static const writer = LibraryFacetId<ComicKind, String>('comic.writer');
  static const artist = LibraryFacetId<ComicKind, String>('comic.artist');
}
