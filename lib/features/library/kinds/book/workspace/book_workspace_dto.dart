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

  // Domain convenience getters:
  int? get pageCount => _catalog.publishing?.pageCount ?? book.pageCount;
  String? get imprint => _catalog.publishing?.imprint ?? book.imprint;
  String? get author =>
      _catalog.authors.firstOrNull ?? book.creators.firstOrNull?.name;
  String? get publisher => book.publisher;
  String? get itemNumber => _catalog.itemNumber ?? book.itemNumber;
  String? get seriesTitle => book.seriesTitle;
  DateTime? get releaseDate => common.releaseDate;
  String? get country => book.country;
  String? get language => book.language;
  String? get variant => _rawText('variant');
  String? get isbn =>
      _rawText('isbn') ??
      _rawText('isbn13') ??
      _rawText('isbn10') ??
      book.barcode;
  String? get identifierCode => isbn;
  String? get barcode => identifierCode;
  String? get subtitle => _catalog.subtitle;
  String? get format => book.physicalFormatLabel;
  String? get referenceFormatLabel => format;
  String? get translator => _catalog.translators.firstOrNull;
  String? get editor => _catalog.editors.firstOrNull;
  String? get illustrator => _catalog.illustrators.firstOrNull;
  String? get coverArtist => _catalog.coverArtists.firstOrNull;
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

  String? _rawText(String key) {
    final value = _catalog.rawPayload[key];
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  BookCatalogMetadata get _catalog => metadata ?? book.catalogMetadata;
}
