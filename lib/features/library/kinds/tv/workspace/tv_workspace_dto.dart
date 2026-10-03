import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceDto implements LibraryWorkspaceDto {
  TvWorkspaceDto({
    required this.common,
    required this.personal,
    required this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final TvSeriesMetadata metadata;

  String get title => common.title;
  String? get coverImageUrl => common.coverImageUrl;
  @override
  String get primaryLabel => title;
  @override
  String? get imageUrl => coverImageUrl;
  @override
  String? get secondaryLabel => null;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  DateTime? get firstAirDate => metadata.firstAirDate;
  DateTime? get lastAirDate => metadata.lastAirDate;
  String? get tvStatus => metadata.status;
  String? get streamingService => metadata.streamingService;
  String? get network => streamingService;
  String? get publisher => metadata.publisher ?? streamingService;
  String? get seriesTitle => metadata.seriesTitle ?? metadata.title;
  String? get itemNumber => metadata.itemNumber;
  DateTime? get releaseDate => common.releaseDate;
  String? get country => metadata.country;
  String? get language => metadata.originalLanguage;
  String? get identifierCode => metadata.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata.variant;
  String? get referenceFormatLabel =>
      metadata.physicalFormatLabel ?? metadata.physicalFormat;
  String? get format => referenceFormatLabel;
  String? get contentRating => metadata.contentRating;
  int? get seasonCount => metadata.seasonCount;
  int? get episodeCount => metadata.episodeCount;
  int? get episodeRuntimeMinutes => metadata.episodeRuntimeMinutes;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (contentRating != null) contentRating!,
        if (tvStatus != null) tvStatus!,
        if (network != null) network!,
      ];
}
