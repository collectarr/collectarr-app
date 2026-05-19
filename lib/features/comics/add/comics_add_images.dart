import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:flutter/material.dart';

class AddComicCoverImage extends StatelessWidget {
  const AddComicCoverImage({super.key, required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return LibraryCoverImage(
      title: item.title,
      itemNumber: item.itemNumber,
      imageUrl: item.displayCoverUrl,
    );
  }
}

class ProviderCandidateImage extends StatelessWidget {
  const ProviderCandidateImage({
    super.key,
    required this.candidate,
    this.fallbackTitle,
  });

  final ProviderCandidate candidate;
  final String? fallbackTitle;

  @override
  Widget build(BuildContext context) {
    final title = fallbackTitle ?? candidate.title;
    if (_shouldUseGeneratedCandidateCover(candidate)) {
      return LibraryGeneratedCover(title: title);
    }
    return LibraryCoverImage(
      title: title,
      imageUrl: candidate.imageUrl,
    );
  }
}

bool _shouldUseGeneratedCandidateCover(ProviderCandidate candidate) {
  return candidate.provider == 'gcd' &&
      candidate.isVariant &&
      (candidate.imageUrl == null || candidate.imageUrl!.isEmpty);
}
