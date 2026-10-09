import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';

/// Translates the strict Core Music v2 document into the local Music aggregate.
final class MusicCatalogMapper {
  const MusicCatalogMapper._();

  static const coreFields = <String>{
    'id',
    'kind',
    'revision',
    'title',
    'sort_title',
    'subtitle',
    'artist',
    'artist_credits',
    'original_release_date',
    'release_date',
    'label',
    'barcode',
    'catalog_number',
    'genres',
    'packaging',
    'country',
    'extra',
    'box_set',
    'credits',
    'external_links',
    'cover_image_url',
    'back_cover_image_url',
    'thumbnail_image_url',
    'discs',
  };

  static const discFields = <String>{
    'id',
    'disc_number',
    'title',
    'format_family',
    'format',
    'sound_types',
    'recording_date',
    'recording_locations',
    'is_live',
    'spars_code',
    'color',
    'vinyl_weight_grams',
    'rpm',
    'matrix_number',
    'matrix_number_side_a',
    'matrix_number_side_b',
    'credits',
    'tracks',
  };

  static const creditFields = <String>{
    'id',
    'contributor_id',
    'name',
    'sort_name',
    'role',
    'role_id',
    'instruments',
    'sequence',
  };

  static const trackFields = <String>{
    'id',
    'position',
    'position_order',
    'title',
    'artist',
    'composition',
    'duration_ms',
    'is_header',
    'parent_header_id',
    'indent_level',
  };

  /// Encodes catalog-owned fields only. Local paths and timestamps stay local.
  static CatalogItemDto toCatalogItemDto(
    MusicAlbum album, {
    CatalogItemRef? ref,
  }) {
    final itemRef = ref ?? album.id;
    if (itemRef == null || itemRef.kind != CatalogMediaKind.music) {
      throw StateError('Encoding a Music Catalog Item requires its Core ID.');
    }
    final music = <String, dynamic>{
      'id': itemRef.id,
      'kind': CatalogMediaKind.music.apiValue,
      'revision': album.revision,
      'title': album.title,
      if (album.sortTitle != null) 'sort_title': album.sortTitle,
      if (album.subtitle != null) 'subtitle': album.subtitle,
      if (album.artist != null) 'artist': album.artist,
      'artist_credits': [
        for (final credit in album.artistCredits)
          {
            'id': credit.id,
            'name': credit.creditedName,
            'sequence': credit.sequence,
            if (credit.sortName != null) 'sort_name': credit.sortName,
            if (credit.artistId != null) 'artist_id': credit.artistId,
            if (credit.joinPhrase != null) 'join_phrase': credit.joinPhrase,
          },
      ],
      if (album.originalReleaseDateParts != null)
        'original_release_date': album.originalReleaseDateParts!.toJson(),
      if (album.releaseDateParts != null)
        'release_date': album.releaseDateParts!.toJson(),
      if (album.publisher != null) 'label': album.publisher,
      if (album.barcode != null) 'barcode': album.barcode,
      if (album.catalogNumber != null) 'catalog_number': album.catalogNumber,
      'genres': album.genres,
      if (album.packaging != null) 'packaging': album.packaging,
      if (album.countryCode != null) 'country': album.countryCode,
      'extra': album.extra,
      if (album.boxSet != null) 'box_set': album.boxSet,
      'credits': album.credits.map((credit) => credit.toJson()).toList(),
      'external_links':
          album.externalLinks.map((link) => link.toJson()).toList(),
      if (album.coverImageUrl != null) 'cover_image_url': album.coverImageUrl,
      if (album.backCoverImageUrl != null)
        'back_cover_image_url': album.backCoverImageUrl,
      if (album.thumbnailImageUrl != null)
        'thumbnail_image_url': album.thumbnailImageUrl,
      'discs': [for (final disc in album.discs) _discToCatalogData(disc)],
    };
    fromCatalogPayload(music);
    return CatalogItemDto.raw(
      id: itemRef.id,
      mediaKind: itemRef.kind,
      kindData: music,
    );
  }

