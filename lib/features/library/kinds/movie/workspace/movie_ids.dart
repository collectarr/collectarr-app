import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_field_identities.dart';

abstract final class MovieFieldIds {
  static const status = LibraryFieldId<MovieKind, String?>('movie.status');
  static const cover = LibraryFieldId<MovieKind, String?>('movie.cover');
  static const title =
      LibraryFieldId<MovieKind, String>(MovieFieldIdentities.titleId);
  static const director = LibraryFieldId<MovieKind, String?>('movie.director');
  static const studio = LibraryFieldId<MovieKind, String?>('movie.studio');
  static const publisher =
      LibraryFieldId<MovieKind, String?>('movie.publisher');
  static const releaseDate =
      LibraryFieldId<MovieKind, DateTime?>(MovieFieldIdentities.releaseDateId);
  static const releaseYear =
      LibraryFieldId<MovieKind, int?>('movie.release_year');
  static const runtimeMinutes =
      LibraryFieldId<MovieKind, int?>(MovieFieldIdentities.runtimeMinutesId);
  static const format =
      LibraryFieldId<MovieKind, String?>(MovieFieldIdentities.formatId);
  static const barcode =
      LibraryFieldId<MovieKind, String?>(MovieFieldIdentities.barcodeId);
  static const rating = LibraryFieldId<MovieKind, int?>('movie.rating');
  static const condition =
      LibraryFieldId<MovieKind, String?>('movie.condition');
  static const pricePaid = LibraryFieldId<MovieKind, int?>('movie.price_paid');
  static const location = LibraryFieldId<MovieKind, String?>('movie.location');
  static const wishlist = LibraryFieldId<MovieKind, bool>('movie.wishlist');
  static const updatedAt =
      LibraryFieldId<MovieKind, DateTime>('movie.updated_at');
  static const addedAt = LibraryFieldId<MovieKind, DateTime?>('movie.added_at');
  static const watchStatus =
      LibraryFieldId<MovieKind, String?>('movie.watch_status');
  static const editionLabel =
      LibraryFieldId<MovieKind, String?>('movie.edition_label');
  static const genre =
      LibraryFieldId<MovieKind, String?>(MovieFieldIdentities.genreId);
  static const audienceRating =
      LibraryFieldId<MovieKind, String?>(MovieFieldIdentities.audienceRatingId);
  static const movieOrTvSeries =
      LibraryFieldId<MovieKind, String?>('movie.movie_or_tv_series');
  static const edition = LibraryFieldId<MovieKind, String?>('movie.edition');
  static const audioTracks =
      LibraryFieldId<MovieKind, String?>('movie.audio_tracks');
  static const editionReleaseDate =
      LibraryFieldId<MovieKind, DateTime?>('movie.edition_release_date');

  // Rich Movie Metadata Fields
  static const originalTitle =
      LibraryFieldId<MovieKind, String?>(MovieFieldIdentities.originalTitleId);
  static const writer = LibraryFieldId<MovieKind, String?>('movie.writer');
  static const producer = LibraryFieldId<MovieKind, String?>('movie.producer');
  static const ageRating =
      LibraryFieldId<MovieKind, String?>(MovieFieldIdentities.ageRatingId);
}

abstract final class MovieSortIds {
  static const status = LibrarySortId<MovieKind>('movie.status');
  static const title = LibrarySortId<MovieKind>(MovieFieldIdentities.titleId);
  static const releaseTitle = LibrarySortId<MovieKind>('movie.release_title');
  static const director = LibrarySortId<MovieKind>('movie.director');
  static const publisher = LibrarySortId<MovieKind>('movie.publisher');
  static const releaseDate =
      LibrarySortId<MovieKind>(MovieFieldIdentities.releaseDateId);
  static const releaseYear = LibrarySortId<MovieKind>('movie.release_year');
  static const runtimeMinutes =
      LibrarySortId<MovieKind>(MovieFieldIdentities.runtimeMinutesId);
  static const rating = LibrarySortId<MovieKind>('movie.rating');
  static const pricePaid = LibrarySortId<MovieKind>('movie.price_paid');
  static const updatedAt = LibrarySortId<MovieKind>('movie.updated_at');
}

abstract final class MovieGroupIds {
  static const director = LibraryGroupId<MovieKind, String?>('movie.director');
  static const publisher =
      LibraryGroupId<MovieKind, String?>('movie.publisher');
  static const format =
      LibraryGroupId<MovieKind, String?>(MovieFieldIdentities.formatId);
  static const genre =
      LibraryGroupId<MovieKind, String?>(MovieFieldIdentities.genreId);
  static const releaseYear =
      LibraryGroupId<MovieKind, int?>('movie.release_year');
  static const location = LibraryGroupId<MovieKind, String?>(
    'movie.location',
    semantic: LibraryGroupSemantic.location,
  );
  static const condition =
      LibraryGroupId<MovieKind, String?>('movie.condition');
  static const rating = LibraryGroupId<MovieKind, int?>('movie.rating');
  static const watchStatus =
      LibraryGroupId<MovieKind, String?>('movie.watch_status');
  static const ageRating =
      LibraryGroupId<MovieKind, String?>(MovieFieldIdentities.ageRatingId);
  static const audienceRating =
      LibraryGroupId<MovieKind, String?>(MovieFieldIdentities.audienceRatingId);
  static const movieOrTvSeries =
      LibraryGroupId<MovieKind, String?>('movie.movie_or_tv_series');
  static const audioTracks =
      LibraryGroupId<MovieKind, String?>('movie.audio_tracks');
  static const editionReleaseDate =
      LibraryGroupId<MovieKind, DateTime?>('movie.edition_release_date');
}

abstract final class MovieFacetIds {
  static const director = LibraryFacetId<MovieKind, String>('movie.director');
  static const publisher = LibraryFacetId<MovieKind, String>('movie.publisher');
  static const genre =
      LibraryFacetId<MovieKind, String>(MovieFieldIdentities.genreId);
  static const format =
      LibraryFacetId<MovieKind, String>(MovieFieldIdentities.formatId);
  static const studio = LibraryFacetId<MovieKind, String>('movie.studio');
}
