import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Comic domain exposes typed media, release, ownership, and IDs', () {
    const mediaId = ComicMediaId('media-1');
    const sameMediaId = ComicMediaId('media-1');
    const releaseId = ComicReleaseId('release-1');
    const sameReleaseId = ComicReleaseId('release-1');
    const media = ComicMedia(
      id: mediaId,
      title: 'Fixture Comic',
      issueNumber: '1',
    );
    const release = ComicRelease(
      id: 'release-1',
      title: 'Fixture Release',
    );
    const ownedDetails = ComicOwnedDetails();

    expect(media.mediaKind, CatalogMediaKind.comic);
    expect(media.toSyncPayload()['title'], 'Fixture Comic');
    expect(media.toSyncPayload()['id'], 'media-1');
    expect(mediaId, sameMediaId);
    expect(releaseId, sameReleaseId);
    expect(mediaId.toString(), 'media-1');
    expect(releaseId.toString(), 'release-1');
    expect(release.typedId, releaseId);
    expect(ownedDetails, isA<ComicOwnedDetails>());
  });

  test('ComicMedia decodes its canonical domain payload', () {
    final media = ComicMedia.fromJson({
      'id': 'media-2',
      'title': 'Decoded Comic',
    });

    expect(media, isA<ComicMedia>());
    expect(media.id, const ComicMediaId('media-2'));
    expect(media.title, 'Decoded Comic');
  });
}
