import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:io';
import 'package:collectarr_app/features/library/kinds/music/config/music_import_sources.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/import/catraxx_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/import/discogs_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/import/music_mapped_csv_importer.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest =
      jsonDecode(File('test/fixtures/imports/manifest.json').readAsStringSync())
          as Map<String, dynamic>;
  String fixture(Map<String, dynamic> entry, String name) =>
      File('test/fixtures/imports/${entry[name]}').readAsStringSync();
  for (final source in musicImportSources.where((s) => s.importer != null)) {
    final entry = manifest['music.${source.id}'] as Map<String, dynamic>;
    group('${source.id} external export', () {
      test('minimal fixture creates complete local albums with stable identity',
          () {
        final rows = source.importer!.parse(fixture(entry, 'minimal'));
        expect(rows, hasLength(2));
        expect(rows.first.title, 'After & Before');
        final record =
            LibraryEntryRecord.fromJson(rows.first.fullEntryPayload!);
        expect(record.sourceCatalogRef, isNull);
        final album = MusicAlbum.fromJson(record.catalogData);
        expect(album.discs, hasLength(2));
        expect(album.discs.first.format, 'CD');
        expect(record.personalData['collection_status'], 'In Collection');
        expect(
            source.importer!
                .parse(fixture(entry, 'minimal'))
                .map((r) => r.itemId),
            rows.map((r) => r.itemId));
        expect(rows.map((r) => r.itemId).toSet(), hasLength(2));
      });
      test('optional fields may be absent without invented metadata', () {
        final rows = source.importer!.parse(fixture(entry, 'optional'));
        expect(rows, hasLength(2));
        final album = MusicAlbum.fromJson(
            LibraryEntryRecord.fromJson(rows.first.fullEntryPayload!)
                .catalogData);
        expect(album.publisher, isNull);
        expect(album.releaseDateParts, isNull);
      });
      test('truncated exports fail with no partial or placeholder records', () {
        expect(() => source.importer!.parse(fixture(entry, 'invalid')),
            throwsA(isA<LibraryImportFormatException>()));
        expect(() => source.importer!.parse(''),
            throwsA(isA<LibraryImportFormatException>()));
        expect(
            () => source.importer!
                .parse('<unrelated><title>Not an album</title></unrelated>'),
            throwsA(isA<LibraryImportFormatException>()));
      });
      if (source.id != 'discogs') {
        test('XML values decode entities, quotes, Unicode and multiple genres',
            () {
          final row = source.importer!.parse(fixture(entry, 'minimal')).first;
          final record = LibraryEntryRecord.fromJson(row.fullEntryPayload!);
          expect(record.personalData['personal_notes'],
              'Fictional notes\nUnicode: \u015e\u00e9\u97f3 & "quotes"');
          expect(MusicAlbum.fromJson(record.catalogData).genres,
              ['Dream Pop', 'Jazz']);
          expect(record.personalData['price_paid_cents'], 1250);
          expect(
              record.personalData['purchase_date'], startsWith('2026-01-15'));
        });
      }
      if (source.id == 'clzweb' || source.id == 'musiccollector') {
        test(
            'contained track titles never become extra albums and credits stay scoped',
            () {
          final row = source.importer!.parse(fixture(entry, 'minimal')).first;
          final album = MusicAlbum.fromJson(
              LibraryEntryRecord.fromJson(row.fullEntryPayload!).catalogData);
          expect(album.discs.map((d) => d.tracks.length), [2, 2]);
          expect(album.discs.first.tracks.first.durationMs, 183000);
          expect(album.discs.first.tracks.first.composition, 'Fictional Work');
          expect(album.discs.first.recordingDate!.year, 2024);
          expect(album.discs.first.isLive, isTrue);
          expect(album.discs.first.soundTypes, ['Stereo']);
          expect(album.credits.map((c) => c.role),
              ['Composer', 'Producer', 'Musician']);
          expect(album.credits.last.instruments, ['Guitar']);
        });
      }
    });
  }
  group('CATraxx', () {
    const importer = CatraxxImporter();
    final raw = File('test/fixtures/imports/music/catraxx/minimal.xml')
        .readAsStringSync();
    (MusicAlbum, Map<String, dynamic>) first(String source) {
      final record = LibraryEntryRecord.fromJson(
          importer.parse(source).first.fullEntryPayload!);
      return (MusicAlbum.fromJson(record.catalogData), record.personalData);
    }

    test('counted formats, tracks, credits and the half-star rating map over',
        () {
      final (album, personal) = first(raw);
      expect(album.discs.map((d) => d.format), ['CD', 'CD']);
      expect(album.discs.map((d) => d.title),
          ['After & Before (Disc 1)', 'After & Before (Disc 2)']);
      expect(album.discs.map((d) => d.tracks.length), [2, 2]);
      expect(album.discs.first.tracks.first.position, '1');
      expect(album.discs.first.tracks.first.durationMs, 183000);
      expect(album.discs.first.isLive, isTrue);
      expect(album.publisher, 'Fictional Records');
      expect(album.releaseDateParts!.month, 4);
      expect(album.credits.single.role, 'Songwriter');
      expect(personal['rating'], 8);
      expect(personal['media_condition'], 'Near Mint');
      expect(personal['purchase_store'], 'Fictional Store');
      // CATraxx stores an unset value as 0.00.
      expect(personal['market_value_cents'], isNull);
    });

    test('vinyl sides become side positions', () {
      final sided = raw
          .replaceFirst('sides="1"', 'sides="2"')
          .replaceFirst('2CD', '2LP')
          .replaceFirst(
              '</side>\n\t\t\t</disc>',
              '</side>\n\t\t\t\t<side>\n\t\t\t\t\t<sideno>B</sideno>\n'
                  '\t\t\t\t\t<track id="99"><side>B</side><index>1</index>'
                  '<title>Flip</title></track>\n\t\t\t\t</side>\n\t\t\t</disc>');
      final (album, _) = first(sided);
      expect(album.discs.first.format, 'LP');
      expect(
          album.discs.first.tracks.map((t) => t.position), ['A1', 'A2', 'B1']);
    });

    test('other tables, unknown statuses and bad ratings are refused', () {
      for (final source in [
        raw.replaceAll('table="album"', 'table="track"'),
        raw.replaceFirst('>Own<', '>Borrowed<'),
        raw.replaceFirst('>4</personalrating>', '>4.2</personalrating>'),
      ]) {
        expect(() => importer.parse(source),
            throwsA(isA<LibraryImportFormatException>()));
      }
    });
  });
  for (final file in ['quoted_multiline.csv', 'unicode.csv']) {
    test('Discogs $file preserves quoted multiline and Unicode values', () {
      final row = const DiscogsImporter()
          .parse(File('test/fixtures/imports/music/discogs/$file')
              .readAsStringSync())
          .first;
      expect(
          (row.fullEntryPayload!['personal_data']
              as Map<String, dynamic>)['personal_notes'],
          'Line 1\nLine 2, with "quotes" & \u015e\u00e9\u97f3');
      expect(
          (row.fullEntryPayload!['personal_data']
              as Map<String, dynamic>)['rating'],
          8);
    });
  }
  test('Discogs rejects missing columns, empty titles and malformed quoting',
      () {
    for (final value in [
      'Title\nName',
      'Artist,Title,release_id\nArtist,,123',
      'Artist,Title,release_id\nArtist,Title,123,extra',
      'Artist,Title,release_id\nArtist,Bad"quote,123'
    ]) {
      expect(() => const DiscogsImporter().parse(value),
          throwsA(isA<LibraryImportFormatException>()));
    }
  });
  test(
      'external disc format families use explicit presets and reject unknown custom formats',
      () {
    final source = musicImportSources.singleWhere((s) => s.id == 'clzweb');
    final raw = File('test/fixtures/imports/music/clz_web/minimal.xml')
        .readAsStringSync();
    final row = source.importer!.parse(raw.replaceAll('>CD<', '>DVDr<')).first;
    final album = MusicAlbum.fromJson(
        LibraryEntryRecord.fromJson(row.fullEntryPayload!).catalogData);
    expect(album.discs.first.formatFamily!.name, 'opticalDisc');
    expect(
        () =>
            source.importer!.parse(raw.replaceAll('>CD<', '>Unknown-CD-ish<')),
        throwsA(isA<LibraryImportFormatException>()));
  });

  test('native disc and track identities survive reordered XML records', () {
    final source = musicImportSources.singleWhere((s) => s.id == 'clzweb');
    final raw = File('test/fixtures/imports/music/clz_web/minimal.xml')
        .readAsStringSync();
    final before = MusicAlbum.fromJson(LibraryEntryRecord.fromJson(
            source.importer!.parse(raw).first.fullEntryPayload!)
        .catalogData);
    final document = XmlDocument.parse(raw);
    final discs = document.findAllElements('discs').first;
    final elements = discs.findElements('disc').toList();
    for (final disc in elements) {
      final tracks = disc.getElement('tracks')!;
      final rows = tracks.findElements('track').toList();
      tracks.children.clear();
      tracks.children.addAll(rows.reversed);
    }
    discs.children.clear();
    discs.children.addAll(elements.reversed);
    final after = MusicAlbum.fromJson(LibraryEntryRecord.fromJson(source
            .importer!
            .parse(document.toXmlString())
            .first
            .fullEntryPayload!)
        .catalogData);
    expect({
      for (final disc in after.discs)
        for (final track in disc.tracks) track.title: track.id.value
    }, {
      for (final disc in before.discs)
        for (final track in disc.tracks) track.title: track.id.value
    });
    expect(after.discs.map((d) => d.id.value),
        before.discs.reversed.map((d) => d.id.value));
  });

  test('CLZ partial dates preserve an unknown year instead of inventing one',
      () {
    final source = musicImportSources.singleWhere((s) => s.id == 'clzweb');
    final raw = File('test/fixtures/imports/music/clz_web/minimal.xml')
        .readAsStringSync()
        .replaceAll('2025-04', '/09/22');
    final row = source.importer!.parse(raw).first;
    final album = MusicAlbum.fromJson(
        LibraryEntryRecord.fromJson(row.fullEntryPayload!).catalogData);
    expect(album.releaseDateParts!.year, isNull);
    expect(album.releaseDateParts!.month, 9);
    expect(album.releaseDateParts!.day, 22);
    expect(() => source.importer!.parse(raw.replaceAll('/09/22', '/02/31')),
        throwsA(isA<LibraryImportFormatException>()));
  });

  test(
      'mapped Music fields persist catalog and personal values rather than custom-field labels',
      () {
    final row = const MusicMappedCsvImporter().parse([
      [
        'Local Album',
        'Mira Example',
        '2025',
        'Dream Pop;Jazz',
        '12.50',
        'A note'
      ]
    ], mappings: {
      0: 'title',
      1: 'artist',
      2: 'release_year',
      3: 'genre',
      4: 'price_paid',
      5: 'notes'
    }, multiValueDelimiter: ';').single;
    final record = LibraryEntryRecord.fromJson(row.fullEntryPayload!);
    expect(record.catalogData['artist'], 'Mira Example');
    expect(record.catalogData['genres'], ['Dream Pop', 'Jazz']);
    expect(record.personalData['price_paid_cents'], 1250);
    expect(record.personalData['personal_notes'], 'A note');
    expect(row.customFieldValues, isEmpty);
    expect(
        () => const MusicMappedCsvImporter().parse([
              ['No title mapping']
            ], mappings: {
              0: 'artist'
            }, multiValueDelimiter: ';'),
        throwsA(isA<LibraryImportFormatException>()));
  });
}
