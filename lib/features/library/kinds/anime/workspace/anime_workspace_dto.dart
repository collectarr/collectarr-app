import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceDto implements LibraryWorkspaceDto {
  AnimeWorkspaceDto({
    required this.common,
    required this.personal,
    required this.video,
    required this.media,
    this.release,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final AnimeCatalogItem video;
  final AnimeMedia media;
  final AnimeRelease? release;
  final AnimeMetadata? metadata;

  AnimeRelease? get _effectiveRelease => release ?? media.primaryRelease;
  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  AnimeMedia get anime => media;

  String? get animeType => media.animeType ?? metadata?.format.label;
  int? get episodeCount => media.episodeCount ?? metadata?.episodeCount;
  String? get airingStatus => media.status == null
      ? metadata?.airingStatus.label
      : AnimeAiringStatus.fromString(media.status).label;
  String? get studio =>
      _firstString(media.rawPayload['studios']) ??
      metadata?.studios.firstOrNull;
  String? get publisher =>
      release?.publisher ??
      release?.distributor ??
      (release == null ? studio : null);
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle;
  String? get itemNumber => metadata?.itemNumber;
  DateTime? get releaseDate =>
      release?.releaseDate ??
      (release == null
          ? metadata?.startDate ?? media.originalAirDate ?? common.releaseDate
          : null);
  String? get country => release == null ? metadata?.country : null;
  String? get language => release == null ? metadata?.language : null;
  String? get identifierCode => _effectiveRelease?.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata?.variant;
  String? get referenceFormatLabel =>
      release?.format ??
      (release == null
          ? metadata?.physicalFormatLabel ?? metadata?.physicalFormat
          : null);
  String? get format => referenceFormatLabel;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (animeType != null) animeType!,
        if (airingStatus != null) airingStatus!,
      ];

  static String? _firstString(Object? value) {
    if (value is! Iterable) return null;
    for (final entry in value) {
      final text = entry?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }
}