  static Map<String, Object?> _discToCatalogData(MusicDisc disc) => {
        'id': disc.id.value,
        'disc_number': disc.discNumber,
        if (disc.title != null) 'title': disc.title,
        if (disc.formatFamily != null)
          'format_family': disc.formatFamily!.value,
        if (disc.format != null) 'format': disc.format,
        'sound_types': disc.soundTypes,
        if (disc.recordingDate != null)
          'recording_date': disc.recordingDate!.toJson(),
        'recording_locations': disc.recordingLocations,
        if (disc.isLive != null) 'is_live': disc.isLive,
        if (disc.sparsCode != null) 'spars_code': disc.sparsCode,
        if (disc.color != null) 'color': disc.color,
        if (disc.vinylWeightGrams != null)
          'vinyl_weight_grams': disc.vinylWeightGrams,
        if (disc.rpm != null) 'rpm': disc.rpm,
        if (disc.matrixNumber != null) 'matrix_number': disc.matrixNumber,
        if (disc.matrixNumberSideA != null)
          'matrix_number_side_a': disc.matrixNumberSideA,
        if (disc.matrixNumberSideB != null)
          'matrix_number_side_b': disc.matrixNumberSideB,
        'credits': disc.credits.map((credit) => credit.toJson()).toList(),
        'tracks': [
          for (var index = 0; index < disc.tracks.length; index++)
            _trackToCatalogData(disc.tracks[index], index),
        ],
      };

  static Map<String, Object?> _trackToCatalogData(
    MusicTrack track,
    int index,
  ) =>
      {
        'id': track.id.value,
        'position': track.isHeader ? '' : track.position,
        'position_order': track.positionOrder ?? index,
        'title': track.title,
        'is_header': track.isHeader,
        'indent_level': track.indentLevel,
        if (track.parentHeaderId != null)
          'parent_header_id': track.parentHeaderId,
        if (!track.isHeader && track.artist != null) 'artist': track.artist,
        if (!track.isHeader && track.composition != null)
          'composition': track.composition,
        if (!track.isHeader && track.durationMs != null)
          'duration_ms': track.durationMs,
      };

  static MusicAlbum mapDtoToMusic(CatalogItemDto dto) =>
      mapMetadataItemToMusic(dto);

  static MusicAlbum mapMetadataItemToMusic(CatalogItemDto item) {
    final payload = catalogTransportPayloadFor(item);
    return switch (item.origin) {
      CatalogItemOrigin.privateLocal => MusicAlbum.fromJson(
          Map<String, dynamic>.from(payload)
            ..remove('id')
            ..remove('kind'),
        ),
      CatalogItemOrigin.core => fromCatalogPayload(payload),
    };
  }

  static CatalogItemDto toLocalCatalogItemDto(MusicAlbum album, {String? id}) {
    final localId = id ?? album.id?.id;
    if (localId == null || localId.trim().isEmpty) {
      throw StateError('Encoding a local Music item requires its entry ID.');
    }
    final localData = Map<String, dynamic>.from(album.toJson())
      ..remove('id')
      ..remove('kind');
    return CatalogItemDto.raw(
      id: localId,
      mediaKind: CatalogMediaKind.music,
      kindData: localData,
      origin: CatalogItemOrigin.privateLocal,
    );
  }

