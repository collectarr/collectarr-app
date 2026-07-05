import 'package:collectarr_app/features/collection/cbz/comic_info_xml.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
