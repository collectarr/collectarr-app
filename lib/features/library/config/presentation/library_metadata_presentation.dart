import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_widgets.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'library_search_presentation.dart';

class LibraryAddSearchResultDisplay {
  const LibraryAddSearchResultDisplay({
    required this.title,
    required this.secondaryLine,
    required this.detailLine,
  });

  final String title;
  final String? secondaryLine;
  final String? detailLine;
}

class LibraryMetadataPresentation {
  const LibraryMetadataPresentation({
    required this.identityFacts,
    required this.contextFacts,
    required this.creators,
    required this.characters,
    required this.storyArcs,
    required this.genres,
    this.labels = const LibraryMetadataLabels(),
  });

  final List<LibraryDetailField> identityFacts;
  final List<LibraryDetailField> contextFacts;
  final List<Map<String, dynamic>> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;
  final LibraryMetadataLabels labels;

  List<LibraryDetailField> get allFacts => [
        ...identityFacts,
        ...contextFacts,
      ];

  bool get hasCredits =>
      creators.isNotEmpty || characters.isNotEmpty || storyArcs.isNotEmpty;
}

class LibraryMetadataLabels {
  const LibraryMetadataLabels({
    this.identitySectionTitle = 'Catalog identity',
    this.contextSectionTitle = 'Catalog context',
    this.creditsSectionTitle = 'Credits & Discovery',
    this.creators = 'Creators',
    this.characters = 'Characters',
    this.storyArcs = 'Story Arcs',
    this.storyArcsInline = 'Story arcs',
    this.genres = 'Genres',
  });

  final String identitySectionTitle;
  final String contextSectionTitle;
  final String creditsSectionTitle;
  final String creators;
  final String characters;
  final String storyArcs;
  final String storyArcsInline;
  final String genres;
}

typedef LibraryMetadataFactTapResolver = VoidCallback? Function(String? value);

abstract class LibraryMediaPresentationBuilder {
  const LibraryMediaPresentationBuilder();

  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required LibraryMetadataItem item,
  }) {
    return null;
  }

  Widget? buildAddPreviewPane({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryMediaPreviewLabels previewLabels,
    required LibraryMetadataItem? item,
    required ProviderCandidate? candidate,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    return null;
  }

  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  });

  LibraryCardPresentation buildCardPresentation(
    LibraryProjectionRuntime item, {
    bool musicVertical = false,
  }) {
    return const LibraryCardPresentation();
  }

  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    return const [];
  }

  bool canOpenKindDrilldown(LibraryProjectionRuntime item) => false;

  Widget? buildKindDrilldown({
    required BuildContext context,
    required LibraryProjectionRuntime selectedItem,
    required Color accent,
    required double coverSize,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItem> ownedCopies,
    required List<WishlistItem> wishlistItems,
    required String? selectedReleaseId,
    required void Function(String releaseId) onSelectRelease,
    required LibraryWorkspaceProjector projector,
  }) =>
      null;

  List<Widget> buildDetailCatalogSections({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    return [
      buildDetailIdentitySection(
        context: context,
        singularLabel: singularLabel,
        mediaFields: mediaFields,
        releaseFields: releaseFields,
        item: item,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
      buildDetailContextSection(
        context: context,
        singularLabel: singularLabel,
        mediaFields: mediaFields,
        releaseFields: releaseFields,
        item: item,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
      buildDetailCreditsSection(
        context: context,
        singularLabel: singularLabel,
        mediaFields: mediaFields,
        releaseFields: releaseFields,
        item: item,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
    ];
  }

  Widget buildDetailIdentitySection({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      mediaFields: mediaFields,
      releaseFields: releaseFields,
      item: item,
      includeIdentityFacts: true,
      tapFor: _tapResolver(onFilterByValue),
    );
    final seriesRaw = item.source.catalogItem?.payload['series'];
    final series = seriesRaw is Map
        ? CatalogSeriesDetailsDto.fromJson(Map<String, dynamic>.from(seriesRaw))
        : null;
    final identityFacts = presentation.identityFacts.map((fact) {
      if (fact.label == 'Series' &&
          series?.seriesId != null &&
          series!.seriesId!.trim().isNotEmpty &&
          series.seriesTitle != null &&
          series.seriesTitle!.trim().isNotEmpty) {
        return LibraryDetailField(
          label: fact.label,
          value: fact.value,
          onTap: () => context.push(
            '/series/${Uri.encodeComponent(series.seriesId!)}?title=${Uri.encodeQueryComponent(series.seriesTitle!)}',
          ),
        );
      }
      return fact;
    }).toList(growable: false);
    return LibraryDetailSection(
      title: presentation.labels.identitySectionTitle,
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(fields: identityFacts),
      ],
    );
  }

  Widget buildDetailContextSection({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      mediaFields: mediaFields,
      releaseFields: releaseFields,
      item: item,
      includeIdentityFacts: false,
      tapFor: _tapResolver(onFilterByValue),
    );
    return LibraryDetailSection(
      title: presentation.labels.contextSectionTitle,
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(fields: presentation.contextFacts),
        if (presentation.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryDetailChipGroupWidget(
            label: presentation.labels.genres,
            values: presentation.genres,
            onValueTap: onFilterByValue,
          ),
        ],
      ],
    );
  }

  Widget buildDetailCreditsSection({
    required BuildContext context,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      mediaFields: mediaFields,
      releaseFields: releaseFields,
      item: item,
      includeIdentityFacts: false,
      tapFor: _tapResolver(onFilterByValue),
    );
    if (!presentation.hasCredits) {
      return const SizedBox.shrink();
    }
    return LibraryDetailSection(
      title: presentation.labels.creditsSectionTitle,
      accentColor: accent,
      children: [
        if (presentation.creators.isNotEmpty)
          LibraryMetadataCreditsList(
            title: presentation.labels.creators,
            credits: presentation.creators,
            onValueTap: (value) => context.push(
              '/creator/${Uri.encodeComponent(value)}',
            ),
          ),
        if (presentation.characters.isNotEmpty) ...[
          if (presentation.creators.isNotEmpty) const SizedBox(height: 8),
          LibraryDetailChipGroupWidget(
            label: presentation.labels.characters,
            values: presentation.characters,
            onValueTap: (value) => context.push(
              '/character/${Uri.encodeComponent(value)}',
            ),
          ),
        ],
        if (presentation.storyArcs.isNotEmpty) ...[
          if (presentation.creators.isNotEmpty ||
              presentation.characters.isNotEmpty)
            const SizedBox(height: 8),
          LibraryDetailChipGroupWidget(
            label: presentation.labels.storyArcs,
            values: presentation.storyArcs,
            onValueTap: (value) => context.push(
              '/story-arc/${Uri.encodeComponent(value)}',
            ),
          ),
        ],
      ],
    );
  }

  static LibraryMetadataFactTapResolver _tapResolver(
    ValueChanged<String>? onFilterByValue,
  ) {
    return (String? value) {
      if (onFilterByValue == null || value == null || value.trim().isEmpty) {
        return null;
      }
      return () => onFilterByValue(value.trim());
    };
  }
}
