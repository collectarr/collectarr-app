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
  const ProviderCandidateImage({super.key, required this.candidate});

  final ProviderCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return LibraryCoverImage(
      title: candidate.title,
      imageUrl: candidate.imageUrl,
    );
  }
}
