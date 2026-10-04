import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Comic domain exposes a flat catalog item and entry state', () {
    const mediaId = ComicCatalogItemId('media-1');
    const sameMediaId = ComicCatalogItemId('media-1');
    const media = ComicCatalogItem(
      id: mediaId,
      title: 'Fixture Comic',
      issueNumber: '1',
    );
    const entryDetails = ComicEntryDetails();

    expect(media.mediaKind, CatalogMediaKind.comic);
    expect(media.toSyncPayload()['title'], 'Fixture Comic');
    expect(media.toSyncPayload()['id'], 'media-1');
    expect(mediaId, sameMediaId);
    expect(mediaId.toString(), 'media-1');
    expect(entryDetails, isA<ComicEntryDetails>());
  });

  test('ComicCatalogItem decodes its canonical domain payload', () {
    final media = ComicCatalogItem.fromJson({
      'id': 'media-2',
      'title': 'Decoded Comic',
    });

    expect(media, isA<ComicCatalogItem>());
    expect(media.id, const ComicCatalogItemId('media-2'));
    expect(media.title, 'Decoded Comic');
  });
}
