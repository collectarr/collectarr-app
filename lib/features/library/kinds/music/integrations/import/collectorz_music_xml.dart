import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_artist_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:xml/xml.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'music_import_row.dart';

/// Shared external Music Collector XML vocabulary, with explicit Web/Desktop
/// record paths. It never scans nested track titles as album records.
List<CollectionImportRow> parseCollectorzMusicXml(String source,
    {required bool web}) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(
        source.replaceAll('\r\n', '\n').replaceAll('\r', '\n'));
  } on XmlException catch (error) {
    throw LibraryImportFormatException('Malformed XML: ${error.message}');
  }
  final root = document.rootElement;
  if (root.name.local != (web ? 'collectorz' : 'musicinfo')) {
    throw LibraryImportFormatException(
        'Expected ${web ? 'CLZ Music Web' : 'Music Collector'} XML, not <${root.name.local}>.');
  }
  final records =
      xmlMusicPath(root, web ? 'data/musicinfo/musiclist' : 'musiclist')
              ?.findElements('music')
              .toList() ??
          <XmlElement>[];
  if (records.isEmpty) {
    throw const LibraryImportFormatException(
        'No album records found in the musiclist export.');
  }
  final copies = <String, int>{};
  final result = <CollectionImportRow>[];
  for (final record in records) {
    final title = xmlMusicValue(record, 'title') ?? '';
    final artists = xmlMusicValues(record, 'artists', 'artist');
    final externalId = xmlMusicValue(record, 'id') ??
        xmlMusicValue(record, 'hash') ??
        '$title/${artists.join('/')}';
    final copy =
        copies.update(externalId, (value) => value + 1, ifAbsent: () => 1);
    final id =
        musicImportId(web ? 'clzweb' : 'musiccollector', '$externalId/$copy');
    final format = xmlMusicValue(record, 'format');
    final rawDiscs = web
        ? xmlMusicPath(record, 'discs')?.findElements('disc').toList() ??
            <XmlElement>[]
        : xmlMusicPath(record, 'details')
                ?.findElements('detail')
                .where((e) => e.getAttribute('type') == 'disc')
                .toList() ??
            <XmlElement>[];
    final discs = <MusicDisc>[];
    final discCount = rawDiscs.isNotEmpty
        ? rawDiscs.length
        : musicImportInt(xmlMusicValue(record, 'nrdiscs'), 'disc count',
                max: 100) ??
            (format == null ? 0 : 1);
    if (discCount > 100) {
      throw const LibraryImportFormatException('An album exceeds 100 discs.');
    }
    for (var index = 0; index < discCount; index++) {
      final raw = index < rawDiscs.length ? rawDiscs[index] : null;
      final discNumber = index + 1;
      final externalDiscId = xmlMusicValue(raw, 'hash') ??
          xmlMusicValue(raw, 'bpdiscid') ??
          xmlMusicValue(raw, 'id') ??
          '$discNumber';
      final discId = musicImportId(id, 'disc/$externalDiscId');
      final discFormat = xmlMusicValue(raw, 'format') ?? format;
      final tracks = raw == null
          ? <XmlElement>[]
          : web
              ? xmlMusicPath(raw, 'tracks')?.findElements('track').toList() ??
                  <XmlElement>[]
              : xmlMusicPath(raw, 'details')
                      ?.findElements('detail')
                      .where((e) => e.getAttribute('type') == 'track')
                      .toList() ??
                  <XmlElement>[];
      discs.add(MusicDisc(
        id: MusicDiscId(discId),
        discNumber: discNumber,
        title: xmlMusicValue(raw, 'title'),
        format: discFormat,
        formatFamily: musicImportFormatFamily(discFormat),
        recordingDate: xmlMusicDate(xmlMusicValue(raw, 'recordingdate/date') ??
            xmlMusicValue(record, 'recordingdate/date')),
        recordingLocations: _scopedValues(raw, record, 'studios', 'studio'),
        sparsCode:
            xmlMusicValue(raw, 'spars') ?? xmlMusicValue(record, 'spars'),
        isLive: _live(
            xmlMusicValue(raw, 'islive') ?? xmlMusicValue(record, 'islive')),
        soundTypes: _scopedValues(raw, record, web ? 'soundtypes' : 'sounds',
            web ? 'soundtype' : 'sound'),
        color: xmlMusicValue(raw, 'vinylcolor') ??
            xmlMusicValue(record, 'vinylcolor'),
        credits: raw == null ? const [] : _credits(raw, discId),
        tracks: [
          for (var track = 0; track < tracks.length; track++)
            _track(tracks[track], discId, track, web: web)
        ],
      ));
    }
    final purchase = xmlMusicDate(xmlMusicValue(record, 'purchasedate/date'));
    final rating = musicImportInt(
        xmlMusicValue(record, web ? 'myrating' : 'rating'), 'rating',
        max: 10);
    result.add(musicImportRow(
        id: id,
        album: MusicAlbum(
          title: title,
          sortTitle:
              resolveSortTitle(title, xmlMusicValue(record, 'sorttitle')),
          artist: artists.isEmpty ? null : artists.join(' / '),
          artistCredits: [
            for (var a = 0; a < artists.length; a++)
              MusicArtistCredit(
                  id: musicImportId(id, 'artist/$a'),
                  creditedName: artists[a],
                  sequence: a + 1,
                  joinPhrase: a < artists.length - 1 ? ' / ' : null)
          ],
          publisher: xmlMusicValue(record, 'label'),
          catalogNumber: xmlMusicValue(record, 'labelnumber'),
          barcode: xmlMusicValue(record, 'upc'),
          countryCode: xmlMusicValue(record, 'country'),
          packaging: xmlMusicValue(record, 'packaging'),
          releaseDateParts:
              xmlMusicDate(xmlMusicValue(record, 'releasedate/date')),
          originalReleaseDateParts: xmlMusicDate(xmlMusicValue(record,
              web ? 'originalreleasedate/date' : 'origreleasedate/date')),
          genres: xmlMusicValues(record, 'genres', 'genre'),
          extra: xmlMusicValues(record, 'extras', 'extra'),
          boxSet: xmlMusicValue(record, 'boxset'),
          credits: _credits(record, id),
          discs: discs,
        ),
        personal: MusicPersonalData(
          pricePaidCents:
              musicImportMoney(xmlMusicValue(record, 'purchaseprice')),
          currency: xmlMusicValue(record, 'currency'),
          purchaseStore: xmlMusicValue(record, 'store'),
          personalNotes: xmlMusicValue(record, 'notes'),
          mediaCondition: xmlMusicValue(record, 'condition'),
          indexNumber: musicImportInt(xmlMusicValue(record, 'index'), 'Index'),
          quantity: musicImportInt(
                  xmlMusicValue(record, 'quantity'), 'Quantity',
                  min: 1) ??
              1,
          rating: rating,
          purchaseDateParts: purchase,
          purchaseDate: purchase?.asDateTime,
          collectionStatus:
              _collectionStatus(xmlMusicValue(record, 'collectionstatus')),
          tags: xmlMusicValues(record, 'tags', 'tag'),
        )));
  }
  return List.unmodifiable(result);
}

