import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_domain.dart';

final class BookHierarchyMapper {
  const BookHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(
    Iterable<BookRelease> releases,
  ) {
    return [
      for (var index = 0; index < releases.length; index++)
        _releaseNode(releases.elementAt(index), index + 1),
    ];
  }

  static LibraryHierarchyNode _releaseNode(BookRelease release, int number) {
    final releaseId = release.id.isEmpty ? 'release-$number' : release.id;
    final variants = [
      for (var index = 0; index < release.variants.length; index++)
        _variantNode(release, release.variants[index], index + 1),
    ];
    return LibraryHierarchyNode(
      id: releaseId,
      label: release.title,
      secondaryLabel: _releaseSecondaryLabel(release),
      level: variants.isEmpty
          ? LibraryHierarchyLevel.leaf
          : LibraryHierarchyLevel.container,
      imageUrl: release.thumbnailImageUrl ?? release.coverImageUrl,
      totalCount: variants.isEmpty ? null : variants.length,
      children: variants,
      metadata: {
        'kind': 'book_release',
        'releaseId': release.id,
        'number': number,
        if (release.workId != null) 'workId': release.workId,
        if (release.isbn != null) 'isbn': release.isbn,
        if (release.upc != null) 'upc': release.upc,
        if (release.publisher != null) 'publisher': release.publisher,
        if (release.distributor != null) 'distributor': release.distributor,
        if (release.releaseDate != null)
          'releaseDate': release.releaseDate!.toIso8601String(),
        if (release.pageCount != null) 'pageCount': release.pageCount,
        if (release.language != null) 'language': release.language,
        if (release.region != null) 'region': release.region,
        if (release.releaseStatus != null)
          'releaseStatus': release.releaseStatus,
        if (release.physicalFormat != null) 'format': release.physicalFormat,
        if (release.editionStatement != null)
          'editionStatement': release.editionStatement,
        if (release.dimensions != null) 'dimensions': release.dimensions,
        if (release.audioLengthMinutes != null)
          'audioLengthMinutes': release.audioLengthMinutes,
      },
    );
  }

  static LibraryHierarchyNode _variantNode(
    BookRelease release,
    BookVariantRef variant,
    int number,
  ) {
    final variantId = variant.id.isEmpty
        ? '${release.id}-variant-$number'
        : '${release.id}::${variant.id}';
    return LibraryHierarchyNode(
      id: variantId,
      label: variant.name,
      secondaryLabel: variant.physicalFormatLabel ?? variant.physicalFormat,
      level: LibraryHierarchyLevel.leaf,
      imageUrl: variant.thumbnailImageUrl ?? variant.coverImageUrl,
      metadata: {
        'kind': 'book_variant',
        'releaseId': release.id,
        'variantId': variant.id,
        if (variant.variantType != null) 'variantType': variant.variantType,
        if (variant.sku != null) 'sku': variant.sku,
        if (variant.barcode != null) 'barcode': variant.barcode,
        if (variant.isbn != null) 'isbn': variant.isbn,
        if (variant.region != null) 'region': variant.region,
        if (variant.physicalFormat != null) 'format': variant.physicalFormat,
      },
    );
  }

  static String? _releaseSecondaryLabel(BookRelease release) {
    final values = <String>[];
    final format = release.physicalFormatLabel ?? release.physicalFormat;
    if (format != null && format.trim().isNotEmpty) {
      values.add(format);
    }
    if (release.releaseDate != null) {
      values.add(release.releaseDate!.year.toString());
    }
    if (release.pageCount != null) {
      values.add('${release.pageCount} pages');
    }
    return values.isEmpty ? null : values.join(' · ');
  }
}
