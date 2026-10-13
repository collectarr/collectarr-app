import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';

abstract final class MusicAlbumFormAdapter {
  static MusicAlbum create(
    MusicAlbumFormValues values, {
    required CatalogItemRef id,
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
        genres: List.unmodifiable(values.genres),
        releaseDateParts: values.releaseDateParts,
        publisher: _text(values.publisher),
        countryCode: _text(values.countryCode),
        barcode: _text(values.barcode),
        catalogNumber: _text(values.catalogNumber),
        packaging: _text(values.packaging),
        extra: List.unmodifiable(values.extra),
        boxSet: _text(values.boxSet),
        coverImageUrl: _text(values.coverImageUrl),
        backCoverImageUrl: _text(values.backCoverImageUrl),
        credits: List.unmodifiable(values.credits),
        discs: List.unmodifiable(discs),
      );

  static MusicAlbum update(
    MusicAlbum original,
    MusicAlbumFormValues values, {
    List<MusicDisc>? discs,
    List<MusicExternalLink>? externalLinks,
    List<MusicCredit>? credits,
  }) =>
      MusicAlbum(
        id: original.id,
        title: values.title.trim(),
        sortTitle: _text(values.sortTitle),
        subtitle: _text(values.subtitle),
        artist: _text(values.artist),
        originalReleaseDateParts: values.originalReleaseDateParts,
        genres: List.unmodifiable(values.genres),
        releaseDateParts: values.releaseDateParts,
        publisher: _text(values.publisher),
        countryCode: _text(values.countryCode),
        barcode: _text(values.barcode),
        catalogNumber: _text(values.catalogNumber),
        packaging: _text(values.packaging),
        boxSet: _text(values.boxSet),
        coverImageUrl: _text(values.coverImageUrl),
        coverImageKey: original.coverImageKey,
        backCoverImageUrl: _text(values.backCoverImageUrl),
        thumbnailImageUrl: original.thumbnailImageUrl,
        localCoverImagePath: original.localCoverImagePath,
        localBackImagePath: original.localBackImagePath,
        localThumbnailImagePath: original.localThumbnailImagePath,
        extra: List.unmodifiable(values.extra),
        externalLinks:
            List.unmodifiable(externalLinks ?? original.externalLinks),
        revision: original.revision,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
        credits: List.unmodifiable(credits ?? values.credits),
        artistCredits: List.unmodifiable(values.artistCredits),
        discs: List.unmodifiable(discs ?? original.discs),
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