XmlElement? xmlMusicPath(XmlElement? root, String path) {
  var element = root;
  for (final part in path.split('/')) {
    element = element?.getElement(part);
  }
  return element;
}

String? xmlMusicValue(XmlElement? root, String path) {
  final element = xmlMusicPath(root, path);
  if (element == null) return null;
  final value = (element.getElement('displayname') ?? element).innerText.trim();
  return value.isEmpty ? null : value;
}

List<String> xmlMusicValues(XmlElement root, String container, String item) => [
      for (final element
          in root.getElement(container)?.findElements(item) ?? <XmlElement>[])
        if (xmlMusicValue(element, 'displayname') ??
                xmlMusicValue(element, 'name') ??
                element.innerText.trim()
            case final value when value.isNotEmpty)
          value,
    ];

List<String> _scopedValues(
    XmlElement? disc, XmlElement album, String container, String item) {
  final values =
      disc == null ? <String>[] : xmlMusicValues(disc, container, item);
  return values.isNotEmpty ? values : xmlMusicValues(album, container, item);
}

MusicTrack _track(XmlElement raw, String discId, int index,
    {required bool web}) {
  final title = xmlMusicValue(raw, 'title');
  if (title == null) {
    throw LibraryImportFormatException('Disc track ${index + 1} has no title.');
  }
  final seconds = musicImportInt(
      xmlMusicValue(raw, web ? 'length' : 'lengthsecs'), 'track length');
  final externalTrackId =
      xmlMusicValue(raw, 'hash') ?? xmlMusicValue(raw, 'id') ?? '${index + 1}';
  return MusicTrack(
      id: MusicTrackId(musicImportId(discId, 'track/$externalTrackId')),
      position: xmlMusicValue(raw, 'position') ?? '${index + 1}',
      positionOrder: index + 1,
      title: title,
      durationMs: seconds == null ? null : seconds * 1000,
      artist: xmlMusicValues(raw, 'artists', 'artist').isEmpty
          ? null
          : xmlMusicValues(raw, 'artists', 'artist').join(' / '),
      composition: xmlMusicValue(raw, 'composition'));
}

