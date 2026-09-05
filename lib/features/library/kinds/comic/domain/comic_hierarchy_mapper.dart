import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';

import 'comic_metadata.dart';

/// Projects Comic's typed media -> release -> variant graph for the hierarchy UI.
final class ComicHierarchyMapper {
  const ComicHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(ComicMedia media) {
    return [
      for (var index = 0; index < media.releases.length; index++)
        _releaseNode(media, media.releases[index], index + 1),
    ];
  }

  static LibraryHierarchyNode _releaseNode(
    ComicMedia media,
    ComicRelease release,
    int number,
  ) {
    final variants = [
      for (var index = 0; index < release.variants.length; index++)
        _variantNode(release, release.variants[index], index + 1),
    ];
    final details = <String>[];
    if (release.publisher?.trim().isNotEmpty == true) {
      details.add(release.publisher!.trim());
    }
    if (release.releaseDate != null) {
      details.add('${release.releaseDate!.year}');
    }
    if (variants.isNotEmpty) details.add('${variants.length} variants');
    final fallbackId = '${media.id?.value ?? media.title}:release:$number';
    return LibraryHierarchyNode(
      id: release.id.isEmpty ? fallbackId : release.id,
      label: release.title.trim().isEmpty ? 'Issue $number' : release.title,
      secondaryLabel: details.isEmpty ? null : details.join(' Â· '),
      level: variants.isEmpty
          ? LibraryHierarchyLevel.leaf
          : LibraryHierarchyLevel.container,
      imageUrl: release.coverImageUrl,
      totalCount: variants.isEmpty ? null : variants.length,
      children: variants,
      metadata: {
        'kind': 'comic_release',
        'releaseId': release.id,
        'number': number,
        if (release.publisher != null) 'publisher': release.publisher,
        if (release.imprint != null) 'imprint': release.imprint,
        if (release.isbn != null) 'isbn': release.isbn,
        if (release.upc != null) 'upc': release.upc,
        if (release.releaseDate != null)
          'releaseDate': release.releaseDate!.toIso8601String(),
      },
    );
  }

  static LibraryHierarchyNode _variantNode(
    ComicRelease release,
    CatalogVariant variant,
    int number,
  ) {
    final format = variant.physicalFormatLabel ?? variant.physicalFormat;
    return LibraryHierarchyNode(
      id: variant.id.isEmpty
          ? '${release.id}:variant:$number'
          : '${release.id}:variant:${variant.id}',
      label: variant.name,
      secondaryLabel: format,
      level: LibraryHierarchyLevel.leaf,
      imageUrl: variant.thumbnailImageUrl ?? variant.coverImageUrl,
      metadata: {
        'kind': 'comic_variant',
        'releaseId': release.id,
        'variantId': variant.id,
        if (variant.variantType != null) 'variantType': variant.variantType,
        if (variant.sku != null) 'sku': variant.sku,
        if (variant.barcode != null) 'barcode': variant.barcode,
        if (variant.isbn != null) 'isbn': variant.isbn,
        if (variant.region != null) 'region': variant.region,
        if (format != null) 'format': format,
      },
    );
  }
}
