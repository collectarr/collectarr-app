import 'package:collectarr_app/features/library/kinds/anime/catalog/anime_catalog_item.dart';
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
  final AnimeCatalogItem video;
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
  @override
  String? get publisher => studio;
  @override
  String? get barcode => video.primaryRelease?.barcode;

  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (barcode != null) barcode!,
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