List<MusicCredit> _credits(XmlElement raw, String owner) {
  final values = <({String name, String role, List<String> instruments})>[];
  for (final role in {
    'composers': 'Composer',
    'conductors': 'Conductor',
    'orchestras': 'Orchestra',
    'choruses': 'Chorus'
  }.entries) {
    for (final name in xmlMusicValues(
        raw,
        role.key,
        role.key == 'choruses'
            ? 'chorus'
            : role.key.substring(0, role.key.length - 1))) {
      values.add((name: name, role: role.value, instruments: const []));
    }
  }
  for (final credit in [
    ...?raw.getElement('credits')?.childElements,
    ...?raw.getElement('musicians')?.childElements
  ]) {
    final name = xmlMusicValue(credit, 'person/displayname') ??
        xmlMusicValue(credit, 'displayname') ??
        xmlMusicValue(credit, 'name');
    final role = xmlMusicValue(credit, 'role');
    if (name != null && role != null) {
      values.add((
        name: name,
        role: role,
        instruments: [
          if (xmlMusicValue(credit, 'instrument') case final instrument?)
            instrument
        ]
      ));
    }
  }
  return [
    for (var i = 0; i < values.length; i++)
      MusicCredit(
          id: MusicCreditId(musicImportId(owner, 'credit/$i')),
          name: values[i].name,
          role: values[i].role,
          instruments: values[i].instruments,
          sequence: i + 1)
  ];
}

bool? _live(String? value) => switch (value?.toLowerCase()) {
      null => null,
      '1' || 'true' || 'yes' => true,
      '0' || 'false' || 'no' => false,
      _ =>
        throw LibraryImportFormatException('Invalid Is Live value "$value".'),
    };
String? _collectionStatus(String? value) => switch (value) {
      null => null,
      'On Order' => 'On Order',
      'Not in Collection' => 'Not in Collection',
      'In Collection' => 'In Collection',
      'For Sale' => 'For Sale',
      'Sold' => 'Sold',
      'Wish List' || 'On Wish List' => 'Wish List',
      _ => throw LibraryImportFormatException(
          'Unsupported collection status "$value".'),
    };

PartialDate? xmlMusicDate(String? value) {
  if (value == null) return null;
  final slash = RegExp(r'^(\d{4})?/(\d{1,2})?/(\d{1,2})?$').firstMatch(value);
  if (slash != null) {
    final year = slash[1] == null ? null : int.parse(slash[1]!);
    final month = slash[2] == null ? null : int.parse(slash[2]!);
    final day = slash[3] == null ? null : int.parse(slash[3]!);
    if (year == null && month == null && day == null) return null;
    if ((year != null && (year < 1 || year > 9999)) ||
        (month != null && (month < 1 || month > 12)) ||
        (day != null &&
            (day < 1 ||
                day >
                    (month == null
                        ? 31
                        : DateTime.utc(year ?? 2000, month + 1, 0).day)))) {
      throw LibraryImportFormatException('Invalid XML date "$value".');
    }
    return PartialDate(year: year, month: month, day: day);
  }
  final us = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})(?: .*)?$').firstMatch(value);
  if (us != null) {
    return musicImportDate(
        '${us[3]}-${us[1]!.padLeft(2, '0')}-${us[2]!.padLeft(2, '0')}');
  }
  return musicImportDate(value);
}
