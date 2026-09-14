import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/foundation.dart';

/// The common, editable catalog metadata used by the shared edit shell.
///
/// This is deliberately limited to metadata whose meaning and lifecycle are
/// identical for every kind. Kind-owned fields stay in the concrete edit
/// draft and never get added here for convenience.
@immutable
final class CatalogEditMetadata {
  const CatalogEditMetadata({
    required this.ref,
    required this.title,
    this.displayTitle,
    this.localizedTitle,
    this.originalTitle,
    this.titleExtension,
    this.searchAliases = const [],
    this.sortKey,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.coverImageData,
    this.releaseDate,
    this.releaseYear,
  });

  final CatalogEntityRef ref;
  final String title;
  final String? displayTitle;
  final String? localizedTitle;
  final String? originalTitle;
  final String? titleExtension;
  final List<String> searchAliases;
  final String? sortKey;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? coverImageData;
  final DateTime? releaseDate;
  final int? releaseYear;

  CatalogMediaKind get kind => ref.mediaKind;
  String get id => ref.id;

  String get resolvedDisplayTitle =>
      displayTitle?.trim().isNotEmpty == true ? displayTitle! : title;

  String? get displayCoverUrl => coverImageUrl?.trim().isNotEmpty == true
      ? coverImageUrl
      : thumbnailImageUrl;

  CatalogEditMetadata copyWith({
    CatalogEntityRef? ref,
    String? title,
    Object? displayTitle = _unset,
    Object? localizedTitle = _unset,
    Object? originalTitle = _unset,
    Object? titleExtension = _unset,
    List<String>? searchAliases,
    Object? sortKey = _unset,
    Object? synopsis = _unset,
    Object? coverImageUrl = _unset,
    Object? thumbnailImageUrl = _unset,
    Object? coverImageData = _unset,
    Object? releaseDate = _unset,
    Object? releaseYear = _unset,
  }) {
    return CatalogEditMetadata(
      ref: ref ?? this.ref,
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
      searchAliases: List<String>.unmodifiable(
        searchAliases ?? this.searchAliases,
      ),
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
    );
  }
}

const Object _unset = Object();
