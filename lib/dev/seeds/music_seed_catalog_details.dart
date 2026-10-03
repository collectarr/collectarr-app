import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';

/// Seed-only Music child data for the legacy workspace fixture boundary.
///
/// Production Music transport is entry by the Music kind and uses its flat
/// Catalog Item DTO. This helper exists only to keep the development seed
/// declarations compact while they are converted to the flat child shape.
class MusicSeedCatalogDetails {
  const MusicSeedCatalogDetails({
    this.trackCount,
    this.tracks = const [],
    this.discs = const [],
    this.catalogNumber,
    this.releaseStatus,
  });

  final int? trackCount;
  final List<CatalogTrackDto> tracks;
  final List<CatalogDiscDto> discs;
  final String? catalogNumber;
  final String? releaseStatus;

  Map<String, dynamic> toJson() => {
        if (trackCount != null) 'track_count': trackCount,
        if (tracks.isNotEmpty) 'tracks': tracks.map((e) => e.toJson()).toList(),
        if (discs.isNotEmpty) 'discs': discs.map((e) => e.toJson()).toList(),
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (releaseStatus != null) 'release_status': releaseStatus,
      };
}
