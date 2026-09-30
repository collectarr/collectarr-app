import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

/// Maps the flat Book Catalog Item response into its kind-owned domain model.
final class BookCatalogMapper {
  const BookCatalogMapper._();

  static BookCatalogItem mapMetadataItemToBook(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    final parsed = rawMetadata is BookCatalogMetadata
        ? rawMetadata
        : BookCatalogMetadata.fromJson(item.toSyncPayload());
    final metadata = parsed.copyWith(title: item.title);
    return BookCatalogItem(
      id: item.id,
      title: item.title,
      catalogMetadata: metadata,
      releaseDate:
          item.releaseDate ?? _date(metadata.rawPayload['release_date']),
      coverImageUrl:
          item.coverImageUrl ?? _text(metadata.rawPayload['cover_image_url']),
      thumbnailImageUrl: item.thumbnailImageUrl ??
          _text(metadata.rawPayload['thumbnail_image_url']),
      printings: _catalogPrintings(metadata.rawPayload['printings']),
    );
  }

  static List<BookCatalogPrinting> _catalogPrintings(Object? value) {
    if (value is! Iterable) return const [];
    final result = <BookCatalogPrinting>[];
    for (final entry in value) {
      if (entry is! Map) continue;
      final json = Map<String, dynamic>.from(entry);
      final id = _text(json['id']);
      if (id == null) continue;
      result.add(
        BookCatalogPrinting(
          id: id,
          printingNumber: _integer(json['printing_number']),
          title: _text(json['title']),
          releaseDate: _date(json['release_date']),
          publisher: _text(json['publisher']),
          language: _text(json['language']),
          isbn: _text(json['isbn']),
        ),
      );
    }
    return List<BookCatalogPrinting>.unmodifiable(result);
  }
}

int? _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

DateTime? _date(Object? value) =>
    value is DateTime ? value : DateTime.tryParse(value?.toString() ?? '');

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
