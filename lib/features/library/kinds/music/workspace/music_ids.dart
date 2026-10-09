import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';

abstract final class MusicFieldIds {
  static const status = LibraryFieldId<MusicKind, String?>('music.status');
  static const cover = LibraryFieldId<MusicKind, String?>('music.cover');
  static const artist = LibraryFieldId<MusicKind, Iterable<String>>(
      MusicFieldIdentities.artistId);
  static const artistSummary = LibraryFieldId<MusicKind, String?>(
    MusicFieldIdentities.artistSummaryId,
  );
  static const title =
      LibraryFieldId<MusicKind, String>(MusicFieldIdentities.titleId);
  static const publisher =
      LibraryFieldId<MusicKind, String?>(MusicFieldIdentities.publisherId);
  static const genre =
      LibraryFieldId<MusicKind, Iterable<String>>(MusicFieldIdentities.genreId);
  static const formatSummary = LibraryFieldId<MusicKind, String?>(
    MusicFieldIdentities.formatSummaryId,
  );
  static const discFormat = LibraryFieldId<MusicKind, Iterable<String>>(
    MusicFieldIdentities.discFormatId,
  );
  static const discFormatFamily =
      LibraryFieldId<MusicKind, Iterable<String>>('music.disc.format_family');
  static const recordingDate = LibraryFieldId<MusicKind, Iterable<PartialDate>>(
    'music.disc.recording_date',
  );
  static const recordingMonth =
      LibraryFieldId<MusicKind, Iterable<int>>('music.disc.recording_month');
  static const recordingYear =
      LibraryFieldId<MusicKind, Iterable<int>>('music.disc.recording_year');
  static const earliestDiscRecordingDate =
      LibraryFieldId<MusicKind, PartialDate?>(
    'music.disc.recording_date.earliest',
  );
  static const latestDiscRecordingDate =
      LibraryFieldId<MusicKind, PartialDate?>(
    'music.disc.recording_date.latest',
  );
  static const liveStudio =
      LibraryFieldId<MusicKind, Iterable<bool>>('music.disc.is_live');
  static const recordingLocation = LibraryFieldId<MusicKind, Iterable<String>>(
    'music.recording_location',
  );
  static const discSpars =
      LibraryFieldId<MusicKind, Iterable<String>>('music.disc.spars');
  static const discSound =
      LibraryFieldId<MusicKind, Iterable<String>>('music.sound');
  static const discColor =
      LibraryFieldId<MusicKind, Iterable<String>>('music.vinyl_color');
  static const discRpm =
      LibraryFieldId<MusicKind, Iterable<String>>('music.rpm');
  static const creditContributor =
      LibraryFieldId<MusicKind, Iterable<String>>('music.credit.contributor');
  static const creditRole =
      LibraryFieldId<MusicKind, Iterable<String>>('music.credit.role');
  static const creditInstrument =
      LibraryFieldId<MusicKind, Iterable<String>>('music.credit.instrument');
  static const trackComposition =
      LibraryFieldId<MusicKind, Iterable<String>>('music.track.composition');
  static const packaging =
      LibraryFieldId<MusicKind, String?>(MusicFieldIdentities.packagingId);
  static const boxSet =
      LibraryFieldId<MusicKind, String?>(MusicFieldIdentities.boxSetId);
  static const releaseDate = LibraryFieldId<MusicKind, DateTime?>(
    MusicFieldIdentities.releaseDateId,
  );
  static const trackCount = LibraryFieldId<MusicKind, int?>(
    'music.track_count',
  );
  static const barcode =
      LibraryFieldId<MusicKind, String?>(MusicFieldIdentities.barcodeId);
  static const rating = LibraryFieldId<MusicKind, int?>('music.rating');
  static const condition =
      LibraryFieldId<MusicKind, String?>('music.condition');
  static const pricePaid = LibraryFieldId<MusicKind, int?>('music.price_paid');
  static const location = LibraryFieldId<MusicKind, String?>('music.location');
  static const wishlist = LibraryFieldId<MusicKind, bool>('music.wishlist');
  static const updatedAt =
      LibraryFieldId<MusicKind, DateTime>('music.updated_at');
  static const addedAt = LibraryFieldId<MusicKind, DateTime?>('music.added_at');

