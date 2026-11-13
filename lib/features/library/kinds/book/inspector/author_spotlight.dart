import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/dto.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_cache.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Authors precede the edition identity, as in the Books reference inspector.
Widget? buildBookAuthorSpotlight({
  required LibraryProjectionView item,
  ValueChanged<String>? onFilterByValue,
}) {
  final dto = item.dto;
  if (dto is! BookWorkspaceDto) return null;
  final authors = dto.metadata.creators
      .where((credit) =>
          (credit.role == null || credit.role!.toLowerCase() == 'author') &&
          credit.name.trim().isNotEmpty)
      .toList();
  if (authors.isEmpty) return null;
  return Builder(
      builder: (context) =>
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final author in authors)
              Row(children: [
                if (author.imageUrl?.trim().isNotEmpty == true) ...[
                  SizedBox.square(
                    dimension: 48,
                    child: CachedNetworkImage(
                      cacheManager: libraryCoverCacheManager,
                      imageUrl: author.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: InkWell(
                    onTap: onFilterByValue == null
                        ? null
                        : () => onFilterByValue(author.name),
                    child: Text(author.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: appPalette(context).textPrimary,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
          ]));
}
