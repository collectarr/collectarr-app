import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MangaWorkspaceDto implements LibraryWorkspaceDto {
  MangaWorkspaceDto({
    required this.common,
    required this.personal,
    this.metadata,
    this.entryDetails,
  });

  final WorkspaceCommonProjection common;
  final PersonalEntryProjection personal;

  final MangaMetadata? metadata;
  final MangaEntryDetails? entryDetails;

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

  String? get publisher => metadata?.publisher;
  String? get seriesTitle => metadata?.seriesTitle;
  String? get itemNumber =>
      metadata?.itemNumber ?? metadata?.volumeNumber?.toString();
  DateTime? get releaseDate =>
      metadata?.releaseDate?.asDateTime ?? common.releaseDate;
  String? get country => metadata?.country;
  String? get language => metadata?.language;
  String? get identifierCode => metadata?.barcode ?? metadata?.isbn;
  String? get barcode => identifierCode;
  String? get variant => metadata?.variant;
  String? get referenceFormatLabel => metadata?.physicalFormat;
  String? get format => referenceFormatLabel;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