  // Rich Music Metadata Fields
  static const catalogNumber =
      LibraryFieldId<MusicKind, String?>(MusicFieldIdentities.catalogNumberId);
  static const country =
      LibraryFieldId<MusicKind, String?>(MusicFieldIdentities.countryId);
  static const discCount = LibraryFieldId<MusicKind, int?>('music.disc_count');
  static const signedBy = LibraryFieldId<MusicKind, String?>('music.signed_by');
  static const grade = LibraryFieldId<MusicKind, String?>('music.grade');
  static const storageSummary =
      LibraryFieldId<MusicKind, String?>('music.storage_summary');
  static const storageDevice =
      LibraryFieldId<MusicKind, Iterable<String>>('music.storage_device');
  static const storageSlot =
      LibraryFieldId<MusicKind, Iterable<String>>('music.storage_slot');
  static const purchaseDate =
      LibraryFieldId<MusicKind, DateTime?>('music.purchase_date');
  static const marketValue =
      LibraryFieldId<MusicKind, int?>('music.market_value');
  static const indexNumber =
      LibraryFieldId<MusicKind, int?>('music.index_number');
  static const lastCleaned =
      LibraryFieldId<MusicKind, DateTime?>('music.last_cleaned');
  static const listenCount =
      LibraryFieldId<MusicKind, int?>('music.listen_count');
  static const lastListened =
      LibraryFieldId<MusicKind, DateTime?>('music.last_listened');
}

abstract final class MusicSortIds {
  static const status = LibrarySortId<MusicKind>('music.status');
  static const artistSummary =
      LibrarySortId<MusicKind>(MusicFieldIdentities.artistSummaryId);
  static const title = LibrarySortId<MusicKind>(MusicFieldIdentities.titleId);
  static const publisher =
      LibrarySortId<MusicKind>(MusicFieldIdentities.publisherId);
  static const releaseDate =
      LibrarySortId<MusicKind>(MusicFieldIdentities.releaseDateId);
  static const trackCount = LibrarySortId<MusicKind>('music.track_count');
  static const rating = LibrarySortId<MusicKind>('music.rating');
  static const pricePaid = LibrarySortId<MusicKind>('music.price_paid');
  static const updatedAt = LibrarySortId<MusicKind>('music.updated_at');
  static const discCount = LibrarySortId<MusicKind>('music.disc_count');
  static const listenCount = LibrarySortId<MusicKind>('music.listen_count');
  static const lastListened = LibrarySortId<MusicKind>('music.last_listened');
  static const earliestDiscRecordingDate = LibrarySortId<MusicKind>(
    'music.disc.recording_date.earliest',
  );
  static const latestDiscRecordingDate = LibrarySortId<MusicKind>(
    'music.disc.recording_date.latest',
  );
}

abstract final class MusicGroupIds {
  static const artist =
      LibraryGroupId<MusicKind, Object?>(MusicFieldIdentities.artistId);
  static const publisher =
      LibraryGroupId<MusicKind, String?>(MusicFieldIdentities.publisherId);
  static const genre =
      LibraryGroupId<MusicKind, Object?>(MusicFieldIdentities.genreId);
  static const discFormat =
      LibraryGroupId<MusicKind, Object?>(MusicFieldIdentities.discFormatId);
  static const location = LibraryGroupId<MusicKind, String?>(
    'music.location',
    semantic: LibraryGroupSemantic.location,
  );
  static const condition =
      LibraryGroupId<MusicKind, String?>('music.condition');
  static const rating = LibraryGroupId<MusicKind, int?>('music.rating');
  static const country =
      LibraryGroupId<MusicKind, String?>(MusicFieldIdentities.countryId);
  static const boxSet =
      LibraryGroupId<MusicKind, String?>(MusicFieldIdentities.boxSetId);
}

abstract final class MusicFacetIds {
  static const artist =
      LibraryFacetId<MusicKind, String>(MusicFieldIdentities.artistId);
  static const publisher =
      LibraryFacetId<MusicKind, String>(MusicFieldIdentities.publisherId);
  static const genre =
      LibraryFacetId<MusicKind, String>(MusicFieldIdentities.genreId);
  static const discFormat =
      LibraryFacetId<MusicKind, String>(MusicFieldIdentities.discFormatId);
  static const country =
      LibraryFacetId<MusicKind, String>(MusicFieldIdentities.countryId);
}
