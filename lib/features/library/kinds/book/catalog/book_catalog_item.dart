import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

class BookCreatorCredit {
  const BookCreatorCredit({
    required this.name,
    required this.role,
    this.imageUrl,
  });

  final String name;
  final String role;
  final String? imageUrl;
}

/// A printing contained by one concrete Book Catalog Item.
///
/// A printing is child catalog data, never another workspace item.
class BookCatalogPrinting {
  const BookCatalogPrinting({
    required this.id,
    this.printingNumber,
    this.title,
    this.releaseDate,
    this.publisher,
    this.language,
    this.isbn,
  });

  final String id;
  final int? printingNumber;
  final String? title;
  final DateTime? releaseDate;
  final String? publisher;
  final String? language;
  final String? isbn;
}

/// One concrete book edition in the shared Catalog Item workspace.
///
/// Catalog-level edition facts live on this root. Only printings are contained
/// children; the model has no Work or Release nodes.
class BookCatalogItem {
  const BookCatalogItem({
    required this.id,
    required this.title,
    required this.catalogMetadata,
    this.releaseDate,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.printings = const [],
  });

  static BookCatalogItem fromDto(CatalogItemDto dto) =>
      BookCatalogMapper.mapMetadataItemToBook(dto);

  final String id;
  final String title;
  final BookCatalogMetadata catalogMetadata;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final List<BookCatalogPrinting> printings;

  String? get originalTitle => catalogMetadata.originalTitle;
  String? get synopsis => catalogMetadata.synopsis;
  String? get country => catalogMetadata.country;
  String? get language => catalogMetadata.language;
  String? get publisher =>
      catalogMetadata.publisher ?? catalogMetadata.originalPublisher;
  String? get seriesTitle =>
      catalogMetadata.seriesTitle ?? catalogMetadata.series?.seriesTitle;
  List<String> get authors => catalogMetadata.authors;
  List<String> get genres => catalogMetadata.genres;
  List<Map<String, dynamic>> get creatorData => catalogMetadata.creators;
  List<BookCreatorCredit> get creators => [
        for (final creator in catalogMetadata.creators)
          if (_text(creator['name'] ?? creator['display_name'])
              case final name?)
            BookCreatorCredit(
              name: name,
              role: _text(creator['role'] ?? creator['type']) ?? '',
              imageUrl: _text(creator['image_url']),
            ),
        if (catalogMetadata.creators.isEmpty)
          for (final author in catalogMetadata.authors)
            BookCreatorCredit(name: author, role: 'Author'),
      ];
  String? get physicalFormatLabel =>
      catalogMetadata.physicalFormatLabel ?? catalogMetadata.physicalFormat;
  int? get pageCount =>
      catalogMetadata.publishing?.pageCount ?? _integer('page_count');
  String? get imprint =>
      catalogMetadata.publishing?.imprint ?? _rawText('imprint');
  String? get barcode =>
      catalogMetadata.barcode ??
      _rawText('isbn') ??
      _rawText('isbn13') ??
      _rawText('isbn10');
  String? get itemNumber =>
      catalogMetadata.itemNumber ?? _rawText('item_number');
  int? get releaseYear => releaseDate?.year;
  String? get displayCoverUrl => coverImageUrl ?? _rawText('cover_image_url');
  String? get displayTitle => title;
  String? get localizedTitle =>
      catalogMetadata.rawPayload['localized_title'] as String?;
  List<String> get searchAliases =>
      (catalogMetadata.rawPayload['search_aliases'] as List?)
          ?.whereType<String>()
          .toList(growable: false) ??
      const [];

  String? _rawText(String key) => _text(catalogMetadata.rawPayload[key]);

  int? _integer(String key) {
    final value = catalogMetadata.rawPayload[key];
    return value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
  }
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
