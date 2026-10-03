import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

enum MangaDemographic {
  shonen('Shonen'),
  shojo('Shojo'),
  seinen('Seinen'),
  josei('Josei'),
  kodomo('Kodomo'),
  other('Other');

  const MangaDemographic(this.label);
  final String label;

  static MangaDemographic fromString(String? value) {
    if (value == null) return MangaDemographic.other;
    final normalized = value.trim().toLowerCase();
    return MangaDemographic.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaDemographic.other,
    );
  }
}

enum MangaPublicationStatus {
  ongoing('Ongoing'),
  completed('Completed'),
  hiatus('On Hiatus'),
  cancelled('Cancelled'),
  upcoming('Upcoming');

  const MangaPublicationStatus(this.label);
  final String label;

  static MangaPublicationStatus fromString(String? value) {
    if (value == null) return MangaPublicationStatus.ongoing;
    final normalized = value.trim().toLowerCase();
    return MangaPublicationStatus.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaPublicationStatus.ongoing,
    );
  }
}

enum MangaEditionFormat {
  tankobon('Tankobon'),
  bunkoban('Bunkoban'),
  kanzenban('Kanzenban'),
  omnibus('Omnibus'),
  hardcover('Hardcover'),
  digital('Digital'),
  other('Other');

  const MangaEditionFormat(this.label);
  final String label;

  static MangaEditionFormat fromString(String? value) {
    if (value == null) return MangaEditionFormat.tankobon;
    final normalized = value.trim().toLowerCase();
    return MangaEditionFormat.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaEditionFormat.tankobon,
    );
  }
}

enum MangaReadingDirection {
  rightToLeft('Right to Left'),
  leftToRight('Left to Right');

  const MangaReadingDirection(this.label);
  final String label;

  static MangaReadingDirection fromString(String? value) {
    if (value == null) return MangaReadingDirection.rightToLeft;
    final normalized = value.trim().toLowerCase();
    return MangaReadingDirection.values.firstWhere(
      (e) => e.name == normalized || e.label.toLowerCase() == normalized,
      orElse: () => MangaReadingDirection.rightToLeft,
    );
  }
}

@immutable
final class MangaChapter implements JsonEncodable {
  const MangaChapter({
    this.id,
    this.chapterNumber,
    this.pageCount,
    this.position,
    this.releaseDate,
    this.title,
  });

  final String? id;
  final int? chapterNumber;
  final int? pageCount;
  final int? position;
  final PartialDate? releaseDate;
  final String? title;

  factory MangaChapter.fromJson(Map<String, dynamic> json) => MangaChapter(
        id: json['id'] as String?,
        chapterNumber: (json['chapter_number'] as num?)?.toInt(),
        pageCount: (json['page_count'] as num?)?.toInt(),
        position: (json['position'] as num?)?.toInt(),
        releaseDate: PartialDate.tryParse(json['release_date']),
        title: json['title'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (chapterNumber != null) 'chapter_number': chapterNumber,
        if (pageCount != null) 'page_count': pageCount,
        if (position != null) 'position': position,
        if (releaseDate != null) 'release_date': releaseDate!.toJson(),
        if (title != null) 'title': title,
      };
}

@immutable
final class MangaCharacter implements JsonEncodable {
  const MangaCharacter({
    required this.name,
    this.id,
    this.characterId,
    this.role,
    this.description,
    this.imageUrl,
    this.aliases = const [],
    this.plainValue = false,
  });

  final String name;
  final String? id;
  final String? characterId;
  final String? role;
  final String? description;
  final String? imageUrl;
  final List<String> aliases;
  final bool plainValue;

