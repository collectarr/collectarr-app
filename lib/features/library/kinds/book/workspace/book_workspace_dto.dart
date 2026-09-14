import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceDto implements LibraryWorkspaceDto {
  BookWorkspaceDto({
    required this.common,
    required this.personal,
    required this.book,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final BookCatalogItem book;
  final BookCatalogMetadata? metadata;
  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters:
  int? get pageCount =>
      metadata?.editions.firstOrNull?.pageCount ?? book.publishing.pageCount;
  String? get imprint =>
      metadata?.editions.firstOrNull?.imprint ?? book.publishing.imprint;
  String? get author =>
      metadata?.authors.firstOrNull ?? book.work.creators.firstOrNull?.name;
  String? get publisher =>
      book.publisher ?? metadata?.editions.firstOrNull?.publisher;
  String? get itemNumber => null;
  String? get seriesTitle => book.series?.seriesTitle;
  DateTime? get releaseDate => book.releaseDate ?? common.releaseDate;
  String? get country => book.country;
  String? get language => book.language;
  String? get variant => book.displayEditionLabel;
  String? get isbn =>
      metadata?.editions.firstOrNull?.isbn ?? book.releases.firstOrNull?.isbn;
  String? get identifierCode => isbn;
  String? get barcode => identifierCode;
  String? get subtitle => metadata?.subtitle;
  String? get format => metadata?.editions.firstOrNull?.format;
  String? get referenceFormatLabel => format;
  String? get translator => metadata?.translators.firstOrNull;
  String? get editor => metadata?.editors.firstOrNull;
  String? get illustrator => metadata?.illustrators.firstOrNull;
  String? get coverArtist => metadata?.coverArtists.firstOrNull;
  String? get printing => metadata?.editions.firstOrNull?.printing;
  String? get numberLine => metadata?.editions.firstOrNull?.numberLine;
  bool get firstEdition =>
      metadata?.editions.firstOrNull?.firstEdition ??
      (book.publishing.firstEdition ?? false);
  String? get dewey =>
      metadata?.editions.firstOrNull?.dewey ?? book.publishing.dewey;
  String? get locClassification =>
      metadata?.editions.firstOrNull?.locClassification;
  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (author != null) author!,
        if (subtitle != null) subtitle!,
        if (translator != null) translator!,
        if (editor != null) editor!,
        if (illustrator != null) illustrator!,
      ];
}
