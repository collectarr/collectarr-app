import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';

typedef BookWorkDtoFetcher = Future<BookWorkDto> Function(String id);

final class BookCoreMapper {
  const BookCoreMapper._();

  static BookMedia fromWorkDto(BookWorkDto dto) {
    _validateKind(dto.kind, 'work');
    return BookMedia(
      id: BookMediaId(dto.id),
      title: dto.title,
      sortTitle: dto.sortTitle,
      description: dto.description,
      firstPublicationDate: dto.firstPublicationDate,
      originalLanguage: dto.originalLanguage,
      originalPublicationDate: dto.originalPublicationDate,
      subtitle: dto.subtitle,
      searchAliases: List<String>.from(dto.searchAliases),
      genres: List<String>.from(dto.genres),
      contributors: List<dynamic>.from(dto.contributors),
      editions: dto.editions.map(fromEditionDto).toList(growable: false),
      series: List<dynamic>.from(dto.series),
      rawPayload: dto.toJson(),
    );
  }

  static BookRelease fromEditionDto(BookEditionDto dto) {
    _validateKind(dto.kind, 'edition');
    final raw = dto.raw;
    final physicalFormatLabel =
        _textValue(raw['physical_format_label']) ?? dto.format ?? dto.binding;

    return BookRelease(
      id: dto.id,
      title: dto.displayTitle ?? dto.titleValue,
      workId: _textValue(dto.workId),
      titleValue: dto.titleValue,
      displayTitle: dto.displayTitle,
      ageRating: dto.ageRating,
      audioLengthMinutes: dto.audioLengthMinutes,
      binding: dto.binding,
      contributors: List<dynamic>.from(dto.contributors),
      coverImageKey: dto.coverImageKey,
      publisher: dto.publisher,
      distributor: _textValue(raw['distributor']),
      description: dto.description,
      editionStatement: dto.editionStatement,
      isbn: dto.isbn,
      identifiers: List<dynamic>.from(dto.identifiers),
      imprint: dto.imprint,
      upc: dto.upc,
      pageCount: dto.pageCount,
      language: dto.language,
      region: dto.region,
      releaseDate: dto.publicationDate,
      releaseStatus: dto.releaseStatus,
      physicalFormat: dto.format ?? dto.binding,
      physicalFormatLabel: physicalFormatLabel,
      coverImageUrl: dto.coverImageUrlValue,
      thumbnailImageUrl: dto.thumbnailImageUrl,
      dimensions: _textValue(raw['dimensions']),
      firstEdition: raw['first_edition'] as bool?,
      variants: _mapVariants(raw['variants']),
    );
  }

  static void _validateKind(String? kind, String dtoType) {
    if (kind != null && kind.trim().toLowerCase() != 'book') {
      throw StateError('Expected a book Core DTO for $dtoType, got $kind');
    }
  }

  static List<BookVariantRef> _mapVariants(Object? value) {
    if (value is! List) return const <BookVariantRef>[];
    return [
      for (final entry in value)
        if (entry is Map<Object?, Object?>)
          BookVariantRef(
            id: _textValue(entry['id']) ?? '',
            name: _textValue(entry['name']) ?? 'Variant',
            variantType: _textValue(entry['variant_type']),
            sku: _textValue(entry['sku']),
            barcode: _textValue(entry['barcode']),
            isbn: _textValue(entry['isbn']),
            region: _textValue(entry['region']),
            coverImageUrl: _textValue(entry['cover_image_url']),
            thumbnailImageUrl: _textValue(entry['thumbnail_image_url']),
            physicalFormat: _textValue(entry['physical_format']),
            physicalFormatLabel: _textValue(entry['physical_format_label']),
            isPrimary: entry['is_primary'] == true,
          ),
    ];
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
