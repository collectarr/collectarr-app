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
  int? get pageCount =>
      metadata?.publishing?.pageCount ?? book.publishing.pageCount;
  String? get imprint =>
      metadata?.publishing?.imprint ?? book.publishing.imprint;
  String? get author =>
      metadata?.authors.firstOrNull ?? book.work.creators.firstOrNull?.name;
  String? get publisher => metadata?.publisher ?? metadata?.originalPublisher;
  String? get itemNumber =>
      metadata?.itemNumber ?? metadata?.rawPayload['item_number']?.toString();
  String? get seriesTitle => metadata?.seriesTitle ?? book.series?.seriesTitle;
  DateTime? get releaseDate => common.releaseDate;
  String? get country => metadata?.country;
  String? get language => metadata?.language;
  String? get variant => metadata?.variant;
  String? get isbn =>
      _rawText('isbn') ??
      _rawText('isbn13') ??
      _rawText('isbn10') ??
      metadata?.barcode;
  String? get identifierCode => isbn;
  String? get barcode => identifierCode;
  String? get subtitle => metadata?.subtitle;
  String? get format =>
      metadata?.physicalFormatLabel ?? metadata?.physicalFormat;
  String? get referenceFormatLabel => format;
  String? get translator => metadata?.translators.firstOrNull;
  String? get editor => metadata?.editors.firstOrNull;
  String? get illustrator => metadata?.illustrators.firstOrNull;
  String? get coverArtist => metadata?.coverArtists.firstOrNull;
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
    final value = metadata?.rawPayload[key];
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
