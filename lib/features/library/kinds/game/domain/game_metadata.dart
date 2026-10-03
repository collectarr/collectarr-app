import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:flutter/foundation.dart';

@immutable
final class GameCatalogIdentifier implements JsonEncodable {
  const GameCatalogIdentifier({
    required this.value,
    this.id,
    this.identifierType,
    this.normalizedValue,
    this.isPrimary = false,
    this.stringValue = false,
  });

  final String value;
  final String? id;
  final String? identifierType;
  final String? normalizedValue;
  final bool isPrimary;
  final bool stringValue;

  factory GameCatalogIdentifier.fromJson(Object? json) {
    if (json is String) {
      return GameCatalogIdentifier(value: json, stringValue: true);
    }
    if (json is! Map) {
      throw const FormatException(
          'Game identifiers must be strings or objects.');
    }
    final value = json['value'];
    final identifierType = json['identifier_type'];
    if (value is! String || identifierType is! String) {
      throw const FormatException(
        'Game identifier objects require identifier_type and value strings.',
      );
    }
    return GameCatalogIdentifier(
      value: value,
      id: json['id'] as String?,
      identifierType: identifierType,
      normalizedValue: json['normalized_value'] as String?,
      isPrimary: json['is_primary'] == true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (identifierType != null) 'identifier_type': identifierType,
        'value': value,
        if (normalizedValue != null) 'normalized_value': normalizedValue,
        'is_primary': isPrimary,
      };

  Object toWireValue() => stringValue ? value : toJson();
}

@immutable
final class GameCatalogPersonCredit implements JsonEncodable {
  const GameCatalogPersonCredit({
    required this.name,
    this.id,
    this.personId,
    this.role,
    this.roleId,
    this.sequence,
    this.creditedName,
    this.joinPhrase,
    this.imageUrl,
    this.sortName,
    this.instrument,
  });

  final String name;
  final String? id;
  final String? personId;
  final String? role;
  final String? roleId;
  final int? sequence;
  final String? creditedName;
  final String? joinPhrase;
  final String? imageUrl;
  final String? sortName;
  final String? instrument;

