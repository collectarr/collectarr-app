import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceDto extends WorkspaceDtoAdapter {
  TvWorkspaceDto({
    required this.common,
    required this.personal,
    required this.video,
    required this.series,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final TvCatalogItem video;
  final TvSeries series;
  final TvSeriesMetadata? metadata;

  TvSeries get show => series;

  DateTime? get firstAirDate =>
      series.originalAirDate ?? metadata?.firstAirDate;
  DateTime? get lastAirDate => series.endDate ?? metadata?.lastAirDate;
  String? get tvStatus => series.status ?? metadata?.status;
  String? get streamingService =>
      _text(series.rawPayload['streaming_service']) ??
      metadata?.streamingService;
  String? get contentRating =>
      _text(series.rawPayload['content_rating']) ?? metadata?.contentRating;
  int? get seasonCount => series.seasonCount ?? metadata?.seasonCount;
  int? get episodeCount => series.episodeCount ?? metadata?.episodeCount;
  int? get episodeRuntimeMinutes => metadata?.episodeRuntimeMinutes;

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
