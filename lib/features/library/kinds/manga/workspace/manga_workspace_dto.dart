import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceDto implements LibraryWorkspaceDto {
  MangaWorkspaceDto({
    required this.common,
    required this.personal,
    this.metadata,
    this.ownedDetails,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;

  final MangaMetadata? metadata;
  final MangaOwnedDetails? ownedDetails;
  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  String? get publisher => metadata?.publisher;
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle;
  String? get itemNumber => metadata?.itemNumber;
  DateTime? get releaseDate =>
      metadata?.localizedReleaseDate ??
      metadata?.originalPublicationDate ??
      common.releaseDate;
  String? get country => metadata?.country;
  String? get language => metadata?.language;
  String? get identifierCode => metadata?.barcode ?? metadata?.isbn;
  String? get barcode => identifierCode;
  String? get variant => metadata?.variant;
  String? get referenceFormatLabel =>
      metadata?.physicalFormatLabel ?? metadata?.physicalFormat;
  String? get format => referenceFormatLabel;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
