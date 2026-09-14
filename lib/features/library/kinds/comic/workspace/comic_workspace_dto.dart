import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceDto extends WorkspaceDtoAdapter {
  ComicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.comic,
    this.ownedItem,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final ComicMedia comic;
  final ComicOwnedItem? ownedItem;

  // Domain convenience getters
  String? get writer => comic.writers.firstOrNull;
  String? get artist => comic.artists.firstOrNull;
  String? get coverArtist => comic.coverArtists.firstOrNull;
  String? get imprint => comic.imprint ?? comic.publishing?.imprint;
  String? get publisher => comic.publisher ?? imprint;
  @override
  String? get seriesTitle => comic.seriesTitle ?? comic.series?.seriesTitle;
  @override
  String? get itemNumber => comic.issueNumber;
  @override
  DateTime? get releaseDate => comic.releaseDate ?? common.releaseDate;
  @override
  String? get country => comic.country;
  @override
  String? get language => comic.language;
  @override
  String? get identifierCode => comic.barcode;
  String? get barcode => identifierCode;
  @override
  String? get variant => comic.variant;
  @override
  String? get referenceFormatLabel =>
      comic.physicalFormatLabel ?? comic.physicalFormat;
  @override
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
