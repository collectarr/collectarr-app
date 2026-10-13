import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

/// Read-only projection of one concrete Movie Catalog Item and its collection item.
///
/// Edition facts and contained media live on the kind-owned metadata value.
final class MovieWorkspaceDto implements LibraryWorkspaceDto {
  const MovieWorkspaceDto({
    required this.common,
    required this.personal,
    required this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalEntryProjection personal;
  final MovieCatalogMetadata metadata;

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

  String? get director => metadata.directors.firstOrNull?.name;
  String? get writer => metadata.writers.firstOrNull?.name;
  String? get producer => metadata.producers.firstOrNull?.name;
  String? get studio => metadata.studio;
  String? get publisher => metadata.publisher;
  String? get seriesTitle => metadata.seriesTitle;
  String? get itemNumber => metadata.itemNumber;
  DateTime? get releaseDate =>
      metadata.releaseDate ??
      metadata.releaseDateParts?.asDateTime ??
      common.releaseDate;
  String? get country => metadata.country;
  String? get language => metadata.language;
  String? get identifierCode => metadata.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata.variant;
  String? get format => metadata.physicalFormat;
  String? get referenceFormatLabel => format;
  int? get runtimeMinutes => metadata.runtimeMinutes;
  String? get originalTitle => metadata.originalTitle;
  String? get ageRating => metadata.ageRating;
  String? get audienceRating => metadata.audienceRating;
  List<String> get genres => metadata.genres;
}
