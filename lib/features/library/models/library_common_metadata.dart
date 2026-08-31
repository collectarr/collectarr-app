import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryCommonMetadata {
  const LibraryCommonMetadata({
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.titleExtension,
    this.searchAliases,
    this.sortKey,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.releaseDate,
    this.releaseYear,
    this.editions = const <CatalogEditionDto>[],
    this.trailerUrls = const <TrailerLinkDto>[],
    this.creatorsSummary,
    this.physicalFormat,
    this.physicalFormatLabel,
  });

  static const _unset = Object();

  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? titleExtension;
  final List<String>? searchAliases;
  final String? sortKey;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final DateTime? releaseDate;
  final int? releaseYear;
  final List<CatalogEditionDto> editions;
  final List<TrailerLinkDto> trailerUrls;
  final String? creatorsSummary;
  final String? physicalFormat;
  final String? physicalFormatLabel;

  String get resolvedDisplayTitle =>
      displayTitle ??
      (creatorsSummary != null && creatorsSummary!.isNotEmpty
          ? '$title / $creatorsSummary'
          : (localizedTitle ?? originalTitle ?? title));

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  LibraryCommonMetadata copyWith({
    String? title,
    Object? displayTitle = _unset,
    Object? localizedTitle = _unset,
    Object? originalTitle = _unset,
    Object? titleExtension = _unset,
    Object? searchAliases = _unset,
    Object? sortKey = _unset,
    Object? synopsis = _unset,
    Object? coverImageUrl = _unset,
    Object? thumbnailImageUrl = _unset,
    Object? coverImageData = _unset,
    Object? releaseDate = _unset,
    Object? releaseYear = _unset,
    List<CatalogEditionDto>? editions,
    List<TrailerLinkDto>? trailerUrls,
  }) {
    return LibraryCommonMetadata(
      title: title ?? this.title,
      displayTitle: identical(displayTitle, _unset)
          ? this.displayTitle
          : displayTitle as String?,
      localizedTitle: identical(localizedTitle, _unset)
          ? this.localizedTitle
          : localizedTitle as String?,
      originalTitle: identical(originalTitle, _unset)
          ? this.originalTitle
          : originalTitle as String?,
      titleExtension: identical(titleExtension, _unset)
          ? this.titleExtension
          : titleExtension as String?,
      searchAliases: identical(searchAliases, _unset)
          ? this.searchAliases
          : searchAliases as List<String>?,
      sortKey: identical(sortKey, _unset) ? this.sortKey : sortKey as String?,
      synopsis:
          identical(synopsis, _unset) ? this.synopsis : synopsis as String?,
      coverImageUrl: identical(coverImageUrl, _unset)
          ? this.coverImageUrl
          : coverImageUrl as String?,
      thumbnailImageUrl: identical(thumbnailImageUrl, _unset)
          ? this.thumbnailImageUrl
          : thumbnailImageUrl as String?,
      coverImageData: identical(coverImageData, _unset)
          ? this.coverImageData
          : coverImageData as String?,
      releaseDate: identical(releaseDate, _unset)
          ? this.releaseDate
          : releaseDate as DateTime?,
      releaseYear: identical(releaseYear, _unset)
          ? this.releaseYear
          : releaseYear as int?,
      editions: editions ?? this.editions,
      trailerUrls: trailerUrls ?? this.trailerUrls,
    );
  }
}
