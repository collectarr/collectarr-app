import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BookCatalogPrinting implements JsonEncodable {
  const BookCatalogPrinting({
    this.id,
    this.printingNumber,
    this.title,
    this.releaseDate,
    this.releaseDateParts,
    this.publisher,
    this.language,
    this.isbn,
  });

  final String? id;
  final int? printingNumber;
  final String? title;
  final DateTime? releaseDate;
  final PartialDate? releaseDateParts;
  final String? publisher;
  final String? language;
  final String? isbn;

  factory BookCatalogPrinting.fromJson(Map<String, dynamic> json) {
    return BookCatalogPrinting(
      id: json['id'] as String?,
      printingNumber: (json['printing_number'] as num?)?.toInt(),
      title: json['title'] as String?,
      releaseDate: PartialDate.tryParse(json['release_date'])?.asDateTime,
      releaseDateParts: PartialDate.tryParse(json['release_date']),
      publisher: json['publisher'] as String?,
      language: json['language'] as String?,
      isbn: json['isbn'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (printingNumber != null) 'printing_number': printingNumber,
        if (title != null) 'title': title,
        if (releaseDateParts != null)
          'release_date': releaseDateParts!.toJson()
        else if (releaseDate != null)
          'release_date': releaseDate!.toIso8601String(),
        if (publisher != null) 'publisher': publisher,
        if (language != null) 'language': language,
        if (isbn != null) 'isbn': isbn,
      };
}

@immutable
final class BookCatalogCredit implements JsonEncodable {
  const BookCatalogCredit({
    required this.name,
    this.id,
    this.artistId,
    this.personId,
    this.creditedName,
    this.imageUrl,
    this.instrument,
    this.joinPhrase,
    this.role,
    this.roleId,
    this.sequence,
    this.sortName,
  });

  final String name;
  final String? id;
  final String? artistId;
  final String? personId;
  final String? creditedName;
  final String? imageUrl;
  final String? instrument;
  final String? joinPhrase;
  final String? role;
  final String? roleId;
  final int? sequence;
  final String? sortName;

  factory BookCatalogCredit.fromValue(Object value) {
    if (value is String) return BookCatalogCredit(name: value);
    if (value is! Map) {
      throw const FormatException('Book credits must be strings or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Book credit objects require a name.');
    }
    return BookCatalogCredit(
      name: name,
      id: json['id'] as String?,
      artistId: json['artist_id'] as String?,
      personId: json['person_id'] as String?,
      creditedName: json['credited_name'] as String?,
      imageUrl: json['image_url'] as String?,
      instrument: json['instrument'] as String?,
      joinPhrase: json['join_phrase'] as String?,
      role: json['role'] as String?,
      roleId: json['role_id'] as String?,
      sequence: (json['sequence'] as num?)?.toInt(),
      sortName: json['sort_name'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        if (id != null) 'id': id,
        if (artistId != null) 'artist_id': artistId,
        if (personId != null) 'person_id': personId,
        if (creditedName != null) 'credited_name': creditedName,
        if (imageUrl != null) 'image_url': imageUrl,
        if (instrument != null) 'instrument': instrument,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (role != null) 'role': role,
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (sortName != null) 'sort_name': sortName,
      };
}

@immutable
final class BookCatalogCharacter implements JsonEncodable {
  const BookCatalogCharacter({
    required this.name,
    this.id,
    this.characterId,
    this.aliases = const [],
    this.role,
    this.description,
    this.imageUrl,
  });

  final String name;
  final String? id;
  final String? characterId;
  final List<String> aliases;
  final String? role;
  final String? description;
  final String? imageUrl;

  factory BookCatalogCharacter.fromValue(Object value) {
    if (value is String) return BookCatalogCharacter(name: value);
    if (value is! Map) {
      throw const FormatException(
          'Book characters must be strings or objects.');
    }
    final json = Map<String, dynamic>.from(value);
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Book character objects require a name.');
    }
    return BookCatalogCharacter(
      name: name,
      id: json['id'] as String?,
      characterId: json['character_id'] as String?,
      aliases: _stringList(json['aliases']),
      role: json['role'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        if (id != null) 'id': id,
        if (characterId != null) 'character_id': characterId,
        if (aliases.isNotEmpty) 'aliases': aliases,
        if (role != null) 'role': role,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  Object toJsonValue() => id == null &&
          characterId == null &&
          aliases.isEmpty &&
          role == null &&
          description == null &&
          imageUrl == null
      ? name
      : toJson();
}

@immutable
final class BookCatalogIdentifier implements JsonEncodable {
  const BookCatalogIdentifier({
    required this.value,
    this.identifierType,
    this.id,
    this.normalizedValue,
    this.isPrimary,
  });

  final String value;
  final String? identifierType;
  final String? id;
  final String? normalizedValue;
  final bool? isPrimary;

  factory BookCatalogIdentifier.fromValue(Object value) {
    if (value is String) return BookCatalogIdentifier(value: value);
    if (value is! Map) {
      throw const FormatException(
        'Book identifiers must be strings or objects.',
      );
    }
    final json = Map<String, dynamic>.from(value);
    final identifierValue = json['value'];
    final type = json['identifier_type'];
    if (identifierValue is! String ||
        identifierValue.isEmpty ||
        type is! String ||
        type.isEmpty) {
      throw const FormatException(
        'Book identifier objects require identifier_type and value.',
      );
    }
    return BookCatalogIdentifier(
      value: identifierValue,
      identifierType: type,
      id: json['id'] as String?,
      normalizedValue: json['normalized_value'] as String?,
      isPrimary: json['is_primary'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'identifier_type': identifierType ?? 'unspecified',
        'value': value,
        if (id != null) 'id': id,
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        if (isPrimary != null) 'is_primary': isPrimary,
      };

  Object toJsonValue() => identifierType == null ? value : toJson();
}

@immutable
final class BookSeriesMembership implements JsonEncodable {
  const BookSeriesMembership({
    required this.seriesId,
    this.id,
    this.displayNumber,
    this.sequence,
  });

  final String seriesId;
  final String? id;
  final String? displayNumber;
  final double? sequence;

  factory BookSeriesMembership.fromJson(Map<String, dynamic> json) {
    final seriesId = json['series_id'];
    if (seriesId is! String || seriesId.trim().isEmpty) {
      throw const FormatException('Book series membership requires series_id.');
    }
    return BookSeriesMembership(
      seriesId: seriesId,
      id: json['id'] as String?,
      displayNumber: json['display_number'] as String?,
      sequence: (json['sequence'] as num?)?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'series_id': seriesId,
        if (id != null) 'id': id,
        if (displayNumber != null) 'display_number': displayNumber,
        if (sequence != null) 'sequence': sequence,
      };
}

@immutable
final class BookExternalLink implements JsonEncodable {
  const BookExternalLink({
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

  factory BookExternalLink.fromJson(Map<String, dynamic> json) {
    final url = json['url'];
    if (url is! String || url.trim().isEmpty) {
      throw const FormatException('Book external links require a URL.');
    }
    return BookExternalLink(
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
final class BookCatalogMetadata implements JsonEncodable {
  const BookCatalogMetadata({
    required this.title,
    this.transportId,
    this.ageRating,
    this.audienceRating,
    this.barcode,
    this.catalogNumber,
    this.characters = const [],
    this.contributors = const [],
    this.country,
    this.coverImageUrl,
    this.backCoverImageUrl,
    this.creators = const [],
    this.description,
    this.distributor,
    this.dimensions,
    this.editionTitle,
    this.editionStatement,
    this.externalLinks = const [],
    this.genres = const [],
    this.identifiers = const [],
    this.imprint,
    this.isbn,
    this.isbn10,
    this.isbn13,
    this.itemNumber,
    this.firstEdition,
    this.firstPublicationDate,
    this.firstPublicationDateParts,
    this.audioLengthMinutes,
    this.binding,
    this.language,
    this.localizedTitle,
    this.originalTitle,
    this.originalLanguage,
    this.originalPublicationDate,
    this.originalPublicationDateParts,
    this.pageCount,
    this.physicalFormat,
    this.plotDescription,
    this.plotSummary,
    this.printings = const [],
    this.publisher,
    this.releaseDate,
    this.releaseDateParts,
    this.releaseStatus,
    this.searchAliases = const [],
    this.seriesGroup,
    this.seriesMemberships = const [],
    this.seriesTags = const [],
    this.seriesTitle,
    this.subjects = const [],
    this.region,
    this.sortTitle,
    this.subtitle,
    this.synopsis,
    this.thumbnailImageUrl,
    this.titleExtension,
    this.variant,
    this.volumeName,
    this.volumeNumber,
  });

  final String? transportId;
  final String title;
  final String? ageRating;
  final String? audienceRating;
  final String? barcode;
  final String? catalogNumber;
  final List<BookCatalogCharacter> characters;
  final List<BookCatalogCredit> contributors;
  final String? country;
  final String? coverImageUrl;
  final String? backCoverImageUrl;
  final List<BookCatalogCredit> creators;
  final String? description;
  final String? distributor;
  final String? dimensions;
  final String? editionTitle;
  final String? editionStatement;
  final List<BookExternalLink> externalLinks;
  final List<String> genres;
  final List<BookCatalogIdentifier> identifiers;
  final String? imprint;
  final String? isbn;
  final String? isbn10;
  final String? isbn13;
  final String? itemNumber;
  final bool? firstEdition;
  final DateTime? firstPublicationDate;
  final PartialDate? firstPublicationDateParts;
  final int? audioLengthMinutes;
  final String? binding;
  final String? language;
  final String? localizedTitle;
  final String? originalTitle;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final PartialDate? originalPublicationDateParts;
  final int? pageCount;
  final String? physicalFormat;
  final String? plotDescription;
  final String? plotSummary;
  final List<BookCatalogPrinting> printings;
  final String? publisher;
  final DateTime? releaseDate;
  final PartialDate? releaseDateParts;
  final String? releaseStatus;
  final List<String> searchAliases;
  final String? seriesGroup;
  final List<BookSeriesMembership> seriesMemberships;
  final List<String> seriesTags;
  final String? seriesTitle;
  final List<String> subjects;
  final String? region;
  final String? sortTitle;
  final String? subtitle;
  final String? synopsis;
  final String? thumbnailImageUrl;
  final String? titleExtension;
  final String? variant;
  final String? volumeName;
  final String? volumeNumber;

  String? get physicalFormatLabel => physicalFormat;

  List<String> get authors => _creditsForRole('author', creators);
  List<String> get translators => _creditsForRole('translator');
  List<String> get editors => _creditsForRole('editor');
  List<String> get illustrators => _creditsForRole('illustrator');
  List<String> get coverArtists => _creditsForRole('cover artist');

  List<String> _creditsForRole(
    String role, [
    List<BookCatalogCredit>? source,
  ]) {
    final credits = source ?? [...creators, ...contributors];
    final matching = credits
        .where((credit) => credit.role?.toLowerCase() == role)
        .map((credit) => credit.name)
        .where((name) => name.trim().isNotEmpty)
        .toList(growable: false);
    if (matching.isNotEmpty) return matching;
    return role == 'author' && source == null
        ? creators.map((credit) => credit.name).toList(growable: false)
        : const [];
  }

  @override
  Map<String, dynamic> toJson() => {
        if (transportId != null) 'id': transportId,
        'title': title,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (characters.isNotEmpty)
          'characters': characters.map((value) => value.toJsonValue()).toList(),
        if (contributors.isNotEmpty)
          'contributors': contributors.map((value) => value.toJson()).toList(),
        if (country != null) 'country': country,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (backCoverImageUrl != null)
          'back_cover_image_url': backCoverImageUrl,
        if (creators.isNotEmpty)
          'creators': creators.map((value) => value.toJson()).toList(),
        if (description != null) 'description': description,
        if (distributor != null) 'distributor': distributor,
        if (dimensions != null) 'dimensions': dimensions,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (editionStatement != null) 'edition_statement': editionStatement,
        if (externalLinks.isNotEmpty)
          'external_links':
              externalLinks.map((value) => value.toJson()).toList(),
        if (genres.isNotEmpty) 'genres': genres,
        if (identifiers.isNotEmpty)
          'identifiers':
              identifiers.map((value) => value.toJsonValue()).toList(),
        if (imprint != null) 'imprint': imprint,
        if (isbn != null) 'isbn': isbn,
        if (isbn10 != null) 'isbn10': isbn10,
        if (isbn13 != null) 'isbn13': isbn13,
        if (itemNumber != null) 'item_number': itemNumber,
        if (firstEdition != null) 'first_edition': firstEdition,
        if (firstPublicationDateParts != null)
          'first_publication_date': firstPublicationDateParts!.toJson()
        else if (firstPublicationDate != null)
          'first_publication_date': firstPublicationDate!.toIso8601String(),
        if (audioLengthMinutes != null)
          'audio_length_minutes': audioLengthMinutes,
        if (binding != null) 'binding': binding,
        if (language != null) 'language': language,
        if (localizedTitle != null) 'localized_title': localizedTitle,
        if (originalTitle != null) 'original_title': originalTitle,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (originalPublicationDateParts != null)
          'original_publication_date': originalPublicationDateParts!.toJson()
        else if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toIso8601String(),
        if (pageCount != null) 'page_count': pageCount,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (plotDescription != null) 'plot_description': plotDescription,
        if (plotSummary != null) 'plot_summary': plotSummary,
        if (printings.isNotEmpty)
          'printings': printings.map((value) => value.toJson()).toList(),
        if (publisher != null) 'publisher': publisher,
        if (releaseDateParts != null)
          'release_date_parts': releaseDateParts!.toJson(),
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
        if (seriesGroup != null) 'series_group': seriesGroup,
        if (seriesMemberships.isNotEmpty)
          'series_memberships':
              seriesMemberships.map((value) => value.toJson()).toList(),
        if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (subjects.isNotEmpty) 'subjects': subjects,
        if (region != null) 'region': region,
        if (sortTitle != null) 'sort_key': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
        if (synopsis != null) 'synopsis': synopsis,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (titleExtension != null) 'title_extension': titleExtension,
        if (variant != null) 'variant_name': variant,
        if (volumeName != null) 'volume_name': volumeName,
        if (volumeNumber != null) 'volume_number': volumeNumber,
      };

  BookCatalogMetadata copyWith({
    String? title,
    Object? ageRating = _bookMetadataUnset,
    Object? audienceRating = _bookMetadataUnset,
    Object? barcode = _bookMetadataUnset,
    Object? catalogNumber = _bookMetadataUnset,
    List<BookCatalogCharacter>? characters,
    List<BookCatalogCredit>? contributors,
    Object? country = _bookMetadataUnset,
    Object? coverImageUrl = _bookMetadataUnset,
    Object? backCoverImageUrl = _bookMetadataUnset,
    List<BookCatalogCredit>? creators,
    Object? description = _bookMetadataUnset,
    Object? distributor = _bookMetadataUnset,
    Object? dimensions = _bookMetadataUnset,
    Object? editionTitle = _bookMetadataUnset,
    Object? editionStatement = _bookMetadataUnset,
    List<BookExternalLink>? externalLinks,
    List<String>? genres,
    List<BookCatalogIdentifier>? identifiers,
    Object? imprint = _bookMetadataUnset,
    Object? isbn = _bookMetadataUnset,
    Object? isbn10 = _bookMetadataUnset,
    Object? isbn13 = _bookMetadataUnset,
    Object? itemNumber = _bookMetadataUnset,
    Object? firstEdition = _bookMetadataUnset,
    Object? firstPublicationDate = _bookMetadataUnset,
    Object? firstPublicationDateParts = _bookMetadataUnset,
    Object? audioLengthMinutes = _bookMetadataUnset,
    Object? binding = _bookMetadataUnset,
    Object? language = _bookMetadataUnset,
    Object? localizedTitle = _bookMetadataUnset,
    Object? originalTitle = _bookMetadataUnset,
    Object? originalLanguage = _bookMetadataUnset,
    Object? originalPublicationDate = _bookMetadataUnset,
    Object? originalPublicationDateParts = _bookMetadataUnset,
    Object? pageCount = _bookMetadataUnset,
    Object? physicalFormat = _bookMetadataUnset,
    Object? plotDescription = _bookMetadataUnset,
    Object? plotSummary = _bookMetadataUnset,
    List<BookCatalogPrinting>? printings,
    Object? publisher = _bookMetadataUnset,
    Object? releaseDate = _bookMetadataUnset,
    Object? releaseDateParts = _bookMetadataUnset,
    Object? releaseStatus = _bookMetadataUnset,
    List<String>? searchAliases,
    Object? seriesGroup = _bookMetadataUnset,
    List<BookSeriesMembership>? seriesMemberships,
    List<String>? seriesTags,
    Object? seriesTitle = _bookMetadataUnset,
    List<String>? subjects,
    Object? region = _bookMetadataUnset,
    Object? sortTitle = _bookMetadataUnset,
    Object? subtitle = _bookMetadataUnset,
    Object? synopsis = _bookMetadataUnset,
    Object? thumbnailImageUrl = _bookMetadataUnset,
    Object? titleExtension = _bookMetadataUnset,
    Object? variant = _bookMetadataUnset,
    Object? volumeName = _bookMetadataUnset,
    Object? volumeNumber = _bookMetadataUnset,
  }) =>
      BookCatalogMetadata(
        transportId: transportId,
        title: title ?? this.title,
        ageRating: _copyBookNullable(ageRating, this.ageRating),
        audienceRating: _copyBookNullable(audienceRating, this.audienceRating),
        barcode: _copyBookNullable(barcode, this.barcode),
        catalogNumber: _copyBookNullable(catalogNumber, this.catalogNumber),
        characters: characters ?? this.characters,
        contributors: contributors ?? this.contributors,
        country: _copyBookNullable(country, this.country),
        coverImageUrl: _copyBookNullable(coverImageUrl, this.coverImageUrl),
        backCoverImageUrl:
            _copyBookNullable(backCoverImageUrl, this.backCoverImageUrl),
        creators: creators ?? this.creators,
        description: _copyBookNullable(description, this.description),
        distributor: _copyBookNullable(distributor, this.distributor),
        dimensions: _copyBookNullable(dimensions, this.dimensions),
        editionTitle: _copyBookNullable(editionTitle, this.editionTitle),
        editionStatement:
            _copyBookNullable(editionStatement, this.editionStatement),
        externalLinks: externalLinks ?? this.externalLinks,
        genres: genres ?? this.genres,
        identifiers: identifiers ?? this.identifiers,
        imprint: _copyBookNullable(imprint, this.imprint),
        isbn: _copyBookNullable(isbn, this.isbn),
        isbn10: _copyBookNullable(isbn10, this.isbn10),
        isbn13: _copyBookNullable(isbn13, this.isbn13),
        itemNumber: _copyBookNullable(itemNumber, this.itemNumber),
        firstEdition: _copyBookNullable(firstEdition, this.firstEdition),
        firstPublicationDate:
            _copyBookNullable(firstPublicationDate, this.firstPublicationDate),
        firstPublicationDateParts: _copyBookNullable(
          firstPublicationDateParts,
          this.firstPublicationDateParts,
        ),
        audioLengthMinutes:
            _copyBookNullable(audioLengthMinutes, this.audioLengthMinutes),
        binding: _copyBookNullable(binding, this.binding),
        language: _copyBookNullable(language, this.language),
        localizedTitle: _copyBookNullable(localizedTitle, this.localizedTitle),
        originalTitle: _copyBookNullable(originalTitle, this.originalTitle),
        originalLanguage:
            _copyBookNullable(originalLanguage, this.originalLanguage),
        originalPublicationDate: _copyBookNullable(
          originalPublicationDate,
          this.originalPublicationDate,
        ),
        originalPublicationDateParts: _copyBookNullable(
          originalPublicationDateParts,
          this.originalPublicationDateParts,
        ),
        pageCount: _copyBookNullable(pageCount, this.pageCount),
        physicalFormat: _copyBookNullable(physicalFormat, this.physicalFormat),
        plotDescription:
            _copyBookNullable(plotDescription, this.plotDescription),
        plotSummary: _copyBookNullable(plotSummary, this.plotSummary),
        printings: printings ?? this.printings,
        publisher: _copyBookNullable(publisher, this.publisher),
        releaseDate: _copyBookNullable(releaseDate, this.releaseDate),
        releaseDateParts:
            _copyBookNullable(releaseDateParts, this.releaseDateParts),
        releaseStatus: _copyBookNullable(releaseStatus, this.releaseStatus),
        searchAliases: searchAliases ?? this.searchAliases,
        seriesGroup: _copyBookNullable(seriesGroup, this.seriesGroup),
        seriesMemberships: seriesMemberships ?? this.seriesMemberships,
        seriesTags: seriesTags ?? this.seriesTags,
        seriesTitle: _copyBookNullable(seriesTitle, this.seriesTitle),
        subjects: subjects ?? this.subjects,
        region: _copyBookNullable(region, this.region),
        sortTitle: _copyBookNullable(sortTitle, this.sortTitle),
        subtitle: _copyBookNullable(subtitle, this.subtitle),
        synopsis: _copyBookNullable(synopsis, this.synopsis),
        thumbnailImageUrl:
            _copyBookNullable(thumbnailImageUrl, this.thumbnailImageUrl),
        titleExtension: _copyBookNullable(titleExtension, this.titleExtension),
        variant: _copyBookNullable(variant, this.variant),
        volumeName: _copyBookNullable(volumeName, this.volumeName),
        volumeNumber: _copyBookNullable(volumeNumber, this.volumeNumber),
      );

  factory BookCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final rawTitle = json['title'];
    if (rawTitle is! String || rawTitle.trim().isEmpty) {
      throw const FormatException('Book catalog metadata requires a title.');
    }
    return BookCatalogMetadata(
      transportId: json['id'] as String?,
      title: rawTitle,
      ageRating: json['age_rating'] as String?,
      audienceRating: json['audience_rating'] as String?,
      barcode: json['barcode'] as String?,
      catalogNumber: json['catalog_number'] as String?,
      characters: _list(json['characters'], BookCatalogCharacter.fromValue),
      contributors: _list(json['contributors'], BookCatalogCredit.fromValue),
      country: json['country'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      backCoverImageUrl: json['back_cover_image_url'] as String?,
      creators: _list(json['creators'], BookCatalogCredit.fromValue),
      description: json['description'] as String?,
      distributor: json['distributor'] as String?,
      dimensions: json['dimensions'] as String?,
      editionTitle: json['edition_title'] as String?,
      editionStatement: json['edition_statement'] as String?,
      externalLinks: _list(
        json['external_links'],
        (value) => BookExternalLink.fromJson(_object(value, 'external link')),
      ),
      genres: _stringList(json['genres']),
      identifiers: _list(json['identifiers'], BookCatalogIdentifier.fromValue),
      imprint: json['imprint'] as String?,
      isbn: json['isbn'] as String?,
      isbn10: json['isbn10'] as String?,
      isbn13: json['isbn13'] as String?,
      itemNumber: json['item_number'] as String?,
      firstEdition: json['first_edition'] as bool?,
      firstPublicationDate:
          PartialDate.tryParse(json['first_publication_date'])?.asDateTime,
      firstPublicationDateParts:
          PartialDate.tryParse(json['first_publication_date']),
      audioLengthMinutes: (json['audio_length_minutes'] as num?)?.toInt(),
      binding: json['binding'] as String?,
      language: json['language'] as String?,
      localizedTitle: json['localized_title'] as String?,
      originalTitle: json['original_title'] as String?,
      originalLanguage: json['original_language'] as String?,
      originalPublicationDate:
          PartialDate.tryParse(json['original_publication_date'])?.asDateTime,
      originalPublicationDateParts:
          PartialDate.tryParse(json['original_publication_date']),
      pageCount: (json['page_count'] as num?)?.toInt(),
      physicalFormat: json['physical_format'] as String?,
      plotDescription: json['plot_description'] as String?,
      plotSummary: json['plot_summary'] as String?,
      printings: _list(
        json['printings'],
        (value) => BookCatalogPrinting.fromJson(_object(value, 'printing')),
      ),
      publisher: json['publisher'] as String?,
      releaseDate: PartialDate.tryParse(json['release_date'])?.asDateTime,
      releaseDateParts: PartialDate.tryParse(json['release_date_parts']),
      releaseStatus: json['release_status'] as String?,
      searchAliases: _stringList(json['search_aliases']),
      seriesGroup: json['series_group'] as String?,
      seriesMemberships: _list(
        json['series_memberships'],
        (value) => BookSeriesMembership.fromJson(
          _object(value, 'series membership'),
        ),
      ),
      seriesTags: _stringList(json['series_tags']),
      seriesTitle: json['series_title'] as String?,
      subjects: _stringList(json['subjects']),
      region: json['region'] as String?,
      sortTitle: json['sort_key'] as String?,
      subtitle: json['subtitle'] as String?,
      synopsis: json['synopsis'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      titleExtension: json['title_extension'] as String?,
      variant: json['variant_name'] as String?,
      volumeName: json['volume_name'] as String?,
      volumeNumber: json['volume_number']?.toString(),
    );
  }
}

T? _copyBookNullable<T>(Object? value, T? current) =>
    identical(value, _bookMetadataUnset) ? current : value as T?;

const Object _bookMetadataUnset = Object();

List<T> _list<T>(Object? value, T Function(Object value) decode) {
  if (value == null) return const [];
  if (value is! List) throw const FormatException('Expected a list value.');
  final values = <T>[];
  for (final entry in value) {
    if (entry is! Object) {
      throw const FormatException('List entries cannot be null.');
    }
    values.add(decode(entry));
  }
  return List<T>.unmodifiable(values);
}

Map<String, dynamic> _object(Object? value, String label) {
  if (value is! Map) throw FormatException('Book $label must be an object.');
  return Map<String, dynamic>.from(value);
}

List<String> _stringList(Object? value) {
  if (value == null) return const [];
  if (value is! List) throw const FormatException('Expected a string list.');
  return List<String>.unmodifiable(value.map((entry) {
    if (entry is! String) {
      throw const FormatException('String lists may only contain strings.');
    }
    return entry;
  }));
}
