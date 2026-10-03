import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_link.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
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
    final type = ComicKeyEventType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => ComicKeyEventType.other,
    );
    return ComicKeyEvent(
      type: type,
      characterOrSubject: (json['character_or_subject'] as String?) ?? '',
      description: json['description'] as String?,
    );
  }
}

@immutable
class ComicCreatorCredit {
  const ComicCreatorCredit({
    required this.name,
    required this.role,
  });

  final String name;
  final String role;

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
      };

  factory ComicCreatorCredit.fromJson(Map<String, dynamic> json) {
    return ComicCreatorCredit(
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
    );
  }
}

@immutable
class ComicCatalogItem implements JsonEncodable {
  const ComicCatalogItem({
    this.id,
    required this.title,
    this.sortTitle,
    this.seriesTitle,
    this.issueNumber,
    this.publisher,
    this.imprint,
    this.releaseDate,
    this.coverDate,
    this.coverDateParts,
    this.pageCount,
    this.country = 'US',
    this.language = 'en',
    this.ageRating,
    this.crossover,
    this.genres = const [],
    this.searchAliases = const [],
    this.synopsis,
    this.writers = const [],
    this.artists = const [],
    this.inkers = const [],
    this.colorists = const [],
    this.letterers = const [],
    this.editors = const [],
    this.coverArtists = const [],
    this.creatorCredits = const [],
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
    this.series,
    this.publishing,
    this.editionTitle,
    this.titleExtension,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.identifiers = const [],
    this.links = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.comic;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final ComicCatalogItemId? id;
  final String? sortTitle;
  final String? seriesTitle;
  final String? issueNumber;
  final String? publisher;
  final String? imprint;
  final DateTime? releaseDate;
  final DateTime? coverDate;
  final PartialDate? coverDateParts;
  final int? pageCount;
  final String country;
  final String language;
  final String? ageRating;
  final String? crossover;
  final List<String> genres;
  final List<String> searchAliases;
  final String? synopsis;
  final List<String> writers;
  final List<String> artists;
  final List<String> inkers;
  final List<String> colorists;
  final List<String> letterers;
  final List<String> editors;
  final List<String> coverArtists;
  final List<ComicCreatorCredit> creatorCredits;
  final List<String> characters;
  final List<Map<String, dynamic>> characterDetails;
  final List<Map<String, dynamic>> creators;
  final List<ComicStoryArc> storyArcs;
  final List<ComicKeyEvent> keyEvents;
  final bool isKeyComic;
  final String? keyReason;
  final String? variant;
  final String? variantDescription;
  final String? barcode;
  final CatalogSeriesDetailsDto? series;
  final CatalogPublishingDetailsDto? publishing;
  final String? editionTitle;
  final String? titleExtension;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<ComicIdentifier> identifiers;
  final List<ComicLink> links;
  final Map<String, dynamic> rawPayload;

  String? get coverImageUrl => _comicText(rawPayload['cover_image_url']);
  String? get thumbnailImageUrl =>
      _comicText(rawPayload['thumbnail_image_url']) ?? coverImageUrl;
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
    final contributors = <Map<String, dynamic>>[
      for (final credit in creatorCredits) credit.toJson(),
      ..._comicCredits(writers, 'writer'),
      ..._comicCredits(artists, 'artist'),
      ..._comicCredits(inkers, 'inker'),
      ..._comicCredits(colorists, 'colorist'),
      ..._comicCredits(letterers, 'letterer'),
      ..._comicCredits(editors, 'editor'),
      ..._comicCredits(coverArtists, 'cover artist'),
    ];
    final externalLinks = [
      for (final link in links)
        if (link.isExternalLink) link.toJson(),
    ];
    final payload = <String, dynamic>{
      ...rawPayload,
      'kind': CatalogMediaKind.comic.apiValue,
      if (id != null) 'id': id!.value,
      'title': title,
      if (sortTitle != null) 'sort_key': sortTitle,
      if (seriesTitle != null) 'series_title': seriesTitle,
      if (issueNumber != null) ...{
        'issue_number': issueNumber,
        'item_number': issueNumber,
      },
      if (publisher != null) 'publisher': publisher,
      if (imprint != null) 'imprint': imprint,
      if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
      if (coverDateParts != null)
        'cover_date': coverDateParts!.toJson()
      else if (coverDate != null)
        'cover_date': coverDate!.toIso8601String(),
      if (pageCount != null) 'page_count': pageCount,
      'country': country,
      'language': language,
      if (ageRating != null) 'age_rating': ageRating,
      if (crossover != null) 'crossover': crossover,
      if (genres.isNotEmpty) 'genres': genres,
      if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
      if (synopsis != null) 'synopsis': synopsis,
      if (characters.isNotEmpty) 'characters': characters,
      if (characterDetails.isNotEmpty) 'character_details': characterDetails,
      if (contributors.isNotEmpty) 'contributors': contributors,
      if (creators.isNotEmpty) 'creators': creators,
      if (storyArcs.isNotEmpty)
        'story_arcs': [for (final arc in storyArcs) arc.toJsonValue()],
      if (keyEvents.isNotEmpty)
        'key_events': [for (final event in keyEvents) event.toJson()],
      if (isKeyComic) 'key_comic': true,
      if (keyReason != null) 'key_reason': keyReason,
      if (variant != null) 'variant_name': variant,
      if (variantDescription != null) 'variant_description': variantDescription,
      if (barcode != null) 'barcode': barcode,
      if (editionTitle != null) 'edition_title': editionTitle,
      if (titleExtension != null) 'title_extension': titleExtension,
      if (physicalFormat != null || physicalFormatLabel != null)
        'physical_format': physicalFormat ?? physicalFormatLabel,
      if (identifiers.isNotEmpty)
        'identifiers': [
          for (final identifier in identifiers) identifier.toJson()
        ],
      if (externalLinks.isNotEmpty) 'external_links': externalLinks,
      if (series?.tags?.isNotEmpty == true) 'series_tags': series!.tags,
      if (series?.volumeName != null) 'volume_name': series!.volumeName,
      if (series?.volumeNumber != null) 'volume_number': series!.volumeNumber,
      if (series?.volumeStartYear != null)
        'volume_start_year': series!.volumeStartYear,
      if (publishing?.seriesGroup != null)
        'series_group': publishing!.seriesGroup,
      if (publishing?.coverPriceCents != null)
        'cover_price_cents': publishing!.coverPriceCents,
      if (publishing?.currency != null) 'currency': publishing!.currency,
    };
    return payload;
  }

  ComicCatalogItem copyWith({
    ComicCatalogItemId? id,
    String? title,
    String? sortTitle,
    String? seriesTitle,
    String? issueNumber,
    String? publisher,
    String? imprint,
    DateTime? releaseDate,
    DateTime? coverDate,
    PartialDate? coverDateParts,
    int? pageCount,
    String? country,
    String? language,
    String? ageRating,
    String? crossover,
    List<String>? genres,
    List<String>? searchAliases,
    String? synopsis,
    List<String>? writers,
    List<String>? artists,
    List<String>? inkers,
    List<String>? colorists,
    List<String>? letterers,
    List<String>? editors,
    List<String>? coverArtists,
    List<ComicCreatorCredit>? creatorCredits,
    List<String>? characters,
    List<Map<String, dynamic>>? characterDetails,
    List<Map<String, dynamic>>? creators,
    List<ComicStoryArc>? storyArcs,
    List<ComicKeyEvent>? keyEvents,
    bool? isKeyComic,
    String? keyReason,
    String? variant,
    String? variantDescription,
    String? barcode,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    String? editionTitle,
    String? titleExtension,
    String? physicalFormat,
    String? physicalFormatLabel,
    List<ComicIdentifier>? identifiers,
    List<ComicLink>? links,
  }) {
    return ComicCatalogItem(
      id: id ?? this.id,
      title: title ?? this.title,
      sortTitle: sortTitle ?? this.sortTitle,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      issueNumber: issueNumber ?? this.issueNumber,
      publisher: publisher ?? this.publisher,
      imprint: imprint ?? this.imprint,
      releaseDate: releaseDate ?? this.releaseDate,
      coverDate: coverDate ?? this.coverDate,
      coverDateParts: coverDateParts ?? this.coverDateParts,
      pageCount: pageCount ?? this.pageCount,
      country: country ?? this.country,
      language: language ?? this.language,
      ageRating: ageRating ?? this.ageRating,
      crossover: crossover ?? this.crossover,
      genres: genres ?? this.genres,
      searchAliases: searchAliases ?? this.searchAliases,
      synopsis: synopsis ?? this.synopsis,
      writers: writers ?? this.writers,
      artists: artists ?? this.artists,
      inkers: inkers ?? this.inkers,
      colorists: colorists ?? this.colorists,
      letterers: letterers ?? this.letterers,
      editors: editors ?? this.editors,
      coverArtists: coverArtists ?? this.coverArtists,
      creatorCredits: creatorCredits ?? this.creatorCredits,
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
      series: series ?? this.series,
      publishing: publishing ?? this.publishing,
      editionTitle: editionTitle ?? this.editionTitle,
      titleExtension: titleExtension ?? this.titleExtension,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      identifiers: identifiers ?? this.identifiers,
      links: links ?? this.links,
      rawPayload: rawPayload,
    );
  }

  factory ComicCatalogItem.fromJson(Map<String, dynamic> json) {
    final rawLinks = <ComicLink>[
      ...((json['trailer_urls'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicLink.fromJson) ??
          const <ComicLink>[]),
      ...((json['external_links'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicLink.fromJson) ??
          const <ComicLink>[]),
    ];

    final seriesMap = json['series'] as Map<String, dynamic>?;
    final series = seriesMap != null
        ? CatalogSeriesDetailsDto.fromJson(seriesMap)
        : CatalogSeriesDetailsDto.fromJson(json);

    final pubMap = json['publishing'] as Map<String, dynamic>?;
    final publishing = pubMap != null
        ? CatalogPublishingDetailsDto.fromJson(pubMap)
        : CatalogPublishingDetailsDto.fromJson(json);

    final rawContributorValues =
        json['contributors'] as List<dynamic>? ?? const <dynamic>[];
    final creatorCredits = <ComicCreatorCredit>[];
    for (final contributor in rawContributorValues) {
      if (contributor is Map<String, dynamic>) {
        final credit = ComicCreatorCredit.fromJson(contributor);
        if (credit.name.isNotEmpty) creatorCredits.add(credit);
      } else {
        final name = contributor?.toString().trim();
        if (name != null && name.isNotEmpty) {
          creatorCredits.add(
            ComicCreatorCredit(name: name, role: 'contributor'),
          );
        }
      }
    }

    final rawCreators = (json['creators'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: true) ??
        <Map<String, dynamic>>[];

    final rawCharDetails = (json['character_details'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList(growable: false) ??
        const <Map<String, dynamic>>[];

    return ComicCatalogItem(
      id: json['id'] is String && (json['id'] as String).isNotEmpty
          ? ComicCatalogItemId(json['id'] as String)
          : null,
      title: (json['title'] as String?) ?? '',
      sortTitle: (json['sort_key'] ?? json['sort_title']) as String?,
      rawPayload: Map<String, dynamic>.from(json),
      seriesTitle: (json['series_title'] ?? series.seriesTitle) as String?,
      issueNumber: (json['issue_number'] ?? json['item_number']) as String?,
      publisher: (json['publisher'] ?? publishing.originalPublisher) as String?,
      imprint: (json['imprint'] ?? publishing.imprint) as String?,
      releaseDate: _comicDate(json['release_date']) ??
          _comicDate(json['release_date_parts']),
      coverDate: PartialDate.tryParse(json['cover_date'])?.asDateTime,
      coverDateParts: PartialDate.tryParse(json['cover_date']),
      pageCount: (json['page_count'] ?? publishing.pageCount) as int?,
      country: (json['country'] as String?) ?? 'US',
      language: (json['language'] as String?) ?? 'en',
      ageRating: json['age_rating'] as String?,
      crossover: json['crossover'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      searchAliases: (json['search_aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      writers: (json['writers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      inkers: (json['inkers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      colorists: (json['colorists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      letterers: (json['letterers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      editors: (json['editors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coverArtists: (json['cover_artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      creatorCredits: creatorCredits,
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      characterDetails: rawCharDetails,
      creators: rawCreators,
      storyArcs:
          (json['story_arcs'] as List<dynamic>?)?.map<ComicStoryArc>((value) {
                if (value is! Map && value is! String) {
                  throw const FormatException(
                    'Comic story arcs must be strings or objects.',
                  );
                }
                return ComicStoryArc.fromValue(value as Object);
              }).toList(growable: false) ??
              const <ComicStoryArc>[],
      keyEvents: (json['key_events'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ComicKeyEvent.fromJson)
              .toList() ??
          const [],
      isKeyComic: json['is_key_comic'] as bool? ?? false,
      keyReason: json['key_reason'] as String?,
      variant: json['variant_name'] as String?,
      variantDescription: json['variant_description'] as String?,
      barcode: json['barcode'] as String?,
      series: series.hasData ? series : null,
      publishing: publishing.hasData ? publishing : null,
      editionTitle: json['edition_title'] as String?,
      titleExtension: json['title_extension'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      identifiers: (json['identifiers'] as List<dynamic>?)
              ?.map<ComicIdentifier>((value) {
                if (value is! Map && value is! String) {
                  throw const FormatException(
                    'Comic identifiers must be strings or objects.',
                  );
                }
                return ComicIdentifier.fromValue(value as Object);
              })
              .where((identifier) => identifier.value.trim().isNotEmpty)
              .toList(growable: false) ??
          const <ComicIdentifier>[],
      links: rawLinks,
    );
  }
}

String? _comicText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
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

List<Map<String, dynamic>> _comicCredits(
  Iterable<String> names,
  String role,
) =>
    [
      for (final name in names)
        if (name.trim().isNotEmpty) {'name': name.trim(), 'role': role},
    ];
