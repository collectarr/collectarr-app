import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';

/// Catalog fields consumed by the Music kind.
final class MusicCatalogFields {
  const MusicCatalogFields._(this._candidate, this._metadata);

  final CatalogSearchCandidate _candidate;
  final MusicAlbum? _metadata;

  MusicAlbum? get metadata => _metadata;
  String get title => _metadata?.title ?? _candidate.summary.primaryLabel;
  String? get titleExtension => _metadata?.subtitle;
  List<String> get searchAliases => const [];
  String? get sortKey => _metadata?.sortTitle;
  String? get coverImageUrl =>
      _metadata?.coverImageUrl ?? _candidate.summary.imageUrl;
  String? get thumbnailImageUrl => _metadata?.thumbnailImageUrl;
  DateTime? get releaseDate => _metadata?.releaseDate;
  int? get releaseYear => _metadata?.releaseDateParts?.year;

  bool get hasReleaseDate => releaseDate != null || releaseYear != null;
}

extension MusicCatalogCandidateFields on CatalogSearchCandidate {
  MusicCatalogFields get musicCatalogFields {
    try {
      final item = kindCapability.mapTransport((item) => item);
      return MusicCatalogFields._(
        this,
        MusicCatalogMapper.mapMetadataItemToMusic(item),
      );
    } on StateError {
      return MusicCatalogFields._(this, null);
    }
  }
}
