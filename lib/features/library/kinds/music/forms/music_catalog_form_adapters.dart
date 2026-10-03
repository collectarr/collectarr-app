import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';

abstract final class MusicAlbumFormAdapter {
  static MusicAlbum create(
    MusicAlbumFormValues values, {
    required MusicAlbumId id,
    List<MusicDisc> discs = const [],
  }) =>
      MusicAlbum(
        id: id,
        title: values.title.trim(),
        sortTitle: _text(values.sortTitle),
        subtitle: _text(values.subtitle),
        artist: _text(values.artist),
        artistCredits: List.unmodifiable(values.artistCredits),
        originalReleaseDateParts: values.originalReleaseDateParts,
        recordingDateParts: values.recordingDateParts,
        studios: List.unmodifiable(values.studios),
        isLive: values.isLive,
        genres: List.unmodifiable(values.genres),
        releaseDateParts: values.releaseDateParts,
        publisher: _text(values.publisher),
        countryCode: _text(values.countryCode),
        barcode: _text(values.barcode),
        catalogNumber: _text(values.catalogNumber),
        packaging: _text(values.packaging),
        format: _formFormat(values),
        soundTypes: List.unmodifiable(values.soundTypes),
        vinylColor: _text(values.vinylColor),
        vinylWeight: _text(values.vinylWeight),
        rpm: values.rpm,
        spars: _text(values.spars),
        extra: _text(values.extra),
        boxSet: _text(values.boxSet),
        coverImageUrl: _text(values.coverImageUrl),
        backCoverImageUrl: _text(values.backCoverImageUrl),
        discs: List.unmodifiable(discs),
      );

  static MusicAlbum update(
    MusicAlbum original,
    MusicAlbumFormValues values, {
    List<MusicDisc>? discs,
    List<MusicExternalLink>? externalLinks,
    List<MusicAlbumContribution>? contributions,
  }) =>
      MusicAlbum(
        id: original.id,
        title: values.title.trim(),
        sortTitle: _text(values.sortTitle),
        subtitle: _text(values.subtitle),
        artist: _text(values.artist),
        originalReleaseDateParts: values.originalReleaseDateParts,
        recordingDateParts: values.recordingDateParts,
        studios: List.unmodifiable(values.studios),
        isLive: values.isLive,
        genres: List.unmodifiable(values.genres),
        releaseDateParts: values.releaseDateParts,
        publisher: _text(values.publisher),
        countryCode: _text(values.countryCode),
        barcode: _text(values.barcode),
        catalogNumber: _text(values.catalogNumber),
        packaging: _text(values.packaging),
        format: _formFormat(values),
        boxSet: _text(values.boxSet),
        coverImageUrl: _text(values.coverImageUrl),
        coverImageKey: original.coverImageKey,
        backCoverImageUrl: _text(values.backCoverImageUrl),
        thumbnailImageUrl: original.thumbnailImageUrl,
        localCoverImagePath: original.localCoverImagePath,
        localBackImagePath: original.localBackImagePath,
        localThumbnailImagePath: original.localThumbnailImagePath,
        soundTypes: List.unmodifiable(values.soundTypes),
        vinylColor: _text(values.vinylColor),
        vinylWeight: _text(values.vinylWeight),
        rpm: values.rpm,
        spars: _text(values.spars),
        extra: _text(values.extra),
        externalLinks:
            List.unmodifiable(externalLinks ?? original.externalLinks),
        revision: original.revision,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
        contributions:
            List.unmodifiable(contributions ?? original.contributions),
        artistCredits: List.unmodifiable(values.artistCredits),
        discs: List.unmodifiable(discs ?? original.discs),
      );
}

String? _formFormat(MusicAlbumFormValues values) => _text(values.format);

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