  static MusicAlbum fromCatalogPayload(Map<String, dynamic> payload) {
    _assertFields(payload, coreFields, 'Music Catalog Item');
    final id = _requiredText(payload['id'], 'Music Catalog Item id');
    _requiredText(payload['title'], 'Music Catalog Item title');
    if (payload['kind'] != 'music') {
      throw FormatException(
          'Expected a Music Catalog Item, received ${payload['kind']}.');
    }
    final revision = payload['revision'];
    if (revision is! int || revision < 1) {
      throw const FormatException(
          'Music Catalog Item revision must be positive.');
    }
    for (final field in const [
      'sort_title',
      'subtitle',
      'artist',
      'label',
      'barcode',
      'catalog_number',
      'country',
      'packaging',
      'box_set',
      'cover_image_url',
      'back_cover_image_url',
      'thumbnail_image_url',
    ]) {
      _optionalText(payload[field], 'Music Catalog Item $field');
    }

    final artistCredits = _requiredMaps(
      payload['artist_credits'],
      path: 'Music artist credits',
    );
    final albumCredits =
        _requiredMaps(payload['credits'], path: 'Music credits');
    final discs = _requiredMaps(payload['discs'], path: 'Music discs');
    _requiredStrings(payload['genres'], path: 'Music genres');
    _requiredStrings(payload['extra'], path: 'Music extra');
    _validatePartialDate(payload['original_release_date'],
        'Music Catalog Item original_release_date');
    _validatePartialDate(
        payload['release_date'], 'Music Catalog Item release_date');
    _validateArtistCredits(artistCredits);
    final creditIds = <String>{};
    _validateCredits(
      albumCredits,
      path: 'Music album credits',
      sharedIds: creditIds,
    );
    _validateDiscs(discs, creditIds: creditIds);

    final localPayload = <String, dynamic>{
      'id': id,
      'kind': 'music',
      'revision': revision,
      'title': payload['title'],
      if (payload['sort_title'] != null) 'sort_title': payload['sort_title'],
      if (payload['subtitle'] != null) 'subtitle': payload['subtitle'],
      if (payload['artist'] != null) 'artist': payload['artist'],
      if (payload['original_release_date'] != null)
        'original_release_date': payload['original_release_date'],
      if (payload['release_date'] != null)
        'release_date': payload['release_date'],
      if (payload['label'] != null) 'publisher': payload['label'],
      if (payload['barcode'] != null) 'barcode': payload['barcode'],
      if (payload['catalog_number'] != null)
        'catalog_number': payload['catalog_number'],
      'genres': payload['genres'],
      if (payload['packaging'] != null) 'packaging': payload['packaging'],
      if (payload['country'] != null) 'country_code': payload['country'],
      'extra': payload['extra'],
      if (payload['box_set'] != null) 'box_set': payload['box_set'],
      'credits': albumCredits,
      'artist_credits': [
        for (final credit in artistCredits)
          {
            'id': credit['id'],
            'credited_name': credit['name'],
            'sequence': credit['sequence'],
            if (credit['sort_name'] != null) 'sort_name': credit['sort_name'],
            if (credit['artist_id'] != null) 'artist_id': credit['artist_id'],
            if (credit['join_phrase'] != null)
              'join_phrase': credit['join_phrase'],
          },
      ],
      'external_links': _requiredMaps(
        payload['external_links'],
        path: 'Music external links',
      ),
      if (payload['cover_image_url'] != null)
        'cover_image_url': payload['cover_image_url'],
      if (payload['back_cover_image_url'] != null)
        'back_cover_image_url': payload['back_cover_image_url'],
      if (payload['thumbnail_image_url'] != null)
        'thumbnail_image_url': payload['thumbnail_image_url'],
      'discs': discs,
    };
    return MusicAlbum.fromJson(localPayload);
  }

  static void _validateArtistCredits(List<Map<String, dynamic>> credits) {
    final ids = <String>{};
    final sequences = <int>{};
    for (var index = 0; index < credits.length; index++) {
      final credit = credits[index];
      const fields = {
        'id',
        'name',
        'sort_name',
        'artist_id',
        'sequence',
        'join_phrase',
      };
      _assertFields(credit, fields, 'Music artist credit ${index + 1}');
      final id = _requiredText(credit['id'], 'Music artist credit id');
      _requiredText(credit['name'], 'Music artist credit name');
      _optionalText(credit['sort_name'], 'Music artist credit sort_name');
      _optionalText(credit['artist_id'], 'Music artist credit artist_id');
      final joinPhrase = credit['join_phrase'];
      if (joinPhrase != null && joinPhrase is! String) {
        throw const FormatException(
          'Music artist credit join_phrase must be text or null.',
        );
      }
      final sequence = credit['sequence'];
      if (sequence is! int ||
          sequence < 1 ||
          !ids.add(id) ||
          !sequences.add(sequence)) {
        throw const FormatException(
            'Music artist credits require unique IDs and sequences.');
      }
    }
  }