  factory GameCatalogPersonCredit.fromJson(Object? json) {
    if (json is String) return GameCatalogPersonCredit(name: json);
    if (json is! Map) {
      throw const FormatException('Game credits must be strings or objects.');
    }
    final sequence = json['sequence'];
    return GameCatalogPersonCredit(
      name: _text(json['name']) ?? '',
      id: _text(json['id']),
      personId: _text(json['person_id']),
      role: _text(json['role']),
      roleId: _text(json['role_id']),
      sequence: sequence is num ? sequence.toInt() : null,
      creditedName: _text(json['credited_name']),
      joinPhrase: _text(json['join_phrase']),
      imageUrl: _text(json['image_url']),
      sortName: _text(json['sort_name']),
      instrument: _text(json['instrument']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (personId != null) 'person_id': personId,
        'name': name,
        if (role != null) 'role': role,
        if (roleId != null) 'role_id': roleId,
        if (sequence != null) 'sequence': sequence,
        if (creditedName != null) 'credited_name': creditedName,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (imageUrl != null) 'image_url': imageUrl,
        if (sortName != null) 'sort_name': sortName,
        if (instrument != null) 'instrument': instrument,
      };
}

@immutable
final class GameCatalogLink implements JsonEncodable {
  const GameCatalogLink({
    required this.url,
    this.id,
    this.label,
    this.title,
    this.site,
    this.name,
    this.kind,
    this.description,
    this.position,
    this.linkType,
  });

  final String url;
  final String? id;
  final String? label;
  final String? title;
  final String? site;
  final String? name;
  final String? kind;
  final String? description;
  final int? position;
  final String? linkType;

  bool get isExternalLink =>
      kind == 'external' || kind == 'link' || linkType == 'external';
  bool get isTrailerLink => !isExternalLink;

  factory GameCatalogLink.fromJson(Map<String, dynamic> json) {
    final position = json['position'];
    return GameCatalogLink(
      url: _text(json['url']) ?? '',
      id: _text(json['id']),
      label: _text(json['label']),
      title: _text(json['title']),
      site: _text(json['site']),
      name: _text(json['name']),
      kind: _text(json['kind']),
      description: _text(json['description']),
      position: position is num ? position.toInt() : null,
      linkType: _text(json['link_type']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (label != null) 'label': label,
        if (title != null) 'title': title,
        'url': url,
        if (site != null) 'site': site,
        if (name != null) 'name': name,
        if (kind != null) 'kind': kind,
        if (description != null) 'description': description,
        if (position != null) 'position': position,
        if (linkType != null) 'link_type': linkType,
      };
}

@immutable
final class GameCatalogMetadata implements JsonEncodable {
  const GameCatalogMetadata({
    required this.title,
    this.sortKey,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.titleExtension,
    this.subtitle,
    this.searchAliases = const [],
    this.synopsis,
    this.description,
    this.plotSummary,
    this.plotDescription,
    this.ageRating,
    this.audienceRating,
    this.barcode,
    this.catalogNumber,
    this.itemNumber,
    this.companyRoles = const [],
    this.contributors = const [],
    this.country = 'US',
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.developers = const [],
    this.editionTitle,
    this.franchise,
    this.genres = const [],
    this.identifiers = const [],
    this.language,
    this.languages = const [],
    this.originalLanguage,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.platforms = const [],
    this.publisher,
    this.releaseDateParts,
    this.releaseRegion,
    this.releaseStatus,
    this.seriesTags = const [],
    this.seriesTitle,
    this.links = const [],
    this.variantName,
    this.toySubtype,
    this.toyType,
    this.priceChartingId,
    this.valuations,
    this.creators = const [],
  });

  CatalogMediaKind get mediaKind => CatalogMediaKind.game;

  Map<String, dynamic> toSyncPayload() => toJson();

  final String title;
  final String? sortKey;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? titleExtension;
  final String? subtitle;
  final List<String> searchAliases;
  final String? synopsis;
  final String? description;
  final String? plotSummary;
  final String? plotDescription;
  final String? ageRating;
  final String? audienceRating;
  final String? barcode;
  final String? catalogNumber;
  final String? itemNumber;
  final List<String> companyRoles;
  final List<GameCatalogPersonCredit> contributors;
  final String country;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<String> developers;
  final String? editionTitle;
  final String? franchise;
  final List<String> genres;
  final List<GameCatalogIdentifier> identifiers;
  final String? language;
  final List<String> languages;
  final String? originalLanguage;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final List<String> platforms;
  final String? publisher;
  final PartialDate? releaseDateParts;
  final String? releaseRegion;
  final String? releaseStatus;
  final List<String> seriesTags;
  final String? seriesTitle;
  final List<GameCatalogLink> links;
  final String? variantName;

  // These values belong to the local Game details layer and are not emitted
  // in the source-neutral Core Catalog Item document.
  final String? toySubtype;
  final String? toyType;
  final String? priceChartingId;
  final GameValuationSet? valuations;
  final List<GameCatalogPersonCredit> creators;

  DateTime? get releaseDate => releaseDateParts?.asDateTime;

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        if (sortKey != null) 'sort_key': sortKey,
        if (displayTitle != null) 'display_title': displayTitle,
        if (localizedTitle != null) 'localized_title': localizedTitle,
        if (originalTitle != null) 'original_title': originalTitle,
        if (titleExtension != null) 'title_extension': titleExtension,
        if (subtitle != null) 'subtitle': subtitle,
        if (searchAliases.isNotEmpty) 'search_aliases': searchAliases,
        if (synopsis != null) 'synopsis': synopsis,
        if (description != null) 'description': description,
        if (plotSummary != null) 'plot_summary': plotSummary,
        if (plotDescription != null) 'plot_description': plotDescription,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (itemNumber != null) 'item_number': itemNumber,
        if (companyRoles.isNotEmpty) 'company_roles': companyRoles,
        if (country.isNotEmpty) 'country': country,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (creators.isNotEmpty)
          'creators': creators.map((value) => value.toJson()).toList(),
        if (developers.isNotEmpty) 'developers': developers,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (contributors.isNotEmpty)
          'contributors': contributors.map((value) => value.toJson()).toList(),
        if (links.where((link) => link.isExternalLink).isNotEmpty)
          'external_links': links
              .where((link) => link.isExternalLink)
              .map((link) => link.toJson())
              .toList(growable: false),
        if (genres.isNotEmpty) 'genres': genres,
        if (identifiers.isNotEmpty)
          'identifiers':
              identifiers.map((value) => value.toWireValue()).toList(),
        if (language != null) 'language': language,
        if (languages.isNotEmpty) 'languages': languages,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (platforms.isNotEmpty) 'platforms': platforms,
        if (publisher != null) 'publisher': publisher,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (releaseDateParts != null) ...{
          'release_date': releaseDateParts!.isoString,
          'release_date_parts': releaseDateParts!.toJson(),
        },
        if (releaseRegion != null) 'release_region': releaseRegion,
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (seriesTags.isNotEmpty) 'series_tags': seriesTags,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (links.where((link) => link.isTrailerLink).isNotEmpty)
          'trailer_urls': links
              .where((link) => link.isTrailerLink)
              .map((link) => link.toJson())
              .toList(growable: false),
        if (variantName != null) 'variant_name': variantName,
        if (toySubtype != null) 'toy_subtype': toySubtype,
        if (toyType != null) 'toy_type': toyType,
      };

  GameCatalogMetadata copyWith({
    String? title,
    String? sortKey,
    String? displayTitle,
    String? localizedTitle,
    String? originalTitle,
    String? titleExtension,
    String? subtitle,
    List<String>? searchAliases,
    String? synopsis,
    String? description,
    String? plotSummary,
    String? plotDescription,
    String? ageRating,
    String? audienceRating,
    String? barcode,
    String? catalogNumber,
    String? itemNumber,
    List<String>? companyRoles,
    List<GameCatalogPersonCredit>? contributors,
    String? country,
    String? coverImageUrl,
    String? thumbnailImageUrl,
    List<String>? developers,
    String? editionTitle,
    String? franchise,
    List<String>? genres,
    List<GameCatalogIdentifier>? identifiers,
    String? language,
    List<String>? languages,
    String? originalLanguage,
    String? physicalFormat,
    String? physicalFormatLabel,
    List<String>? platforms,
    String? publisher,
    PartialDate? releaseDateParts,
    String? releaseRegion,
    String? releaseStatus,
    List<String>? seriesTags,
    String? seriesTitle,
    List<GameCatalogLink>? links,
    String? variantName,
    String? toySubtype,
    String? toyType,
    String? priceChartingId,
    GameValuationSet? valuations,
    List<GameCatalogPersonCredit>? creators,
  }) =>
      GameCatalogMetadata(
        title: title ?? this.title,
        sortKey: sortKey ?? this.sortKey,
        displayTitle: displayTitle ?? this.displayTitle,
        localizedTitle: localizedTitle ?? this.localizedTitle,
        originalTitle: originalTitle ?? this.originalTitle,
        titleExtension: titleExtension ?? this.titleExtension,
        subtitle: subtitle ?? this.subtitle,
        searchAliases: searchAliases ?? this.searchAliases,
        synopsis: synopsis ?? this.synopsis,
        description: description ?? this.description,
        plotSummary: plotSummary ?? this.plotSummary,
        plotDescription: plotDescription ?? this.plotDescription,
        ageRating: ageRating ?? this.ageRating,
        audienceRating: audienceRating ?? this.audienceRating,
        barcode: barcode ?? this.barcode,
        catalogNumber: catalogNumber ?? this.catalogNumber,
        itemNumber: itemNumber ?? this.itemNumber,
        companyRoles: companyRoles ?? this.companyRoles,
        contributors: contributors ?? this.contributors,
        country: country ?? this.country,
        coverImageUrl: coverImageUrl ?? this.coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
        developers: developers ?? this.developers,
        editionTitle: editionTitle ?? this.editionTitle,
        franchise: franchise ?? this.franchise,
        genres: genres ?? this.genres,
        identifiers: identifiers ?? this.identifiers,
        language: language ?? this.language,
        languages: languages ?? this.languages,
        originalLanguage: originalLanguage ?? this.originalLanguage,
        physicalFormat: physicalFormat ?? this.physicalFormat,
        physicalFormatLabel: physicalFormatLabel ?? this.physicalFormatLabel,
        platforms: platforms ?? this.platforms,
        publisher: publisher ?? this.publisher,
        releaseDateParts: releaseDateParts ?? this.releaseDateParts,
        releaseRegion: releaseRegion ?? this.releaseRegion,
        releaseStatus: releaseStatus ?? this.releaseStatus,
        seriesTags: seriesTags ?? this.seriesTags,
        seriesTitle: seriesTitle ?? this.seriesTitle,
        links: links ?? this.links,
        variantName: variantName ?? this.variantName,
        toySubtype: toySubtype ?? this.toySubtype,
        toyType: toyType ?? this.toyType,
        priceChartingId: priceChartingId ?? this.priceChartingId,
        valuations: valuations ?? this.valuations,
        creators: creators ?? this.creators,
      );

  factory GameCatalogMetadata.fromJson(Map<String, dynamic> json) {
    final links = <GameCatalogLink>[
      ..._objectList(json['trailer_urls']).map(GameCatalogLink.fromJson),
      ..._objectList(json['external_links']).map(GameCatalogLink.fromJson),
    ];
    final creatorRows = _people(json['creators']);
    final contributorRows = _people(json['contributors']);
    final rawIdentifiers = json['identifiers'];
    if (rawIdentifiers != null && rawIdentifiers is! List) {
      throw const FormatException('Game identifiers must be a list.');
    }

    return GameCatalogMetadata(
      title: _text(json['title']) ?? '',
      sortKey: _text(json['sort_key']),
      displayTitle: _text(json['display_title']),
      localizedTitle: _text(json['localized_title']),
      originalTitle: _text(json['original_title']),
      titleExtension: _text(json['title_extension']),
      subtitle: _text(json['subtitle']),
      searchAliases: _strings(json['search_aliases']),
      synopsis: _text(json['synopsis']),
      description: _text(json['description']),
      plotSummary: _text(json['plot_summary']),
      plotDescription: _text(json['plot_description']),
      ageRating: _text(json['age_rating']),
      audienceRating: _text(json['audience_rating']),
      barcode: _text(json['barcode']),
      catalogNumber: _text(json['catalog_number']),
      itemNumber: _text(json['item_number']),
      companyRoles: _strings(json['company_roles']),
      contributors: contributorRows,
      country: _text(json['country']) ?? 'US',
      coverImageUrl: _text(json['cover_image_url']),
      thumbnailImageUrl: _text(json['thumbnail_image_url']),
      developers: _strings(json['developers']),
      editionTitle: _text(json['edition_title']),
      franchise: _text(json['franchise']),
      genres: _strings(json['genres']),
      identifiers: [
        for (final identifier in rawIdentifiers as List? ?? const [])
          GameCatalogIdentifier.fromJson(identifier),
      ],
      language: _text(json['language']),
      languages: _strings(json['languages']),
      originalLanguage: _text(json['original_language']),
      physicalFormat: _text(json['physical_format']),
      physicalFormatLabel: _text(json['physical_format_label']),
      platforms: _strings(json['platforms']),
      publisher: _text(json['publisher']),
      releaseDateParts: PartialDate.tryParse(
        json['release_date_parts'] ?? json['release_date'],
      ),
      releaseRegion: _text(json['release_region']),
      releaseStatus: _text(json['release_status']),
      seriesTags: _strings(json['series_tags']),
      seriesTitle: _text(json['series_title']),
      links: links,
      variantName: _text(json['variant_name']),
      toySubtype: _text(json['toy_subtype']),
      toyType: _text(json['toy_type']),
      priceChartingId: _text(json['price_charting_id']),
      valuations: json['valuations'] is Map
          ? GameValuationSet.fromJson(
              Map<String, dynamic>.from(json['valuations'] as Map),
            )
          : null,
      creators: creatorRows,
    );
  }
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

List<String> _strings(Object? value) => value is List
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text,
      ]
    : const [];

List<GameCatalogPersonCredit> _people(Object? value) => value is List
    ? [
        for (final entry in value) GameCatalogPersonCredit.fromJson(entry),
      ]
    : const [];

List<Map<String, dynamic>> _objectList(Object? value) => value is List
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry),
      ]
    : const [];
