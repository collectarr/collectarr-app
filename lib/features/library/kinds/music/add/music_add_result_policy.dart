import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';

/// Core search already returns concrete Music catalog entries, so grouping
/// presentation is derived only from the item data stored in Core.
final musicAddResultPolicy = LibraryAddResultPolicy(
  coreGroupTitleBuilder: _musicCoreGroupTitle,
  coreGroupArtistBuilder: _musicCoreGroupArtist,
);

String _musicCoreGroupTitle(CatalogSearchCandidate item) {
  final album = item.kindCapability
      .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  final title = album.title.trim();
  return title.isEmpty ? item.summary.primaryLabel : title;
}

String? _musicCoreGroupArtist(CatalogSearchCandidate item) {
  final album = item.kindCapability
      .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  return album.artist;
}
