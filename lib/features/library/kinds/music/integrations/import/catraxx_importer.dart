import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_format_presets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_artist_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:xml/xml.dart';
import 'music_import_row.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';

/// CATraxx "Export to XML" of the Album table: a `<data>` root with field
/// definitions and one `<record table="album">` per album, holding
/// `<albumdata>` and the discs, sides and tracks under `<trackdata>`.
final class CatraxxImporter implements LibraryGuidedImporter {
  const CatraxxImporter();

  @override
  List<CollectionImportRow> parse(String source) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(
          source.replaceAll('\r\n', '\n').replaceAll('\r', '\n'));
    } on XmlException catch (error) {
      throw LibraryImportFormatException('Malformed XML: ${error.message}');
    }
    final root = document.rootElement;
    if (root.name.local != 'data') {
      throw LibraryImportFormatException(
          'Expected a CATraxx XML export, not <${root.name.local}>.');
    }
    final records = root.findElements('record').toList();
    if (records.any((record) => record.getAttribute('table') != 'album')) {
      throw const LibraryImportFormatException(
          'Export the Album table from CATraxx; other tables are not albums.');
    }
    if (records.isEmpty) {
      throw const LibraryImportFormatException(
          'No album records found in the CATraxx export.');
    }
    final seen = <String>{};
    return List.unmodifiable([
      for (final record in records) _album(record, seen),
    ]);
  }
}

CollectionImportRow _album(XmlElement record, Set<String> seen) {
  final data = record.getElement('albumdata');
  final albumId = record.getAttribute('id');
  if (data == null || albumId == null || !seen.add(albumId)) {
    throw const LibraryImportFormatException(
        'An album record is missing its data or repeats an Album ID.');
  }
  final id = musicImportId('catraxx', albumId);
  final title = _text(data, 'title') ?? '';
  final artists = _artists(data);
  final format = _text(data, 'format');
  final rawDiscs =
      record.getElement('trackdata')?.findElements('disc').toList() ??
          const <XmlElement>[];
  // "2CD" or "2LP" name the disc count before the format of each disc.
  final counted = RegExp(r'^(\d+)\s*(\S.*)$').firstMatch(format ?? '');
  final discFormat =
      counted != null && musicFormatPresetFamily(counted[2]) != null
          ? counted[2]
          : format;
  final discCount = rawDiscs.isNotEmpty
      ? rawDiscs.length
      : int.tryParse(counted?[1] ?? '') ??
          musicImportInt(_text(data, 'disccount'), 'Disc Count', max: 100) ??
          (format == null ? 0 : 1);
  if (discCount > 100) {
    throw const LibraryImportFormatException('An album exceeds 100 discs.');
  }
  final live = _bool(data, 'live');
  final purchase = _date(data.getElement('dateacquired'));
  return musicImportRow(
      id: id,
      album: MusicAlbum(
        title: title,
        sortTitle: resolveSortTitle(title, _text(data, 'titlesort')),
        artist: data.getElement('artists')?.getAttribute('formattedname') ??
            (artists.isEmpty ? null : artists.join(' / ')),
        artistCredits: [
          for (var a = 0; a < artists.length; a++)
            MusicArtistCredit(
                id: musicImportId(id, 'artist/$a'),
                creditedName: artists[a],
                sequence: a + 1,
                joinPhrase: a < artists.length - 1 ? ' / ' : null)
        ],
        publisher: _text(data, 'label'),
        catalogNumber: _text(data, 'catalognumber'),
        barcode: _text(data, 'barcode'),
        countryCode: _text(data, 'country'),
        packaging: _text(data, 'packaging'),
        releaseDateParts: _date(data.getElement('released')),
        genres: _list(data, 'genrelist', 'genre'),
        boxSet: _text(data, 'boxset'),
        credits: _credits(data, id),
        discs: [
          for (var index = 0; index < discCount; index++)
            _disc(index < rawDiscs.length ? rawDiscs[index] : null, index + 1,
                id, title, discFormat, live),
        ],
      ),
      personal: MusicPersonalData(
        pricePaidCents: _money(data, 'price'),
        marketValueCents: _money(data, 'value'),
        purchaseStore: _text(data, 'acquiredfrom'),
        purchaseDateParts: purchase,
        purchaseDate: purchase?.asDateTime,
        personalNotes: _text(data, 'notes'),
        mediaCondition: _text(data, 'conditionrecord'),
        ownerLabel: _text(data, 'owner'),
        rating: _rating(_text(data, 'personalrating')),
        tags: splitPickListValues(_text(data, 'keywords')),
        collectionStatus: _status(_text(data, 'status')),
      ));
}

MusicDisc _disc(XmlElement? raw, int number, String albumId, String albumTitle,
    String? format, bool? live) {
  final discId = musicImportId(albumId, 'disc/$number');
  final sides = raw?.findElements('side').toList() ?? const <XmlElement>[];
  final tracks = [
    for (final side in sides) ...side.findElements('track'),
  ];
  final title = _text(raw, 'title');
  return MusicDisc(
    id: MusicDiscId(discId),
    discNumber: number,
    title: title == albumTitle ? null : title,
    format: format,
    formatFamily: musicImportFormatFamily(format),
    isLive: live,
    tracks: [
      for (var index = 0; index < tracks.length; index++)
        _track(tracks[index], discId, index, sided: sides.length > 1),
    ],
  );
}

