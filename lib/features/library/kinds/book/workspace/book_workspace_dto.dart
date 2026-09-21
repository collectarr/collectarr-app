import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BookWorkspaceDto implements LibraryWorkspaceDto {
  BookWorkspaceDto({
    required this.common,
    required this.personal,
    required this.book,
    this.release,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final BookCatalogItem book;
  final BookRelease? release;
  final BookCatalogMetadata? metadata;

  BookEditionMetadata? get _selectedEdition {
    if (release == null) return metadata?.editions.firstOrNull;
    for (final edition in metadata?.editions ?? const <BookEditionMetadata>[]) {
      if (edition.id == release!.id) return edition;
    }
    return null;
  }

  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters:
  int? get pageCount =>
      release?.pageCount ??
      _selectedEdition?.pageCount ??
      book.publishing.pageCount;
  String? get imprint =>
      release?.imprint ?? _selectedEdition?.imprint ?? book.publishing.imprint;
  String? get author =>
      metadata?.authors.firstOrNull ?? book.work.creators.firstOrNull?.name;
  String? get publisher =>
      release?.publisher ??
      _selectedEdition?.publisher ??
      (release == null ? book.publisher : null);
  String? get itemNumber => null;
  String? get seriesTitle => book.series?.seriesTitle;
  DateTime? get releaseDate =>
      release?.releaseDate ??
      (release == null
          ? book.work.originalPublicationDate ?? common.releaseDate
          : null);
  String? get country =>
      release?.region ?? (release == null ? book.country : null);
  String? get language =>
      release?.language ?? (release == null ? book.language : null);
  String? get variant =>
      release?.title ?? (release == null ? book.displayEditionLabel : null);
  String? get isbn =>
      release?.isbn ??
      release?.upc ??
      _selectedEdition?.isbn ??
      (release == null ? book.barcode : null);
  String? get identifierCode => isbn;
  String? get barcode => identifierCode;
  String? get subtitle => metadata?.subtitle;
  String? get format =>
      release?.physicalFormatLabel ??
      release?.physicalFormat ??
      _selectedEdition?.physicalFormatLabel ??
      _selectedEdition?.format;
  String? get referenceFormatLabel => format;
  String? get translator => metadata?.translators.firstOrNull;
  String? get editor => metadata?.editors.firstOrNull;
  String? get illustrator => metadata?.illustrators.firstOrNull;
  String? get coverArtist => metadata?.coverArtists.firstOrNull;
  String? get printing => _selectedEdition?.printing;
  String? get numberLine => _selectedEdition?.numberLine;
  bool get firstEdition =>
      release?.firstEdition ??
      _selectedEdition?.firstEdition ??
      (book.publishing.firstEdition ?? false);
  String? get dewey => _selectedEdition?.dewey ?? book.publishing.dewey;
  String? get locClassification => _selectedEdition?.locClassification;
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
