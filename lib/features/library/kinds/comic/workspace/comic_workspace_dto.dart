import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceDto implements LibraryWorkspaceDto {
  ComicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.comic,
    this.release,
    this.ownedItem,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final ComicMedia comic;
  final ComicRelease? release;
  final ComicOwnedItem? ownedItem;

  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters
  String? get writer => comic.writers.firstOrNull;
  String? get artist => comic.artists.firstOrNull;
  String? get coverArtist => comic.coverArtists.firstOrNull;
  String? get imprint =>
      release?.imprint ??
      (release == null ? comic.imprint ?? comic.publishing?.imprint : null);
  String? get publisher =>
      release?.publisher ??
      (release == null ? comic.publisher : null) ??
      (release == null ? imprint : null);
  String? get seriesTitle => comic.seriesTitle ?? comic.series?.seriesTitle;
  String? get itemNumber => comic.issueNumber;
  DateTime? get releaseDate =>
      release?.releaseDate ?? (release == null ? common.releaseDate : null);
  String? get country => release == null ? comic.country : null;
  String? get language => release == null ? comic.language : null;
  String? get identifierCode =>
      release?.upc ?? release?.isbn ?? (release == null ? comic.barcode : null);
  String? get barcode => identifierCode;
  String? get variant {
    if (release == null) return comic.variant;
    final names = release!.variants
        .map((variant) => variant.name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    return names.isEmpty ? null : names.join(', ');
  }
  String? get referenceFormatLabel => release == null
      ? comic.physicalFormatLabel ?? comic.physicalFormat
      : null;
  String? get format => referenceFormatLabel;
  int? get pageCount => release == null
      ? comic.pageCount ?? comic.publishing?.pageCount
      : null;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (writer != null) writer!,
        if (artist != null) artist!,
        if (coverArtist != null) coverArtist!,
      ];
}