MusicTrack _track(XmlElement raw, String discId, int index,
    {required bool sided}) {
  final title = _text(raw, 'title');
  if (title == null) {
    throw LibraryImportFormatException('Disc track ${index + 1} has no title.');
  }
  final length = raw.getElement('length');
  final seconds = length == null
      ? null
      : (musicImportInt(length.getAttribute('minutes'), 'track length') ?? 0) *
              60 +
          (musicImportInt(length.getAttribute('seconds'), 'track length') ?? 0);
  final trackNumber = _text(raw, 'index') ?? '${index + 1}';
  final artists = _artists(raw);
  return MusicTrack(
    id: MusicTrackId(
        musicImportId(discId, 'track/${raw.getAttribute('id') ?? index + 1}')),
    position: sided ? '${_text(raw, 'side') ?? ''}$trackNumber' : trackNumber,
    positionOrder: index + 1,
    title: title,
    durationMs: seconds == null || seconds == 0 ? null : seconds * 1000,
    artist: raw.getElement('artists')?.getAttribute('formattedname') ??
        (artists.isEmpty ? null : artists.join(' / ')),
  );
}

/// Album-level people other than the performing artists, by credit group.
List<MusicCredit> _credits(XmlElement data, String owner) {
  final values = <({String name, String role})>[];
  for (final group in const {
    'albumauthorcredits': 'Composer',
    'albumconductorcredits': 'Conductor',
    'albumproductioncredits': 'Producer',
    'albumstudiocredits': 'Studio',
    'albumcredits': 'Credit',
    'albumbandmembers': 'Musician',
    'albumguestmusicians': 'Guest Musician',
  }.entries) {
    for (final credit
        in data.getElement(group.key)?.childElements ?? const <XmlElement>[]) {
      final name = _text(credit, 'name');
      if (name == null) continue;
      final roles = _list(credit, 'roles', 'role');
      values.add((name: name, role: roles.isEmpty ? group.value : roles.first));
    }
  }
  return [
    for (var i = 0; i < values.length; i++)
      MusicCredit(
          id: MusicCreditId(musicImportId(owner, 'credit/$i')),
          name: values[i].name,
          role: values[i].role,
          sequence: i + 1),
  ];
}

List<String> _artists(XmlElement raw) => [
      for (final artist in raw.getElement('artists')?.findElements('artist') ??
          const <XmlElement>[])
        if (_text(artist, 'name') case final name?) name,
    ];

List<String> _list(XmlElement raw, String container, String item) => [
      for (final element in raw.getElement(container)?.findElements(item) ??
          const <XmlElement>[])
        if (element.innerText.trim() case final value when value.isNotEmpty)
          value,
    ];

String? _text(XmlElement? raw, String name) {
  final value = raw?.getElement(name)?.innerText.trim();
  // Rich-text fields the export did not expand are references, not text.
  if (value == null ||
      value.isEmpty ||
      RegExp(r'^\*rtf:.*\*$').hasMatch(value)) {
    return null;
  }
  return value;
}

bool? _bool(XmlElement raw, String name) =>
    switch (raw.getElement(name)?.getAttribute('bool')) {
      null => null,
      'True' => true,
      'False' => false,
      final value =>
        throw LibraryImportFormatException('Invalid $name value "$value".'),
    };

/// CATraxx dates carry year, month and day attributes, blank when unknown.
PartialDate? _date(XmlElement? raw) {
  if (raw == null) return null;
  final parts = [
    for (final name in ['year', 'month', 'day'])
      raw.getAttribute(name)?.trim() ?? '',
  ];
  if (parts[0].isEmpty) return null;
  return musicImportDate([
    parts[0],
    if (parts[1].isNotEmpty) ...[
      parts[1].padLeft(2, '0'),
      if (parts[2].isNotEmpty) parts[2].padLeft(2, '0'),
    ],
  ].join('-'));
}

/// CATraxx stores an unset amount as zero, so zero is not imported.
int? _money(XmlElement raw, String name) {
  final cents =
      musicImportMoney(raw.getElement(name)?.getAttribute('unformatted'));
  return cents == 0 ? null : cents;
}

/// The CATraxx Personal Rating runs 0-5 in half steps; ours runs 0-10.
int? _rating(String? value) {
  if (value == null) return null;
  final stars = double.tryParse(value);
  if (stars == null || stars < 0 || stars > 5 || (stars * 2) % 1 != 0) {
    throw LibraryImportFormatException('Invalid Personal Rating "$value".');
  }
  return (stars * 2).round();
}

String? _status(String? value) => switch (value?.toLowerCase()) {
      null => 'In Collection',
      'own' || 'owned' || 'in collection' => 'In Collection',
      'ordered' || 'on order' => 'On Order',
      'wanted' || 'want' || 'wish list' => 'Wish List',
      'for sale' => 'For Sale',
      'sold' => 'Sold',
      'not owned' || 'not in collection' => 'Not in Collection',
      _ => throw LibraryImportFormatException(
          'Unsupported CATraxx Status "$value". Rename it to Own, Ordered, Wanted, For Sale or Sold before exporting.'),
    };
