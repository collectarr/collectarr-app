import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceDto implements LibraryWorkspaceDto {
  ComicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.comic,
    this.libraryEntry,
  });

  final WorkspaceCommonProjection common;
  final PersonalEntryProjection personal;
  final ComicCatalogItem comic;
  final ComicLibraryEntry? libraryEntry;

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
  String? get writer => _creatorNameForRole('writer');
  String? get artist => _creatorNameForRole('artist');
  String? get coverArtist => _creatorNameForRole('coverartist');
  String? get imprint => comic.imprint;
  String? get publisher => comic.publisher ?? imprint;
  String? get seriesTitle => comic.seriesTitle;
  String? get itemNumber => comic.issueNumber;
  DateTime? get releaseDate => common.releaseDate ?? comic.releaseDate;
  String? get country => comic.country;
  String? get language => comic.language;
  String? get identifierCode => comic.barcode ?? comic.upc ?? comic.isbn;
  String? get barcode => identifierCode;
  String? get variant => comic.variant;

  String? get referenceFormatLabel => comic.physicalFormat;
  String? get format => referenceFormatLabel;
  int? get pageCount => comic.pageCount;

  String? _creatorNameForRole(String expectedRole) => [
        ...comic.contributors,
        ...comic.creators,
      ]
          .where((creator) {
            final role = (creator.roleId ?? creator.role ?? '')
                .toLowerCase()
                .replaceAll(RegExp('[^a-z]'), '');
            return role == expectedRole;
          })
          .map((creator) => creator.name)
          .firstOrNull;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (writer != null) writer!,
        if (artist != null) artist!,
        if (coverArtist != null) coverArtist!,
      ];
}
