import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceDto implements LibraryWorkspaceDto {
  AnimeWorkspaceDto({
    required this.common,
    required this.personal,
    required this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalEntryProjection personal;
  final AnimeMetadata metadata;

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

  String? get animeType => metadata.format.label;
  int? get episodeCount => metadata.episodeCount;
  String? get airingStatus => metadata.airingStatus.label;
  String? get studio => metadata.studios.firstOrNull;
  String? get publisher => metadata.publisher ?? studio;
  String? get seriesTitle => metadata.seriesTitle;
  String? get itemNumber => metadata.itemNumber;
  DateTime? get releaseDate =>
      metadata.startDate ?? metadata.releaseDate ?? common.releaseDate;
  String? get country => metadata.country;
  String? get language => metadata.language;
  String? get identifierCode => metadata.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata.variant;
  String? get referenceFormatLabel =>
      metadata.physicalFormatLabel ?? metadata.physicalFormat;
  String? get format => referenceFormatLabel;
}
