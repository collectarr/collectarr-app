import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class MangaFieldIds {
  static const status = LibraryFieldId<MangaKind, String?>('manga.status');
  static const cover = LibraryFieldId<MangaKind, String?>('manga.cover');
  static const series = LibraryFieldId<MangaKind, String?>('manga.series');
  static const title = LibraryFieldId<MangaKind, String>('manga.title');
  static const volumeNumber =
      LibraryFieldId<MangaKind, String?>('manga.volume_number');
  static const publisher =
      LibraryFieldId<MangaKind, String?>('manga.publisher');
  static const releaseDate =
      LibraryFieldId<MangaKind, DateTime?>('manga.release_date');
  static const barcode = LibraryFieldId<MangaKind, String?>('manga.barcode');
  static const rating = LibraryFieldId<MangaKind, int?>('manga.rating');
  static const condition =
      LibraryFieldId<MangaKind, String?>('manga.condition');
  static const pricePaid = LibraryFieldId<MangaKind, int?>('manga.price_paid');
  static const location = LibraryFieldId<MangaKind, String?>('manga.location');
  static const wishlist = LibraryFieldId<MangaKind, bool>('manga.wishlist');
  static const updatedAt =
      LibraryFieldId<MangaKind, DateTime>('manga.updated_at');
  static const addedAt = LibraryFieldId<MangaKind, DateTime?>('manga.added_at');
  static const readStatus =
      LibraryFieldId<MangaKind, String?>('manga.read_status');

  // Rich Manga Metadata Fields
  static const nativeTitle =
      LibraryFieldId<MangaKind, String?>('manga.native_title');
  static const romajiTitle =
      LibraryFieldId<MangaKind, String?>('manga.romaji_title');
  static const englishTitle =
      LibraryFieldId<MangaKind, String?>('manga.english_title');
  static const authors =
      LibraryFieldId<MangaKind, List<String>>('manga.authors');
  static const artists =
      LibraryFieldId<MangaKind, List<String>>('manga.artists');
  static const demographic =
      LibraryFieldId<MangaKind, String?>('manga.demographic');
  static const serializationPlatform =
      LibraryFieldId<MangaKind, String?>('manga.serialization_platform');
  static const publicationStatus =
      LibraryFieldId<MangaKind, String?>('manga.publication_status');
  static const originalPublisher =
      LibraryFieldId<MangaKind, String?>('manga.original_publisher');
  static const localizedPublisher =
      LibraryFieldId<MangaKind, String?>('manga.localized_publisher');
  static const totalVolumes =
      LibraryFieldId<MangaKind, int?>('manga.total_volumes');
  static const chapterCount =
      LibraryFieldId<MangaKind, int?>('manga.chapter_count');
  static const editionFormat =
      LibraryFieldId<MangaKind, String?>('manga.edition_format');
  static const readingDirection =
      LibraryFieldId<MangaKind, String?>('manga.reading_direction');
  static const translator =
      LibraryFieldId<MangaKind, String?>('manga.translator');
  static const genres = LibraryFieldId<MangaKind, List<String>>('manga.genres');
  static const themes = LibraryFieldId<MangaKind, List<String>>('manga.themes');

  // Rich Manga Ownership Fields
  static const obiStripPresent =
      LibraryFieldId<MangaKind, bool>('manga.obi_strip_present');
  static const slipcoverPresent =
      LibraryFieldId<MangaKind, bool>('manga.slipcover_present');
  static const dustJacketPresent =
      LibraryFieldId<MangaKind, bool>('manga.dust_jacket_present');
  static const dustJacketCondition =
      LibraryFieldId<MangaKind, String?>('manga.dust_jacket_condition');
  static const boxSetOuterCondition =
      LibraryFieldId<MangaKind, String?>('manga.box_set_outer_condition');
  static const insertsPresent =
      LibraryFieldId<MangaKind, bool>('manga.inserts_present');
  static const printing = LibraryFieldId<MangaKind, String?>('manga.printing');
  static const localizedEdition =
      LibraryFieldId<MangaKind, String?>('manga.localized_edition');
  static const signedBy = LibraryFieldId<MangaKind, String?>('manga.signed_by');
}

abstract final class MangaSortIds {
  static const series = LibrarySortId<MangaKind>('manga.series');
  static const volumeNumber = LibrarySortId<MangaKind>('manga.volume_number');
  static const publisher = LibrarySortId<MangaKind>('manga.publisher');
  static const status = LibrarySortId<MangaKind>('manga.status');
  static const title = LibrarySortId<MangaKind>('manga.title');
  static const releaseDate = LibrarySortId<MangaKind>('manga.release_date');
  static const rating = LibrarySortId<MangaKind>('manga.rating');
  static const pricePaid = LibrarySortId<MangaKind>('manga.price_paid');
  static const updatedAt = LibrarySortId<MangaKind>('manga.updated_at');
  static const demographic = LibrarySortId<MangaKind>('manga.demographic');
  static const publicationStatus =
      LibrarySortId<MangaKind>('manga.publication_status');
  static const totalVolumes = LibrarySortId<MangaKind>('manga.total_volumes');
  static const editionFormat = LibrarySortId<MangaKind>('manga.edition_format');
}

abstract final class MangaGroupIds {
  static const series = LibraryGroupId<MangaKind, String?>('manga.series');
  static const publisher =
      LibraryGroupId<MangaKind, String?>('manga.publisher');
  static const location = LibraryGroupId<MangaKind, String?>(
    'manga.location',
    semantic: LibraryGroupSemantic.location,
  );
  static const condition =
      LibraryGroupId<MangaKind, String?>('manga.condition');
  static const rating = LibraryGroupId<MangaKind, int?>('manga.rating');
  static const demographic =
      LibraryGroupId<MangaKind, String?>('manga.demographic');
  static const publicationStatus =
      LibraryGroupId<MangaKind, String?>('manga.publication_status');
  static const editionFormat =
      LibraryGroupId<MangaKind, String?>('manga.edition_format');
  static const readingDirection =
      LibraryGroupId<MangaKind, String?>('manga.reading_direction');
  static const localizedPublisher =
      LibraryGroupId<MangaKind, String?>('manga.localized_publisher');
}

abstract final class MangaFacetIds {
  static const publisher = LibraryFacetId<MangaKind, String>('manga.publisher');
  static const genre = LibraryFacetId<MangaKind, String>('manga.genre');
  static const character = LibraryFacetId<MangaKind, String>('manga.character');
  static const theme = LibraryFacetId<MangaKind, String>('manga.theme');
  static const demographic =
      LibraryFacetId<MangaKind, String>('manga.demographic');
}
