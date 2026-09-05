import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/comic_info/comic_info_export.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/comic_info/comic_info_xml.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('ComicInfo export is contributed from a typed Comic boundary', () {
    final previews = comicInfoExportPreviews([
      ShelfEntry(
        itemId: 'comic-1',
        catalogItem: testCatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Amazing Fantasy',
          itemNumber: '15',
          publisher: 'Marvel Comics',
          synopsis: 'A public synopsis',
          releaseDate: DateTime.utc(1962, 8, 10),
          releaseYear: 1962,
        ),
      ),
    ]);

    expect(previews, hasLength(1));
    expect(previews.single.id, 'comic.comic_info_xml');
    expect(previews.single.mimeType, 'application/xml');
    expect(previews.single.content, contains('<Number>15</Number>'));
    expect(previews.single.content,
        contains('<Publisher>Marvel Comics</Publisher>'));
  });

  test('ComicInfo XML serializes comic-owned metadata and personal state', () {
    final metadata = ComicCatalogMetadata(
      title: 'Amazing Fantasy',
      seriesTitle: 'Amazing Fantasy',
      issueNumber: '15',
      synopsis: 'A public synopsis',
      publisher: 'Marvel Comics',
      releaseDate: DateTime(1962, 8, 10),
      physicalFormatLabel: 'Softcover',
    );

    final xml = const ComicInfoXml().serialize(metadata);

    expect(xml, contains('<Title>Amazing Fantasy</Title>'));
    expect(xml, contains('<Series>Amazing Fantasy</Series>'));
    expect(xml, contains('<Number>15</Number>'));
    expect(xml, contains('<Publisher>Marvel Comics</Publisher>'));
    expect(xml, contains('<Format>Softcover</Format>'));
    expect(xml, contains('<Year>1962</Year>'));
  });

  test('ComicInfo XML splits canonical metadata from personal local state', () {
    const xml = '''
<ComicInfo>
  <Title>Spider-Man</Title>
  <Series>Amazing Spider-Man</Series>
  <Number>1</Number>
  <Summary>Public synopsis</Summary>
  <Publisher>Marvel</Publisher>
  <Year>1963</Year>
  <Notes>Signed by Stan Lee</Notes>
  <Tags>spider,key</Tags>
  <CommunityRating>4.5</CommunityRating>
  <StorageBox>Short Box 6</StorageBox>
</ComicInfo>
''';

    final split = const ComicInfoXml().splitForImport(xml);

    expect(split.canonical.title, 'Spider-Man');
    expect(split.canonical.seriesTitle, 'Amazing Spider-Man');
    expect(split.canonical.itemNumber, '1');
    expect(split.canonical.synopsis, 'Public synopsis');
    expect(split.canonical.publisher, 'Marvel');
    expect(split.canonical.releaseYear, 1963);
    expect(split.personal.notes, 'Signed by Stan Lee');
    expect(split.personal.tags, 'spider,key');
    expect(split.personal.rating, 9);
    expect(split.personal.localOnlyFields['StorageBox'], 'Short Box 6');
    expect(split.unknownFields['StorageBox'], 'Short Box 6');
  });
}
