import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceDto implements LibraryWorkspaceDto {
  TvWorkspaceDto({
    required this.common,
    required this.personal,
    required this.video,
    required this.series,
    this.release,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final TvCatalogItem video;
  final TvSeries series;
  final TvCatalogRelease? release;
  final TvSeriesMetadata? metadata;

  TvCatalogRelease? get _effectiveRelease => release ?? video.primaryRelease;
  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  TvSeries get show => series;

  DateTime? get firstAirDate =>
      series.originalAirDate ?? metadata?.firstAirDate;
  DateTime? get lastAirDate => series.endDate ?? metadata?.lastAirDate;
  String? get tvStatus => series.status ?? metadata?.status;
  String? get streamingService =>
      _text(series.rawPayload['streaming_service']) ??
      metadata?.streamingService;
  String? get network => streamingService;
  String? get publisher =>
      release?.publisher ?? (release == null ? streamingService : null);
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle ?? series.title;
  String? get itemNumber => metadata?.itemNumber;
  DateTime? get releaseDate =>
      release?.releaseDate ??
      (release == null
          ? series.originalAirDate ??
              metadata?.firstAirDate ??
              common.releaseDate
          : null);
  String? get country => release == null ? metadata?.country : null;
  String? get language => release == null ? metadata?.originalLanguage : null;
  String? get identifierCode => _effectiveRelease?.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata?.variant;
  String? get referenceFormatLabel =>
      release?.formatLabel ??
      (release == null
          ? metadata?.physicalFormatLabel ?? metadata?.physicalFormat
          : null);
  String? get format => referenceFormatLabel;
  String? get contentRating =>
      _text(series.rawPayload['content_rating']) ?? metadata?.contentRating;
  int? get seasonCount => series.seasonCount ?? metadata?.seasonCount;
  int? get episodeCount => series.episodeCount ?? metadata?.episodeCount;
  int? get episodeRuntimeMinutes => metadata?.episodeRuntimeMinutes;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (contentRating != null) contentRating!,
        if (tvStatus != null) tvStatus!,
        if (network != null) network!,
      ];

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
