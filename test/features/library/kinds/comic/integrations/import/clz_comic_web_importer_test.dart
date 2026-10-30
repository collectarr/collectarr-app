import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/import/clz_comic_web_importer.dart';
import 'package:flutter_test/flutter_test.dart';

// Shaped like a CLZ Comics Web "Export to XML" file, with fictional values.
const _export = '''<?xml version="1.0" encoding="utf-8" ?>
<collectorz><meta><scope>export</scope></meta><data><comicinfo><comiclist>
<comic>
  <hash>fixture-1</hash>
  <mainsection>
    <title>Fixture Title</title>
    <series><displayname>Fixture Series</displayname></series>
    <plot>A fixture plot.</plot>
    <pagecount>32</pagecount>
    <myrating>8</myrating>
    <notes>Fixture notes</notes>
  </mainsection>
  <issuenr>2</issuenr>
  <issueext>A</issueext>
  <edition><displayname>Fixture Variant</displayname></edition>
  <publisher><displayname>Fixture Comics</displayname></publisher>
  <coverdate><year><displayname>2025</displayname></year><month>01</month><date>2025/01</date></coverdate>
  <releasedate><year><displayname>2024</displayname></year><month>11</month><day>13</day><date>2024/11/13</date></releasedate>
  <addeddate><timestamp>1780188904</timestamp></addeddate>
  <barcode>761941000000</barcode>
  <format><displayname>Comic</displayname></format>
  <quantity>1</quantity>
  <collectionstatus listid="3">In Collection</collectionstatus>
  <storyarc><displayname>Fixture Arc</displayname></storyarc>
  <age><displayname>Modern</displayname></age>
  <currentprice>0</currentprice>
  <coverprice>4.99</coverprice>
  <readit boolvalue="1">Yes</readit>
  <collection><displayname>comic</displayname><hash>CLZ-0000</hash></collection>
  <iskeycomic listid="2">Major</iskeycomic>
  <keycomicreason>1st fixture appearance</keycomicreason>
  <grade><id>27</id><rating>10.0</rating><displayname>10.0 Gem Mint</displayname></grade>
  <isslabbed boolvalue="1">Slabbed</isslabbed>
  <signees><signee><displayname>Fixture Signee</displayname></signee></signees>
  <genres><genre><displayname>Action</displayname></genre></genres>
  <keycategories><keycategory><displayname>First Appearance</displayname></keycategory></keycategories>
  <credits><credit><person><displayname>Fixture Writer</displayname></person><roleid>dfEditorInChief</roleid><sequence>1</sequence></credit></credits>
  <characters><character><name>Fixture Hero</name></character></characters>
</comic>
<comic>
  <hash>fixture-2</hash>
  <mainsection><series><displayname>Fixture Series</displayname></series></mainsection>
  <issueext>TP-1</issueext>
  <iskeycomic listid="0">No</iskeycomic>
  <grade><id>0</id><rating>0.0</rating></grade>
  <readit boolvalue="0">No</readit>
</comic>
</comiclist></comicinfo></data></collectorz>''';

void main() {
  const importer = ClzComicWebImporter();

  test('reads a CLZ Comics Web export', () {
    final rows = importer.parse(_export);
    expect(rows.map((row) => row.kindDisplayTitle),
        ['Fixture Series #2A', 'Fixture Series #TP-1']);
    expect(rows.map((row) => row.kindDisplaySubtitle), ['Fixture Title', null]);

    final record = rows.first.fullEntryPayload!;
    final catalog = record['catalog_data'] as Map;
    final personal = record['personal_data'] as Map;
    expect(catalog['series_title'], 'Fixture Series');
    expect(catalog['title'], 'Fixture Title');
    expect(catalog['issue_number'], '2');
    expect(catalog['variant'], 'A');
    expect(catalog['variant_description'], 'Fixture Variant');
    expect(catalog['cover_date'], {'year': 2025, 'month': 1});
    expect(
        catalog['release_date_parts'], {'year': 2024, 'month': 11, 'day': 13});
    expect(catalog['story_arcs'], ['Fixture Arc']);
    expect(catalog['description'], 'A fixture plot.');
    expect(catalog['creators'], [
      {'name': 'Fixture Writer', 'role': 'Editor in Chief', 'sequence': 1}
    ]);
    expect(catalog['characters'], ['Fixture Hero']);
    expect(personal['grade'], '10.0 Gem Mint');
    expect(personal['raw_or_slabbed'], 'Slabbed');
    expect(personal['signed_by'], 'Fixture Signee');
    expect(personal['key_severity'], 'Major');
    expect(personal['key_category'], 'First Appearance');
    expect(personal['cover_price_cents'], 499);
    expect(personal['market_value_cents'], isNull);
    expect(personal['personal_notes'], 'Fixture notes');
    expect(personal['reading'], {'rating': 8, 'status': 'Read'});

    final second = rows.last.fullEntryPayload!;
    expect((second['catalog_data'] as Map)['title'], '');
    expect((second['personal_data'] as Map)['key_comic'], false);
    expect((second['personal_data'] as Map)['grade'], isNull);
  });

  test('rejects another inventory', () {
    expect(
        () => importer.parse('<collectorz><data><gameinfo><gamelist>'
            '<game/></gamelist></gameinfo></data></collectorz>'),
        throwsA(isA<LibraryImportFormatException>()));
  });
}
