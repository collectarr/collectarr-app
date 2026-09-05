import 'package:collectarr_app/features/library/models/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceDto extends WorkspaceDtoAdapter {
  AnimeWorkspaceDto({
    required this.common,
    required this.personal,
    required this.video,
    required this.media,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final VideoCatalogItem video;
  final AnimeMedia media;
  final AnimeMetadata? metadata;

  AnimeMedia get anime => media;

  String? get animeType => media.animeType ?? metadata?.format.label;
  int? get episodeCount => media.episodeCount ?? metadata?.episodeCount;
  String? get airingStatus => media.status == null
      ? metadata?.airingStatus.label
      : AnimeAiringStatus.fromString(media.status).label;
  String? get studio =>
      _firstString(media.rawPayload['studios']) ??
      metadata?.studios.firstOrNull;

  static String? _firstString(Object? value) {
    if (value is! Iterable) return null;
    for (final entry in value) {
      final text = entry?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }
}
