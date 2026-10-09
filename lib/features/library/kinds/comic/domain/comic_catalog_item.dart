import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

enum ComicKeyEventType {
  firstAppearance,
  cameoAppearance,
  death,
  origin,
  firstIssue,
  iconicCover,
  other,
}

@immutable
final class ComicIdentifier implements JsonEncodable {
  const ComicIdentifier({
    required this.identifierType,
    required this.value,
    this.id,
    this.normalizedValue,
    this.isPrimary = false,
  });

  final String identifierType;
  final String value;
  final String? id;
  final String? normalizedValue;
  final bool isPrimary;

  factory ComicIdentifier.fromValue(Object value) {
    if (value is String) {
      return ComicIdentifier(identifierType: 'other', value: value);
    }
    if (value is! Map) {
      throw const FormatException(
        'Comic identifiers must be strings or objects.',
      );
    }
    final json = Map<String, dynamic>.from(value);
    final type = json['identifier_type'];
    final identifier = json['value'];
    if (type is! String ||
        type.trim().isEmpty ||
        identifier is! String ||
        identifier.trim().isEmpty) {
      throw const FormatException(
        'Comic identifier objects require identifier_type and value.',
      );
    }
    return ComicIdentifier(
      identifierType: type,
      value: identifier,
      id: json['id'] as String?,
      normalizedValue: json['normalized_value'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'identifier_type': identifierType,
        'value': value,
        if (id != null) 'id': id,
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        'is_primary': isPrimary,
      };
}

@immutable
final class ComicStoryArc implements JsonEncodable {
  const ComicStoryArc({
    this.id,
    this.storyArcId,
    this.name,
    this.description,
    this.publisher,
    this.startDate,
    this.endDate,
  });

  final String? id;
  final String? storyArcId;
  final String? name;
  final String? description;
  final String? publisher;
  final PartialDate? startDate;
  final PartialDate? endDate;

  factory ComicStoryArc.fromValue(Object value) {
    if (value is String) return ComicStoryArc(name: value);
    if (value is! Map) {
      throw const FormatException(
        'Comic story arcs must be strings or objects.',
      );
    }
    final json = Map<String, dynamic>.from(value);
    return ComicStoryArc(
      id: json['id'] as String?,
      storyArcId: json['story_arc_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      publisher: json['publisher'] as String?,
      startDate: PartialDate.tryParse(json['start_date']),
      endDate: PartialDate.tryParse(json['end_date']),
    );
  }

  ComicStoryArc copyWith({String? name}) => ComicStoryArc(
        id: id,
        storyArcId: storyArcId,
        name: name ?? this.name,
        description: description,
        publisher: publisher,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (storyArcId != null) 'story_arc_id': storyArcId,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (publisher != null) 'publisher': publisher,
        if (startDate != null) 'start_date': startDate!.toJson(),
        if (endDate != null) 'end_date': endDate!.toJson(),
      };

  Object toJsonValue() => id == null &&
          storyArcId == null &&
          description == null &&
          publisher == null &&
          startDate == null &&
          endDate == null
      ? name ?? ''
      : toJson();
}

@immutable
final class ComicCreator implements JsonEncodable {
  const ComicCreator({
    this.id,
    this.personId,
    this.artistId,
    this.name,
    this.role,
    this.roleId,
    this.sequence,
    this.creditedName,
    this.joinPhrase,
    this.imageUrl,
    this.sortName,
    this.instrument,
  });

  final String? id;
  final String? personId;
  final String? artistId;
  final String? name;
  final String? role;
  final String? roleId;
  final int? sequence;
  final String? creditedName;
  final String? joinPhrase;
  final String? imageUrl;
  final String? sortName;
  final String? instrument;

  factory ComicCreator.fromValue(Object value) {
    if (value is String) return ComicCreator(name: value);
    if (value is! Map) {
      throw const FormatException('Comic creators must be strings or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    return ComicCreator(
      id: json['id'] as String?,
      personId: json['person_id'] as String?,
      artistId: json['artist_id'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      roleId: json['role_id'] as String?,
      sequence: (json['sequence'] as num?)?.toInt(),
      creditedName: json['credited_name'] as String?,
      joinPhrase: json['join_phrase'] as String?,
      imageUrl: json['image_url'] as String?,
      sortName: json['sort_name'] as String?,
      instrument: json['instrument'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (personId != null) 'person_id': personId,
        if (artistId != null) 'artist_id': artistId,
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (creditedName != null) 'credited_name': creditedName,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (imageUrl != null) 'image_url': imageUrl,
        if (sortName != null) 'sort_name': sortName,
        if (instrument != null) 'instrument': instrument,
      };

  Object toJsonValue() => id == null &&
          personId == null &&
          artistId == null &&
          role == null &&
          roleId == null &&
          sequence == null &&
          creditedName == null &&
          joinPhrase == null &&
          imageUrl == null &&
          sortName == null &&
          instrument == null
      ? name ?? ''
      : toJson();
}

@immutable
final class ComicCharacter implements JsonEncodable {
  const ComicCharacter({
    this.id,
    this.characterId,
    this.name,
    this.realName,
    this.aliases = const [],
    this.role,
    this.description,
    this.imageUrl,
  });

  final String? id;
  final String? characterId;
  final String? name;
  final String? realName;
  final List<String> aliases;
  final String? role;
  final String? description;
  final String? imageUrl;

  factory ComicCharacter.fromValue(Object value) {
    if (value is String) return ComicCharacter(name: value);
    if (value is! Map) {
      throw const FormatException(
          'Comic characters must be strings or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    final aliasesValue = json['aliases'];
    if (aliasesValue != null &&
        (aliasesValue is! List ||
            aliasesValue.any((value) => value is! String))) {
      throw const FormatException('Comic character aliases must be strings.');
    }
    return ComicCharacter(
      id: json['id'] as String?,
      characterId: json['character_id'] as String?,
      name: json['name'] as String?,
      realName: json['real_name'] as String?,
      aliases: (aliasesValue as List<dynamic>?)?.cast<String>() ?? const [],
      role: json['role'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (characterId != null) 'character_id': characterId,
        if (name != null) 'name': name,
        if (realName != null) 'real_name': realName,
        if (aliases.isNotEmpty) 'aliases': aliases,
        if (role != null) 'role': role,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  Object toJsonValue() => id == null &&
          characterId == null &&
          realName == null &&
          aliases.isEmpty &&
          role == null &&
          description == null &&
          imageUrl == null
      ? name ?? ''
      : toJson();
}

@immutable
class ComicKeyEvent {
  const ComicKeyEvent({
    required this.type,
    required this.characterOrSubject,
    this.description,
  });

  final ComicKeyEventType type;
  final String characterOrSubject;
  final String? description;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'character_or_subject': characterOrSubject,
        if (description != null) 'description': description,
      };

  factory ComicKeyEvent.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final type =
        ComicKeyEventType.values.where((event) => event.name == typeName);
    final subject = json['character_or_subject'];
    if (type.isEmpty || subject is! String || subject.trim().isEmpty) {
      throw const FormatException(
        'Comic key events require a recognized type and character_or_subject.',
      );
    }
    return ComicKeyEvent(
      type: type.first,
      characterOrSubject: subject,
      description: json['description'] as String?,
    );
  }
}

@immutable
class ComicCatalogItem implements JsonEncodable {
  const ComicCatalogItem({
    this.id,
    required this.title,
    this.displayTitle,
    this.sortTitle,
    this.seriesTitle,
    this.seriesId,
    this.seriesGroup,
    this.seriesTags = const [],
    this.volumeName,
    this.volumeNumber,
    this.volumeStartYear,
    this.issueNumber,
    this.publisher,
    this.imprint,
    this.releaseDate,
    this.coverDate,
    this.coverDateParts,
    this.releaseDateParts,
    this.pageCount,
    this.country = 'US',
    this.language = 'en',
    this.ageRating,
    this.audienceRating,
    this.crossover,
    this.genres = const [],
    this.searchAliases = const [],
    this.synopsis,
    this.description,
    this.subtitle,
    this.localizedTitle,
    this.originalTitle,
    this.plotDescription,
    this.plotSummary,
    this.releaseStatus,
    this.contributors = const [],
    this.characters = const [],
    this.characterDetails = const [],
    this.creators = const [],
    this.storyArcs = const [],
    this.keyEvents = const [],
    this.isKeyComic = false,
    this.keyReason,
    this.variant,
    this.variantDescription,
    this.barcode,
    this.catalogNumber,
    this.coverPriceCents,
    this.currency,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.editionTitle,
    this.titleExtension,
    this.physicalFormat,
    this.identifiers = const [],
    this.links = const [],
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.comic;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? displayTitle;
  final CatalogItemRef? id;
  final String? sortTitle;
  final String? seriesTitle;
  final String? seriesId;
  final String? seriesGroup;
  final List<String> seriesTags;
  final String? volumeName;
  final String? volumeNumber;
  final int? volumeStartYear;
  final String? issueNumber;
  final String? publisher;
  final String? imprint;
  final DateTime? releaseDate;
  final DateTime? coverDate;
  final PartialDate? coverDateParts;
  final PartialDate? releaseDateParts;
  final int? pageCount;
  final String country;
  final String language;
  final String? ageRating;
  final String? audienceRating;
  final String? crossover;
  final List<String> genres;
  final List<String> searchAliases;
  final String? synopsis;
  final String? description;
  final String? subtitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? plotDescription;
  final String? plotSummary;
  final String? releaseStatus;
  final List<ComicCreator> contributors;
  final List<ComicCharacter> characters;
  final List<ComicCharacter> characterDetails;
  final List<ComicCreator> creators;
  final List<ComicStoryArc> storyArcs;
  final List<ComicKeyEvent> keyEvents;
  final bool isKeyComic;
  final String? keyReason;
  final String? variant;
  final String? variantDescription;
  final String? barcode;
  final String? catalogNumber;
  final int? coverPriceCents;
  final String? currency;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? editionTitle;
  final String? titleExtension;
  final String? physicalFormat;
  final List<ComicIdentifier> identifiers;
  final List<ComicLink> links;

  String? get isbn => identifierValue('isbn');
  String? get upc => identifierValue('upc');

  String? identifierValue(String identifierType) {
    for (final identifier in identifiers) {
      if (identifier.identifierType.toLowerCase() !=
          identifierType.toLowerCase()) {
        continue;
      }
      if (identifier.value.trim().isNotEmpty) return identifier.value;
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final externalLinks = [
      for (final link in links)
        if (link.isExternalLink) link.toJson(),
    ];
    final payload = <String, dynamic>{
      'kind': CatalogMediaKind.comic.apiValue,
      if (id != null) 'id': id!.id,
      'title': title,
      if (displayTitle != null) 'display_title': displayTitle,
      if (sortTitle != null) 'sort_key': sortTitle,
      if (seriesTitle != null) 'series_title': seriesTitle,
      if (seriesGroup != null) 'series_group': seriesGroup,
      if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
      if (volumeName != null) 'volume_name': volumeName,
      if (volumeNumber != null) 'volume_number': volumeNumber,
      if (volumeStartYear != null) 'volume_start_year': volumeStartYear,
      if (seriesId != null) 'series_id': seriesId,
      if (issueNumber != null) ...{
        'issue_number': issueNumber,
        'item_number': issueNumber,
      },
      if (publisher != null) 'publisher': publisher,
      if (imprint != null) 'imprint': imprint,
      if (releaseDateParts != null)
        'release_date_parts': releaseDateParts!.toJson()
      else if (releaseDate != null)
        'release_date': releaseDate!.toIso8601String(),
      if (coverDateParts != null)
        'cover_date': coverDateParts!.toJson()
      else if (coverDate != null)
        'cover_date': coverDate!.toIso8601String(),
      if (pageCount != null) 'page_count': pageCount,
      'country': country,
      'language': language,
      if (ageRating != null) 'age_rating': ageRating,
      if (audienceRating != null) 'audience_rating': audienceRating,
      if (crossover != null) 'crossover': crossover,
      if (genres.isNotEmpty) 'genres': genres,
      if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
      if (synopsis != null) 'synopsis': synopsis,
      if (description != null) 'description': description,
      if (subtitle != null) 'subtitle': subtitle,
      if (localizedTitle != null) 'localized_title': localizedTitle,
      if (originalTitle != null) 'original_title': originalTitle,
      if (plotDescription != null) 'plot_description': plotDescription,
      if (plotSummary != null) 'plot_summary': plotSummary,
      if (releaseStatus != null) 'release_status': releaseStatus,
      if (characters.isNotEmpty)
        'characters': [
          for (final character in characters) character.toJsonValue()
        ],
      if (characterDetails.isNotEmpty)
        'character_details': [
          for (final character in characterDetails) character.toJson(),
        ],
      if (contributors.isNotEmpty)
        'contributors': [
          for (final contributor in contributors) contributor.toJsonValue(),
        ],
      if (creators.isNotEmpty)
        'creators': [for (final creator in creators) creator.toJsonValue()],
      if (storyArcs.isNotEmpty)
        'story_arcs': [for (final arc in storyArcs) arc.toJsonValue()],
      if (keyEvents.isNotEmpty)
        'key_events': [for (final event in keyEvents) event.toJson()],
      if (isKeyComic) 'key_comic': true,
      if (keyReason != null) 'key_reason': keyReason,
      if (variant != null) 'variant_name': variant,
      if (variantDescription != null) 'variant_description': variantDescription,
      if (barcode != null) 'barcode': barcode,
      if (catalogNumber != null) 'catalog_number': catalogNumber,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      if (editionTitle != null) 'edition_title': editionTitle,
      if (titleExtension != null) 'title_extension': titleExtension,
      if (physicalFormat != null) 'physical_format': physicalFormat,
      if (identifiers.isNotEmpty)
        'identifiers': [
          for (final identifier in identifiers) identifier.toJson()
        ],
      if (externalLinks.isNotEmpty) 'external_links': externalLinks,
      if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
      if (currency != null) 'currency': currency,
    };
    return payload;
  }

  ComicCatalogItem copyWith({
    CatalogItemRef? id,
    String? title,
    String? displayTitle,
    String? sortTitle,
    String? seriesTitle,
    String? seriesId,
    String? seriesGroup,
    List<String>? seriesTags,
    String? volumeName,
    String? volumeNumber,
    int? volumeStartYear,
    String? issueNumber,
    String? publisher,
    String? imprint,
    DateTime? releaseDate,
    DateTime? coverDate,
    PartialDate? coverDateParts,
    PartialDate? releaseDateParts,
    int? pageCount,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
    String? crossover,
    List<String>? genres,
    List<String>? searchAliases,
    String? synopsis,
    String? description,
    String? subtitle,
    String? localizedTitle,
    String? originalTitle,
    String? plotDescription,
    String? plotSummary,
    String? releaseStatus,
    List<ComicCreator>? contributors,
    List<ComicCharacter>? characters,
    List<ComicCharacter>? characterDetails,
    List<ComicCreator>? creators,
    List<ComicStoryArc>? storyArcs,
    List<ComicKeyEvent>? keyEvents,
    bool? isKeyComic,
    String? keyReason,
    String? variant,
    String? variantDescription,
    String? barcode,
    String? catalogNumber,
    int? coverPriceCents,
    String? currency,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    String? editionTitle,
    String? titleExtension,
    String? physicalFormat,
    List<ComicIdentifier>? identifiers,
    List<ComicLink>? links,
  }) {
    return ComicCatalogItem(
      id: id ?? this.id,
      title: title ?? this.title,
      displayTitle: displayTitle ?? this.displayTitle,
      sortTitle: sortTitle ?? this.sortTitle,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      seriesId: seriesId ?? this.seriesId,
      seriesGroup: seriesGroup ?? this.seriesGroup,
      seriesTags: seriesTags ?? this.seriesTags,
      volumeName: volumeName ?? this.volumeName,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      volumeStartYear: volumeStartYear ?? this.volumeStartYear,
      issueNumber: issueNumber ?? this.issueNumber,
      publisher: publisher ?? this.publisher,
      imprint: imprint ?? this.imprint,
      releaseDate: releaseDate ?? this.releaseDate,
      coverDate: coverDate ?? this.coverDate,
      coverDateParts: coverDateParts ?? this.coverDateParts,
      releaseDateParts: releaseDateParts ?? this.releaseDateParts,
      pageCount: pageCount ?? this.pageCount,
      country: country ?? this.country,
      language: language ?? this.language,
      ageRating: ageRating ?? this.ageRating,
      audienceRating: audienceRating ?? this.audienceRating,
      crossover: crossover ?? this.crossover,
      genres: genres ?? this.genres,
      searchAliases: searchAliases ?? this.searchAliases,
      synopsis: synopsis ?? this.synopsis,
      description: description ?? this.description,
      subtitle: subtitle ?? this.subtitle,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      originalTitle: originalTitle ?? this.originalTitle,
      plotDescription: plotDescription ?? this.plotDescription,
      plotSummary: plotSummary ?? this.plotSummary,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      contributors: contributors ?? this.contributors,
      characters: characters ?? this.characters,
      characterDetails: characterDetails ?? this.characterDetails,
      creators: creators ?? this.creators,
      storyArcs: storyArcs ?? this.storyArcs,
      keyEvents: keyEvents ?? this.keyEvents,
      isKeyComic: isKeyComic ?? this.isKeyComic,
      keyReason: keyReason ?? this.keyReason,
      variant: variant ?? this.variant,
      variantDescription: variantDescription ?? this.variantDescription,
      barcode: barcode ?? this.barcode,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      coverPriceCents: coverPriceCents ?? this.coverPriceCents,
      currency: currency ?? this.currency,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      editionTitle: editionTitle ?? this.editionTitle,
      titleExtension: titleExtension ?? this.titleExtension,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      identifiers: identifiers ?? this.identifiers,
      links: links ?? this.links,
    );
  }

  factory ComicCatalogItem.fromJson(Map<String, dynamic> json) {
    return ComicCatalogItem(
      id: json['id'] is String && (json['id'] as String).isNotEmpty
          ? CatalogItemRef(
              kind: CatalogMediaKind.comic,
              id: json['id'] as String,
            )
          : null,
      title: (json['title'] as String?) ?? '',
      displayTitle: json['display_title'] as String?,
      sortTitle: json['sort_key'] as String?,
      seriesTitle: json['series_title'] as String?,
      seriesId: json['series_id'] as String?,
      seriesGroup: json['series_group'] as String?,
      seriesTags: _comicStringList(json['series_tags'], 'series_tags'),
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number'] as String?,
      volumeStartYear: (json['volume_start_year'] as num?)?.toInt(),
      issueNumber: json['issue_number'] as String?,
      publisher: json['publisher'] as String?,
      imprint: json['imprint'] as String?,
      releaseDate: _comicDate(json['release_date']),
      releaseDateParts: PartialDate.tryParse(json['release_date_parts']),
      coverDate: PartialDate.tryParse(json['cover_date'])?.asDateTime,
      coverDateParts: PartialDate.tryParse(json['cover_date']),
      pageCount: (json['page_count'] as num?)?.toInt(),
      country: (json['country'] as String?) ?? 'US',
      language: (json['language'] as String?) ?? 'en',
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
      crossover: json['crossover'] as String?,
      genres: _comicStringList(json['genres'], 'genres'),
      searchAliases: _comicStringList(json['search_aliases'], 'search_aliases'),
      synopsis: json['synopsis'] as String?,
      description: json['description'] as String?,
      subtitle: json['subtitle'] as String?,
      localizedTitle: json['localized_title'] as String?,
      originalTitle: json['original_title'] as String?,
      plotDescription: json['plot_description'] as String?,
      plotSummary: json['plot_summary'] as String?,
      releaseStatus: json['release_status'] as String?,
      contributors: _comicChildList<ComicCreator>(
        json['contributors'],
        'contributors',
        ComicCreator.fromValue,
        allowStrings: true,
      ),
      characters: _comicChildList<ComicCharacter>(
        json['characters'],
        'characters',
        ComicCharacter.fromValue,
        allowStrings: true,
      ),
      characterDetails: _comicChildList<ComicCharacter>(
        json['character_details'],
        'character_details',
        ComicCharacter.fromValue,
        allowStrings: false,
      ),
      creators: _comicChildList<ComicCreator>(
        json['creators'],
        'creators',
        ComicCreator.fromValue,
        allowStrings: true,
      ),
      storyArcs: _comicChildList<ComicStoryArc>(
        json['story_arcs'],
        'story_arcs',
        ComicStoryArc.fromValue,
        allowStrings: true,
      ),
      keyEvents: _comicChildList<ComicKeyEvent>(
        json['key_events'],
        'key_events',
        (value) =>
            ComicKeyEvent.fromJson(Map<String, dynamic>.from(value as Map)),
        allowStrings: false,
      ),
      isKeyComic: json['is_key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      variant: json['variant_name'] as String?,
      variantDescription: json['variant_description'] as String?,
      barcode: json['barcode'] as String?,
      catalogNumber: json['catalog_number'] as String?,
      coverPriceCents: (json['cover_price_cents'] as num?)?.toInt(),
      currency: json['currency'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      editionTitle: json['edition_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      physicalFormat: json['physical_format'] as String?,
      identifiers: _comicChildList<ComicIdentifier>(
        json['identifiers'],
        'identifiers',
        ComicIdentifier.fromValue,
        allowStrings: true,
      ),
      links: _comicChildList<ComicLink>(
        json['external_links'],
        'external_links',
        (value) => ComicLink.fromJson(Map<String, dynamic>.from(value as Map)),
        allowStrings: false,
      ),
    );
  }
}

List<String> _comicStringList(Object? value, String field) {
  if (value == null) return const [];
  if (value is! List || value.any((entry) => entry is! String)) {
    throw FormatException('Comic $field must be a list of strings.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

List<T> _comicChildList<T>(
  Object? value,
  String field,
  T Function(Object value) decode, {
  required bool allowStrings,
}) {
  if (value == null) return List<T>.empty(growable: false);
  if (value is! List) {
    throw FormatException('Comic $field must be a list.');
  }
  return List<T>.unmodifiable([
    for (final child in value)
      if (child is Map || allowStrings && child is String)
        decode(child as Object)
      else
        throw FormatException('Comic $field contains an invalid value.'),
  ]);
}

DateTime? _comicDate(Object? value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is! Map) return null;
  final year = int.tryParse(value['year']?.toString() ?? '');
  if (year == null) return null;
  final month = int.tryParse(value['month']?.toString() ?? '');
  final day = int.tryParse(value['day']?.toString() ?? '');
  return DateTime(year, month ?? 1, day ?? 1);
}
