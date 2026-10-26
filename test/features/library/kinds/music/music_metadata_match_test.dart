import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_kind_configuration.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/builders/workspace_item_builder.dart';

void main() {
  test('high Music score requires title, artist and exact barcode', () {
    final source = testLibraryWorkspaceContext(
        kind: 'music',
        catalogData: MusicWorkspaceData(
            music: MusicAlbum(
                title: 'After the Rain',
                artist: 'The Paper Moons',
                barcode: '12345')));
    CatalogSearchCandidate remote(
            {String title = 'After the Rain',
            String? artist = 'The Paper Moons',
            String? barcode}) =>
        CatalogSearchCandidate.fromItem(MusicCatalogMapper.toCatalogItemDto(
            MusicAlbum(title: title, artist: artist, barcode: barcode),
            ref: const CatalogItemRef(
                kind: CatalogMediaKind.music, id: 'remote')));
    expect(musicMetadataMatchScore(source, remote(barcode: '12345')),
        LibraryMetadataMatchScore.high);
    expect(musicMetadataMatchScore(source, remote()),
        LibraryMetadataMatchScore.medium);
    expect(
        musicMetadataMatchScore(
            source, remote(artist: 'Other', barcode: '12345')),
        LibraryMetadataMatchScore.low);
    expect(
        musicMetadataMatchScore(
            source, remote(title: 'Other', barcode: '12345')),
        LibraryMetadataMatchScore.low);
  });
}