  static void _validateCredits(
    List<Map<String, dynamic>> credits, {
    required String path,
    Set<String>? sharedIds,
  }) {
    final ids = sharedIds ?? <String>{};
    final sequences = <int>{};
    for (var index = 0; index < credits.length; index++) {
      final credit = credits[index];
      _assertFields(credit, creditFields, '$path ${index + 1}');
      final id = _requiredText(credit['id'], '$path id');
      _optionalText(credit['contributor_id'], '$path contributor_id');
      _requiredText(credit['name'], '$path name');
      _optionalText(credit['sort_name'], '$path sort_name');
      _requiredText(credit['role'], '$path role');
      _optionalText(credit['role_id'], '$path role_id');
      _requiredStrings(credit['instruments'], path: '$path instruments');
      final sequence = credit['sequence'];
      if (sequence is! int ||
          sequence < 1 ||
          !ids.add(id) ||
          !sequences.add(sequence)) {
        throw FormatException('$path require unique IDs and sequences.');
      }
    }
  }

  static void _validateDiscs(
    List<Map<String, dynamic>> discs, {
    required Set<String> creditIds,
  }) {
    final discIds = <String>{};
    final trackIds = <String>{};
    var previousDiscNumber = 0;
    const families = {'vinyl', 'opticalDisc', 'tape', 'digital', 'other'};
    for (var discIndex = 0; discIndex < discs.length; discIndex++) {
      final disc = discs[discIndex];
      final path = 'Music disc ${discIndex + 1}';
      _assertFields(disc, discFields, path);
      final id = _requiredText(disc['id'], '$path id');
      final number = disc['disc_number'];
      if (number is! int || number <= previousDiscNumber || !discIds.add(id)) {
        throw const FormatException(
            'Music disc IDs and numbers must be unique and ordered.');
      }
      previousDiscNumber = number;
      for (final field in const [
        'title',
        'format',
        'color',
        'rpm',
        'spars_code',
        'matrix_number',
        'matrix_number_side_a',
        'matrix_number_side_b',
      ]) {
        _optionalText(disc[field], '$path $field');
      }
      final family = disc['format_family'];
      if (family != null && !families.contains(family)) {
        throw FormatException('$path has an unrecognized format_family.');
      }
      if (disc['format'] != null && family == null) {
        throw FormatException(
          '$path format requires an explicit format_family.',
        );
      }
      final weight = disc['vinyl_weight_grams'];
      if (weight != null && (weight is! int || weight <= 0)) {
        throw FormatException('$path vinyl_weight_grams must be positive.');
      }
      _requiredStrings(disc['sound_types'], path: '$path sound_types');
      _requiredStrings(
        disc['recording_locations'],
        path: '$path recording_locations',
      );
      _validatePartialDate(disc['recording_date'], '$path recording_date');
      if (disc['is_live'] != null && disc['is_live'] is! bool) {
        throw FormatException('$path is_live must be boolean or null.');
      }
      _validateCredits(
        _requiredMaps(disc['credits'], path: '$path credits'),
        path: '$path credits',
        sharedIds: creditIds,
      );
      final tracks = _requiredMaps(disc['tracks'], path: '$path tracks');
      var previousTrackOrder = -1;
      for (var trackIndex = 0; trackIndex < tracks.length; trackIndex++) {
        final track = tracks[trackIndex];
        final trackPath = '$path track ${trackIndex + 1}';
        _assertFields(track, trackFields, trackPath);
        final trackId = _requiredText(track['id'], '$trackPath id');
        final order = track['position_order'];
        final position = track['position'];
        final title = track['title'];
        final isHeader = track['is_header'] == true;
        if (!trackIds.add(trackId) ||
            order is! int ||
            order <= previousTrackOrder ||
            position is! String ||
            position != position.trim() ||
            (isHeader && position.isNotEmpty) ||
            (!isHeader && position.isEmpty) ||
            title is! String ||
            title.isEmpty ||
            title != title.trim() ||
            track['is_header'] is! bool ||
            track['indent_level'] is! int ||
            (track['indent_level'] as int) < 0 ||
            (track['indent_level'] as int) > 8 ||
            (track['duration_ms'] != null &&
                (track['duration_ms'] is! int ||
                    (track['duration_ms'] as int) < 0)) ||
            (isHeader &&
                (track['artist'] != null ||
                    track['composition'] != null ||
                    track['duration_ms'] != null))) {
          throw FormatException(
              '$trackPath has invalid identity or ordering fields.');
        }
        previousTrackOrder = order;
        _optionalText(track['artist'], '$trackPath artist');
        _optionalText(track['composition'], '$trackPath composition');
        _optionalText(track['parent_header_id'], '$trackPath parent_header_id');
      }
    }
  }

