import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceDto implements LibraryWorkspaceDto {
  BoardGameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalEntryProjection personal;
  final BoardGameMetadata metadata;

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
  String? get publisher =>
      metadata.publisher ?? metadata.publishers.firstOrNull;
  String? get seriesTitle => metadata.seriesTitle;
  String? get itemNumber => metadata.itemNumber;
  DateTime? get releaseDate =>
      metadata.releaseDate?.asDateTime ??
      metadata.releaseDateParts?.asDateTime ??
      common.releaseDate;
  String? get country => metadata.country;
  String? get language => metadata.language ?? metadata.languages.firstOrNull;
  String? get identifierCode => metadata.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata.variantName;
  String? get referenceFormatLabel =>
      metadata.physicalFormatLabel ?? metadata.physicalFormat;
  String? get format => referenceFormatLabel;
  String? get ageRating => metadata.ageRating;
  String? get audienceRating => metadata.audienceRating;
  int? get minPlayers => metadata.minPlayers;
  int? get maxPlayers => metadata.maxPlayers;
  int? get minimumAge => metadata.minimumAge;
  int? get minPlaytimeMinutes => metadata.minPlaytimeMinutes;
  int? get maxPlaytimeMinutes => metadata.maxPlaytimeMinutes;
  String? get bestPlayers => metadata.bestPlayers;
  String? get recommendedPlayers => metadata.recommendedPlayers;
  double? get complexityWeight => metadata.complexityWeight;
  double? get bggRating => metadata.bggRating;
  int? get bggRank => metadata.bggRank;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
