import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceDto implements LibraryWorkspaceDto {
  MangaWorkspaceDto({
    required this.common,
    required this.personal,
    this.release,
    this.metadata,
    this.ownedDetails,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;

  final CatalogEditionDto? release;
  final MangaMetadata? metadata;
  final MangaOwnedDetails? ownedDetails;

  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  String? get publisher =>
      release?.publisher ?? (release == null ? metadata?.publisher : null);
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle;
  String? get itemNumber => metadata?.itemNumber;
  DateTime? get releaseDate =>
      release?.releaseDate ??
      (release == null
          ? metadata?.localizedReleaseDate ??
              metadata?.originalPublicationDate ??
              common.releaseDate
          : null);
  String? get country =>
      release?.region ?? (release == null ? metadata?.country : null);
  String? get language =>
      release?.language ?? (release == null ? metadata?.language : null);
  String? get identifierCode =>
      release?.identifierCode ??
      (release == null ? metadata?.barcode ?? metadata?.isbn : null);
  String? get barcode => identifierCode;
  String? get variant => release == null ? metadata?.variant : null;
  String? get referenceFormatLabel =>
      release?.displayFormat ??
      (release == null
          ? metadata?.physicalFormatLabel ?? metadata?.physicalFormat
          : null);
  String? get format => referenceFormatLabel;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