  static void _validatePartialDate(Object? value, String path) {
    if (value == null) return;
    if (value is! Map) {
      throw FormatException('$path must be a PartialDate object.');
    }
    final fields = Map<Object?, Object?>.from(value);
    if (fields.isEmpty ||
        fields.keys.any((key) => !{'year', 'month', 'day'}.contains(key)) ||
        fields.values.any((part) => part != null && part is! int) ||
        !fields.values.any((part) => part is int)) {
      throw FormatException('$path must be a PartialDate object.');
    }
    final yearValue = fields['year'];
    final monthValue = fields['month'];
    final dayValue = fields['day'];
    final year = yearValue is int ? yearValue : null;
    final month = monthValue is int ? monthValue : null;
    final day = dayValue is int ? dayValue : null;
    if ((yearValue != null && (year == null || year < 1 || year > 9999)) ||
        (monthValue != null && (month == null || month < 1 || month > 12)) ||
        (dayValue != null && (day == null || day < 1 || day > 31)) ||
        (day != null && month == null) ||
        (month != null && year == null)) {
      throw FormatException('$path contains invalid PartialDate values.');
    }
    if (year != null && month != null && day != null) {
      final parsed = DateTime.tryParse(
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      );
      if (parsed == null ||
          parsed.year != year ||
          parsed.month != month ||
          parsed.day != day) {
        throw FormatException('$path contains an invalid calendar date.');
      }
    }
  }

  static void _assertFields(
    Map<String, dynamic> value,
    Set<String> allowed,
    String path,
  ) {
    final unsupported = value.keys.where((key) => !allowed.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException('Unrecognized $path field "${unsupported.first}".');
    }
  }
}

List<Map<String, dynamic>> _requiredMaps(Object? value,
    {required String path}) {
  if (value is! List) throw FormatException('$path must be a list.');
  return [
    for (final (index, entry) in value.indexed)
      if (entry is Map)
        Map<String, dynamic>.from(entry)
      else
        throw FormatException('$path entry ${index + 1} must be an object.'),
  ];
}

List<String> _requiredStrings(Object? value, {required String path}) {
  if (value is! List || value.any((entry) => entry is! String)) {
    throw FormatException('$path must be a list of strings.');
  }
  return [
    for (final (index, entry) in value.cast<String>().indexed)
      if (entry.isNotEmpty && entry == entry.trim())
        entry
      else
        throw FormatException('$path entry ${index + 1} must be trimmed text.'),
  ];
}

String _requiredText(Object? value, String path) {
  if (value is! String || value.isEmpty || value != value.trim()) {
    throw FormatException('$path must be non-empty trimmed text.');
  }
  return value;
}

String? _optionalText(Object? value, String path) {
  if (value == null) return null;
  return _requiredText(value, path);
}
