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

  BookRelease? get _effectiveRelease => release ?? book.primaryRelease;
  BookEditionMetadata? get _effectiveEdition {
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
      _effectiveRelease?.pageCount ??
      _effectiveEdition?.pageCount ??
      book.publishing.pageCount;
  String? get imprint =>
      _effectiveRelease?.imprint ??
      _effectiveEdition?.imprint ??
      book.publishing.imprint;
  String? get author =>
      metadata?.authors.firstOrNull ?? book.work.creators.firstOrNull?.name;
  String? get publisher =>
      _effectiveRelease?.publisher ??
      _effectiveEdition?.publisher ??
      (release == null ? book.publisher : null);
  String? get itemNumber => null;
  String? get seriesTitle => book.series?.seriesTitle;
  DateTime? get releaseDate =>
      _effectiveRelease?.releaseDate ??
      (release == null
          ? book.work.originalPublicationDate ?? common.releaseDate
          : null);
  String? get country =>
      _effectiveRelease?.region ?? (release == null ? book.country : null);
  String? get language =>
      _effectiveRelease?.language ?? (release == null ? book.language : null);
  String? get variant =>
      _effectiveRelease?.title ??
      (release == null ? book.displayEditionLabel : null);
  String? get isbn =>
      _effectiveRelease?.isbn ??
      _effectiveRelease?.upc ??
      _effectiveEdition?.isbn ??
      (release == null ? book.barcode : null);
  String? get identifierCode => isbn;
  String? get barcode => identifierCode;
  String? get subtitle => metadata?.subtitle;
  String? get format =>
      _effectiveRelease?.physicalFormatLabel ??
      _effectiveRelease?.physicalFormat ??
      _effectiveEdition?.physicalFormatLabel ??
      _effectiveEdition?.format;
  String? get referenceFormatLabel => format;
  String? get translator => metadata?.translators.firstOrNull;
  String? get editor => metadata?.editors.firstOrNull;
  String? get illustrator => metadata?.illustrators.firstOrNull;
  String? get coverArtist => metadata?.coverArtists.firstOrNull;
  String? get printing => _effectiveEdition?.printing;
  String? get numberLine => _effectiveEdition?.numberLine;
  bool get firstEdition =>
      _effectiveRelease?.firstEdition ??
      _effectiveEdition?.firstEdition ??
      (book.publishing.firstEdition ?? false);
  String? get dewey => _effectiveEdition?.dewey ?? book.publishing.dewey;
  String? get locClassification => _effectiveEdition?.locClassification;
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