  factory MangaCharacter.fromJsonValue(Object? value) {
    if (value is String) {
      return MangaCharacter(name: value, plainValue: true);
    }
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Manga characters must be names or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    return MangaCharacter(
      name: json['name'] as String? ?? '',
      id: json['id'] as String?,
      characterId: json['character_id'] as String?,
      role: json['role'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      aliases: _stringList(json['aliases']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        if (id != null) 'id': id,
        if (characterId != null) 'character_id': characterId,
        if (role != null) 'role': role,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        if (aliases.isNotEmpty) 'aliases': aliases,
      };

  Object toJsonValue() => plainValue ? name : toJson();
}

@immutable
final class MangaCredit implements JsonEncodable {
  const MangaCredit({
    this.artistId,
    this.creditedName,
    this.id,
    this.imageUrl,
    this.instrument,
    this.joinPhrase,
    this.name,
    this.personId,
    this.role,
    this.roleId,
    this.sequence,
    this.sortName,
  });

  final String? artistId;
  final String? creditedName;
  final String? id;
  final String? imageUrl;
  final String? instrument;
  final String? joinPhrase;
  final String? name;
  final String? personId;
  final String? role;
  final String? roleId;
  final int? sequence;
  final String? sortName;

  factory MangaCredit.fromJsonValue(Object? value) {
    if (value is String) return MangaCredit(name: value);
    if (value is! Map<Object?, Object?>) {
      throw const FormatException('Manga credits must be names or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    return MangaCredit(
      artistId: json['artist_id'] as String?,
      creditedName: json['credited_name'] as String?,
      id: json['id'] as String?,
      imageUrl: json['image_url'] as String?,
      instrument: json['instrument'] as String?,
      joinPhrase: json['join_phrase'] as String?,
      name: json['name'] as String?,
      personId: json['person_id'] as String?,
      role: json['role'] as String?,
      roleId: json['role_id'] as String?,
      sequence: (json['sequence'] as num?)?.toInt(),
      sortName: json['sort_name'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (artistId != null) 'artist_id': artistId,
        if (creditedName != null) 'credited_name': creditedName,
        if (id != null) 'id': id,
        if (imageUrl != null) 'image_url': imageUrl,
        if (instrument != null) 'instrument': instrument,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (name != null) 'name': name,
        if (personId != null) 'person_id': personId,
        if (role != null) 'role': role,
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (sortName != null) 'sort_name': sortName,
      };
}

@immutable
final class MangaExternalLink implements JsonEncodable {
  const MangaExternalLink({
    required this.url,
    this.id,
    this.description,
    this.kind,
    this.label,
    this.linkType,
    this.name,
    this.position,
    this.site,
    this.title,
  });

  final String url;
  final String? id;
  final String? description;
  final String? kind;
  final String? label;
  final String? linkType;
  final String? name;
  final int? position;
  final String? site;
  final String? title;

  factory MangaExternalLink.fromJson(Map<String, dynamic> json) {
    final url = json['url'];
    if (url is! String || url.trim().isEmpty) {
      throw const FormatException('Manga external links require a URL.');
    }
    return MangaExternalLink(
      url: url,
      id: json['id'] as String?,
      description: json['description'] as String?,
      kind: json['kind'] as String?,
      label: json['label'] as String?,
      linkType: json['link_type'] as String?,
      name: json['name'] as String?,
      position: (json['position'] as num?)?.toInt(),
      site: json['site'] as String?,
      title: json['title'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'url': url,
        if (id != null) 'id': id,
        if (description != null) 'description': description,
        if (kind != null) 'kind': kind,
        if (label != null) 'label': label,
        if (linkType != null) 'link_type': linkType,
        if (name != null) 'name': name,
        if (position != null) 'position': position,
        if (site != null) 'site': site,
        if (title != null) 'title': title,
      };
}

@immutable
final class MangaIdentifier implements JsonEncodable {
  const MangaIdentifier({
    required this.identifierType,
    required this.value,
    this.id,
    this.normalizedValue,
    this.isPrimary,
    this.plainValue = false,
  });

  final String identifierType;
  final String value;
  final String? id;
  final String? normalizedValue;
  final bool? isPrimary;
  final bool plainValue;

  factory MangaIdentifier.fromJsonValue(Object? value) {
    if (value is String) {
      return MangaIdentifier(
        identifierType: 'isbn',
        value: value,
        plainValue: true,
      );
    }
    if (value is! Map<Object?, Object?>) {
      throw const FormatException(
          'Manga identifiers must be strings or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    final identifierType = json['identifier_type'];
    final identifierValue = json['value'];
    if (identifierType is! String || identifierType.trim().isEmpty) {
      throw const FormatException('Manga identifier type must not be empty.');
    }
    if (identifierValue is! String || identifierValue.trim().isEmpty) {
      throw const FormatException('Manga identifier value must not be empty.');
    }
    return MangaIdentifier(
      identifierType: identifierType,
      value: identifierValue,
      id: json['id'] as String?,
      normalizedValue: json['normalized_value'] as String?,
      isPrimary: json['is_primary'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'identifier_type': identifierType,
        'value': value,
        if (id != null) 'id': id,
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        if (isPrimary != null) 'is_primary': isPrimary,
      };

  Object toJsonValue() => plainValue ? value : toJson();
}

@immutable
class MangaMetadata implements JsonEncodable {
  const MangaMetadata({
    this.title = '',
    this.nativeTitle,
    this.romajiTitle,
    this.englishTitle,
    this.alternateTitles = const [],
    this.authors = const [],
    this.artists = const [],
    this.demographic = MangaDemographic.other,
    this.serializationPlatform,
    this.publicationStatus = MangaPublicationStatus.ongoing,
    this.originalPublisher,
    this.localizedPublisher,
    this.volumeNumber,
    this.totalVolumes,
    this.chapterCount,
    this.originalPublicationDate,
    this.localizedReleaseDate,
    this.isbn,
    this.editionFormat = MangaEditionFormat.tankobon,
    this.language = 'ja',
    this.country = 'JP',
    this.genres = const [],
    this.themes = const [],
    this.translator,
    this.readingDirection = MangaReadingDirection.rightToLeft,
    this.relations = const [],
    this.seriesTitle,
    this.volumeName,
    this.editionTitle,
    this.pageCount,
    this.imprint,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.publisher,
    this.barcode,
    this.variant,
    this.creators = const [],
    this.sortKey,
    this.ageRating,
    this.audienceRating,
    this.catalogNumber,
    this.chapters = const [],
    this.characters = const [],
    this.characterDetails = const [],
    this.contributors = const [],
    this.coverImageUrl,
    this.backCoverImageUrl,
    this.crossover,
    this.description,
    this.externalLinks = const [],
    this.identifiers = const [],
    this.itemNumber,
    this.localizedTitle,
    this.originalTitle,
    this.searchAliases = const [],
    this.plotDescription,
    this.plotSummary,
    this.releaseDate,
    this.releaseDateParts,
    this.releaseStatus,
    this.seriesGroup,
    this.seriesTags = const [],
    this.subtitle,
    this.synopsis,
    this.thumbnailImageUrl,
    this.titleExtension,
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.manga;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? nativeTitle;
  final String? romajiTitle;
  final String? englishTitle;
  final List<String> alternateTitles;
  final List<String> authors;
  final List<String> artists;
  final MangaDemographic demographic;
  final String? serializationPlatform;
  final MangaPublicationStatus publicationStatus;
  final String? originalPublisher;
  final String? localizedPublisher;
  final int? volumeNumber;
  final int? totalVolumes;
  final int? chapterCount;
  final DateTime? originalPublicationDate;
  final DateTime? localizedReleaseDate;
  final String? isbn;
  final MangaEditionFormat editionFormat;
  final String language;
  final String country;
  final List<String> genres;
  final List<String> themes;
  final String? translator;
  final MangaReadingDirection readingDirection;
  final List<String> relations;
  final String? seriesTitle;
  final String? volumeName;
  final String? editionTitle;
  final int? pageCount;
  final String? imprint;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? publisher;
  final String? barcode;
  final String? variant;
  final List<MangaCredit> creators;
  final String? sortKey;
  final String? ageRating;
  final String? audienceRating;
  final String? catalogNumber;
  final List<MangaChapter> chapters;
  final List<MangaCharacter> characters;
  final List<MangaCharacter> characterDetails;
  final List<MangaCredit> contributors;
  final String? coverImageUrl;
  final String? backCoverImageUrl;
  final String? crossover;
  final String? description;
  final List<MangaExternalLink> externalLinks;
  final List<MangaIdentifier> identifiers;
  final String? itemNumber;
  final String? localizedTitle;
  final String? originalTitle;
  final List<String> searchAliases;
  final String? plotDescription;
  final String? plotSummary;
  final PartialDate? releaseDate;
  final PartialDate? releaseDateParts;
  final String? releaseStatus;
  final String? seriesGroup;
  final List<String> seriesTags;
  final String? subtitle;
  final String? synopsis;
  final String? thumbnailImageUrl;
  final String? titleExtension;

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        if (nativeTitle != null) 'native_title': nativeTitle,
        if (romajiTitle != null) 'romaji_title': romajiTitle,
        if (englishTitle != null) 'english_title': englishTitle,
        if (alternateTitles.isNotEmpty) 'alternate_titles': alternateTitles,
        if (authors.isNotEmpty) 'authors': authors,
        if (artists.isNotEmpty) 'artists': artists,
        'demographic': demographic.name,
        if (serializationPlatform != null)
          'serialization_platform': serializationPlatform,
        'publication_status': publicationStatus.name,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (localizedPublisher != null)
          'localized_publisher': localizedPublisher,
        if (volumeNumber != null) 'volume_number': volumeNumber.toString(),
        if (totalVolumes != null) 'total_volumes': totalVolumes,
        if (chapterCount != null) 'chapter_count': chapterCount,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (localizedReleaseDate != null)
          'localized_release_date': localizedReleaseDate!.toIso8601String(),
        if (isbn != null) 'isbn': isbn,
        'edition_format': editionFormat.name,
        'language': language,
        'country': country,
        if (genres.isNotEmpty) 'genres': genres,
        if (themes.isNotEmpty) 'themes': themes,
        if (translator != null) 'translator': translator,
        'reading_direction': readingDirection.name,
        if (relations.isNotEmpty) 'relations': relations,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (volumeName != null) 'volume_name': volumeName,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (pageCount != null) 'page_count': pageCount,
        if (imprint != null) 'imprint': imprint,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (publisher != null) 'publisher': publisher,
        if (barcode != null) 'barcode': barcode,
        if (variant != null) 'variant_name': variant,
        if (creators.isNotEmpty)
          'creators': creators.map((value) => value.toJson()).toList(),
        if (sortKey != null) 'sort_key': sortKey,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (chapters.isNotEmpty)
          'chapters': chapters.map((value) => value.toJson()).toList(),
        if (characters.isNotEmpty)
          'characters': characters.map((value) => value.toJsonValue()).toList(),
        if (characterDetails.isNotEmpty)
          'character_details':
              characterDetails.map((value) => value.toJson()).toList(),
        if (contributors.isNotEmpty)
          'contributors': contributors.map((value) => value.toJson()).toList(),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (backCoverImageUrl != null)
          'back_cover_image_url': backCoverImageUrl,
        if (crossover != null) 'crossover': crossover,
        if (description != null) 'description': description,
        if (externalLinks.isNotEmpty)
          'external_links':
              externalLinks.map((value) => value.toJson()).toList(),
        if (identifiers.isNotEmpty)
          'identifiers':
              identifiers.map((value) => value.toJsonValue()).toList(),
        if (itemNumber != null) 'item_number': itemNumber,
        if (localizedTitle != null) 'localized_title': localizedTitle,
        if (originalTitle != null) 'original_title': originalTitle,
        if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
        if (plotDescription != null) 'plot_description': plotDescription,
        if (plotSummary != null) 'plot_summary': plotSummary,
        if (releaseDateParts != null)
          'release_date_parts': releaseDateParts!.toJson(),
        if (releaseDate != null) 'release_date': releaseDate!.toJson(),
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (seriesGroup != null) 'series_group': seriesGroup,
        if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
        if (subtitle != null) 'subtitle': subtitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (titleExtension != null) 'title_extension': titleExtension,
      };

  MangaMetadata copyWith({
    String? title,
    String? nativeTitle,
    String? romajiTitle,
    String? englishTitle,
    List<String>? alternateTitles,
    List<String>? authors,
    List<String>? artists,
    MangaDemographic? demographic,
    String? serializationPlatform,
    MangaPublicationStatus? publicationStatus,
    String? originalPublisher,
    String? localizedPublisher,
    int? volumeNumber,
    int? totalVolumes,
    int? chapterCount,
    DateTime? originalPublicationDate,
    DateTime? localizedReleaseDate,
    String? isbn,
    MangaEditionFormat? editionFormat,
    String? language,
    String? country,
    List<String>? genres,
    List<String>? themes,
    String? translator,
    MangaReadingDirection? readingDirection,
    List<String>? relations,
    String? seriesTitle,
    String? volumeName,
    String? editionTitle,
    int? pageCount,
    String? imprint,
    String? physicalFormat,
    String? physicalFormatLabel,
    String? publisher,
    String? barcode,
    String? variant,
    List<MangaCredit>? creators,
    String? sortKey,
    String? ageRating,
    String? audienceRating,
    String? catalogNumber,
    List<MangaChapter>? chapters,
    List<MangaCharacter>? characters,
    List<MangaCharacter>? characterDetails,
    List<MangaCredit>? contributors,
    String? coverImageUrl,
    String? backCoverImageUrl,
    String? crossover,
    String? description,
    List<MangaExternalLink>? externalLinks,
    List<MangaIdentifier>? identifiers,
    String? itemNumber,
    String? localizedTitle,
    String? originalTitle,
    List<String>? searchAliases,
    String? plotDescription,
    String? plotSummary,
    PartialDate? releaseDate,
    PartialDate? releaseDateParts,
    String? releaseStatus,
    String? seriesGroup,
    List<String>? seriesTags,
    String? subtitle,
    String? synopsis,
    String? thumbnailImageUrl,
    String? titleExtension,
  }) {
    return MangaMetadata(
      title: title ?? this.title,
      nativeTitle: nativeTitle ?? this.nativeTitle,
      romajiTitle: romajiTitle ?? this.romajiTitle,
      englishTitle: englishTitle ?? this.englishTitle,
      alternateTitles: alternateTitles ?? this.alternateTitles,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      demographic: demographic ?? this.demographic,
      serializationPlatform:
          serializationPlatform ?? this.serializationPlatform,
      publicationStatus: publicationStatus ?? this.publicationStatus,
      originalPublisher: originalPublisher ?? this.originalPublisher,
      localizedPublisher: localizedPublisher ?? this.localizedPublisher,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      totalVolumes: totalVolumes ?? this.totalVolumes,
      chapterCount: chapterCount ?? this.chapterCount,
      originalPublicationDate:
          originalPublicationDate ?? this.originalPublicationDate,
      localizedReleaseDate: localizedReleaseDate ?? this.localizedReleaseDate,
      isbn: isbn ?? this.isbn,
      editionFormat: editionFormat ?? this.editionFormat,
      language: language ?? this.language,
      country: country ?? this.country,
      genres: genres ?? this.genres,
      themes: themes ?? this.themes,
      translator: translator ?? this.translator,
      readingDirection: readingDirection ?? this.readingDirection,
      relations: relations ?? this.relations,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      volumeName: volumeName ?? this.volumeName,
      editionTitle: editionTitle ?? this.editionTitle,
      pageCount: pageCount ?? this.pageCount,
      imprint: imprint ?? this.imprint,
      physicalFormat: physicalFormat ?? this.physicalFormat,
      physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
      publisher: publisher ?? this.publisher,
      barcode: barcode ?? this.barcode,
      variant: variant ?? this.variant,
      creators: creators ?? this.creators,
      sortKey: sortKey ?? this.sortKey,
      ageRating: ageRating ?? this.ageRating,
      audienceRating: audienceRating ?? this.audienceRating,
      catalogNumber: catalogNumber ?? this.catalogNumber,
      chapters: chapters ?? this.chapters,
      characters: characters ?? this.characters,
      characterDetails: characterDetails ?? this.characterDetails,
      contributors: contributors ?? this.contributors,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      backCoverImageUrl: backCoverImageUrl ?? this.backCoverImageUrl,
      crossover: crossover ?? this.crossover,
      description: description ?? this.description,
      externalLinks: externalLinks ?? this.externalLinks,
      identifiers: identifiers ?? this.identifiers,
      itemNumber: itemNumber ?? this.itemNumber,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      originalTitle: originalTitle ?? this.originalTitle,
      searchAliases: searchAliases ?? this.searchAliases,
      plotDescription: plotDescription ?? this.plotDescription,
      plotSummary: plotSummary ?? this.plotSummary,
      releaseDate: releaseDate ?? this.releaseDate,
      releaseDateParts: releaseDateParts ?? this.releaseDateParts,
      releaseStatus: releaseStatus ?? this.releaseStatus,
      seriesGroup: seriesGroup ?? this.seriesGroup,
      seriesTags: seriesTags ?? this.seriesTags,
      subtitle: subtitle ?? this.subtitle,
      synopsis: synopsis ?? this.synopsis,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      titleExtension: titleExtension ?? this.titleExtension,
    );
  }

  factory MangaMetadata.fromJson(Map<String, dynamic> json) {
    return MangaMetadata(
      title: (json['title'] as String?) ?? '',
      nativeTitle: json['native_title'] as String?,
      romajiTitle: json['romaji_title'] as String?,
      englishTitle: json['english_title'] as String?,
      alternateTitles: (json['alternate_titles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      artists: (json['artists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      demographic: MangaDemographic.fromString(json['demographic'] as String?),
      serializationPlatform: json['serialization_platform'] as String?,
      publicationStatus: MangaPublicationStatus.fromString(
          json['publication_status'] as String?),
      originalPublisher: json['original_publisher'] as String?,
      localizedPublisher: json['localized_publisher'] as String?,
      volumeNumber: int.tryParse(json['volume_number']?.toString() ?? ''),
      totalVolumes: (json['total_volumes'] as num?)?.toInt(),
      chapterCount: (json['chapter_count'] as num?)?.toInt(),
      originalPublicationDate: json['original_publication_date'] != null
          ? DateTime.tryParse(json['original_publication_date'] as String)
          : null,
      localizedReleaseDate: json['localized_release_date'] != null
          ? DateTime.tryParse(json['localized_release_date'] as String)
          : null,
      isbn: json['isbn'] as String?,
      editionFormat:
          MangaEditionFormat.fromString(json['edition_format'] as String?),
      language: (json['language'] as String?) ?? 'ja',
      country: (json['country'] as String?) ?? 'JP',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      translator: json['translator'] as String?,
      readingDirection: MangaReadingDirection.fromString(
          json['reading_direction'] as String?),
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      seriesTitle: json['series_title'] as String?,
      volumeName: json['volume_name'] as String?,
      editionTitle: json['edition_title'] as String?,
      pageCount: (json['page_count'] as num?)?.toInt(),
      imprint: json['imprint'] as String?,
      physicalFormat: json['physical_format'] as String?,
      physicalFormatLabel: json['physical_format_label'] as String?,
      publisher: json['publisher'] as String?,
      barcode: json['barcode'] as String?,
      variant: json['variant_name'] as String?,
      creators: _creditList(json['creators']),
      sortKey: json['sort_key'] as String?,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
      catalogNumber: json['catalog_number'] as String?,
      chapters: _chapterList(json['chapters']),
      characters: _characterList(json['characters']),
      characterDetails: _characterList(json['character_details']),
      contributors: _creditList(json['contributors']),
      coverImageUrl: json['cover_image_url'] as String?,
      backCoverImageUrl: json['back_cover_image_url'] as String?,
      crossover: json['crossover'] as String?,
      description: json['description'] as String?,
      externalLinks: _externalLinkList(json['external_links']),
      identifiers: _identifierList(json['identifiers']),
      itemNumber: json['item_number'] as String?,
      localizedTitle: json['localized_title'] as String?,
      originalTitle: json['original_title'] as String?,
      searchAliases: _stringList(json['search_aliases']),
      plotDescription: json['plot_description'] as String?,
      plotSummary: json['plot_summary'] as String?,
      releaseDate: PartialDate.tryParse(json['release_date']),
      releaseDateParts: PartialDate.tryParse(json['release_date_parts']),
      releaseStatus: json['release_status'] as String?,
      seriesGroup: json['series_group'] as String?,
      seriesTags: _stringList(json['series_tags']),
      subtitle: json['subtitle'] as String?,
      synopsis: json['synopsis'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      titleExtension: json['title_extension'] as String?,
    );
  }
}

List<MangaChapter> _chapterList(Object? value) =>
    (value as List<dynamic>?)
        ?.map((entry) => MangaChapter.fromJson(_objectMap(entry, 'chapter')))
        .toList(growable: false) ??
    const [];

List<MangaCharacter> _characterList(Object? value) =>
    (value as List<dynamic>?)
        ?.map(MangaCharacter.fromJsonValue)
        .toList(growable: false) ??
    const [];

List<MangaCredit> _creditList(Object? value) =>
    (value as List<dynamic>?)
        ?.map(MangaCredit.fromJsonValue)
        .toList(growable: false) ??
    const [];

List<MangaExternalLink> _externalLinkList(Object? value) =>
    (value as List<dynamic>?)
        ?.map((entry) =>
            MangaExternalLink.fromJson(_objectMap(entry, 'external link')))
        .toList(growable: false) ??
    const [];

List<MangaIdentifier> _identifierList(Object? value) =>
    (value as List<dynamic>?)
        ?.map(MangaIdentifier.fromJsonValue)
        .toList(growable: false) ??
    const [];

Map<String, dynamic> _objectMap(Object? value, String label) {
  if (value is! Map<Object?, Object?>) {
    throw FormatException('Manga $label values must be objects.');
  }
  return Map<String, dynamic>.from(value);
}

List<String> _stringList(Object? value) {
  if (value == null) return const [];
  if (value is! List<dynamic>) {
    throw const FormatException('Manga string fields must be arrays.');
  }
  return value.map((entry) {
    if (entry is! String) {
      throw const FormatException('Manga string arrays must contain strings.');
    }
    return entry;
  }).toList(growable: false);
}
