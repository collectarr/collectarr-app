import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceDto implements LibraryWorkspaceDto {
  ComicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.comic,
    this.ownedItem,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final ComicCatalogItem comic;
  final ComicOwnedItem? ownedItem;

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

  // Domain convenience getters
  String? get writer => comic.writers.firstOrNull;
  String? get artist => comic.artists.firstOrNull;
  String? get coverArtist => comic.coverArtists.firstOrNull;
  String? get imprint => comic.imprint ?? comic.publishing?.imprint;
  String? get publisher =>
      comic.publisher ?? comic.publishing?.originalPublisher ?? imprint;
  String? get seriesTitle => comic.seriesTitle ?? comic.series?.seriesTitle;
  String? get itemNumber => comic.issueNumber;
  DateTime? get releaseDate => common.releaseDate ?? comic.releaseDate;
  String? get country => comic.country;
  String? get language => comic.language;
  String? get identifierCode => comic.barcode ?? comic.upc ?? comic.isbn;
  String? get barcode => identifierCode;
  String? get variant => comic.variant;

  String? get referenceFormatLabel =>
      comic.physicalFormatLabel ?? comic.physicalFormat;
  String? get format => referenceFormatLabel;
  int? get pageCount => comic.pageCount ?? comic.publishing?.pageCount;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (writer != null) writer!,
        if (artist != null) artist!,
        if (coverArtist != null) coverArtist!,
      ];
}
