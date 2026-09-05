import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_widgets.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/config/library_group_mode_category_models.dart';
import 'package:flutter/material.dart';

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

enum LibraryMetadataSectionPlacement { context, credits }

enum LibraryMetadataSectionRenderer { text, credits }

class LibraryMetadataSection {
  const LibraryMetadataSection({
    required this.values,
    this.placement = LibraryMetadataSectionPlacement.context,
    this.renderer = LibraryMetadataSectionRenderer.text,
    this.inlineLabelKey,
    this.completenessWeight = 4,
  });

  final List<Object?> values;
  final LibraryMetadataSectionPlacement placement;
  final LibraryMetadataSectionRenderer renderer;
  final String? inlineLabelKey;
  final int completenessWeight;
}

class LibraryMetadataPresentation {
  const LibraryMetadataPresentation({
    required this.identityFacts,
    required this.contextFacts,
    required this.sections,
    this.labels = const LibraryMetadataLabels(),
  });

  final List<LibraryDetailField> identityFacts;
  final List<LibraryDetailField> contextFacts;
  final Map<String, LibraryMetadataSection> sections;
  final LibraryMetadataLabels labels;

  List<LibraryDetailField> get allFacts => [
        ...identityFacts,
        ...contextFacts,
      ];
}

class LibraryMetadataLabels {
  const LibraryMetadataLabels({
    this.identitySectionTitle = 'Catalog identity',
    this.contextSectionTitle = 'Catalog context',
    this.creditsSectionTitle = 'Credits & Discovery',
    this.values = const {},
  });

  final String identitySectionTitle;
  final String contextSectionTitle;
  final String creditsSectionTitle;
  final Map<String, String> values;

  String labelFor(String key, {String? fallback}) =>
      values[key] ?? fallback ?? key;
}

typedef LibraryMetadataFactTapResolver = VoidCallback? Function(String? value);

List<String> libraryMetadataTextValues(LibraryMetadataSection section) {
  return section.values
      .map((value) => value?.toString().trim() ?? '')
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

List<Map<String, dynamic>> libraryMetadataCreditValues(
  LibraryMetadataSection section,
) {
  return section.values
      .whereType<Map<Object?, Object?>>()
      .map((value) => Map<String, dynamic>.from(value))
      .toList(growable: false);
}

abstract class LibraryMediaPresentationBuilder {
  const LibraryMediaPresentationBuilder();

  List<CatalogEditionDto> buildReleaseEditions({
    required CatalogItem item,
  }) =>
      const [];

  List<TrailerLinkDto> buildLinks({
    required CatalogItem item,
  }) =>
      const [];

  List<LibraryGroupModeCategory>? buildGroupModeCategories(
    List<String> modes,
  ) =>
      null;

  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogItem item,
  }) {
    return null;
  }

  Widget? buildAddPreviewPane({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required LibraryMediaPreviewLabels previewLabels,
    required CatalogItem? item,
    required ProviderCandidate? candidate,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    return null;
  }

  List<Widget> buildAddPreviewSections({
    required Color accent,
    required CatalogMediaKind kind,
    required String provider,
    required String providerItemId,
  }) {
    return const [];
  }

  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
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
    required LibraryProjectionRuntime item,
    required Color accent,
    LibraryRelationCapability? relationCapability,
    ValueChanged<String>? onFilterByValue,
  }) {
    return [
      buildDetailIdentitySection(
        context: context,
        singularLabel: singularLabel,
        item: item,
        accent: accent,
        relationCapability: relationCapability,
        onFilterByValue: onFilterByValue,
      ),
      buildDetailContextSection(
        context: context,
        singularLabel: singularLabel,
        item: item,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
      buildDetailCreditsSection(
        context: context,
        singularLabel: singularLabel,
        item: item,
        accent: accent,
        onFilterByValue: onFilterByValue,
      ),
    ];
  }

  Widget buildDetailIdentitySection({
    required BuildContext context,
    required String singularLabel,
    required LibraryProjectionRuntime item,
    required Color accent,
    LibraryRelationCapability? relationCapability,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      item: item,
      includeIdentityFacts: true,
      tapFor: _tapResolver(onFilterByValue),
    );
    final relationTarget = relationCapability?.targetFor(item);
    final identityFacts = presentation.identityFacts.map((fact) {
      if (relationTarget != null &&
          fact.label == relationTarget.label &&
          fact.value.trim() == relationTarget.title) {
        return LibraryDetailField(
          label: fact.label,
          value: fact.value,
          onTap: () => relationCapability!.openTarget(context, relationTarget),
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
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      item: item,
      includeIdentityFacts: false,
      tapFor: _tapResolver(onFilterByValue),
    );
    return LibraryDetailSection(
      title: presentation.labels.contextSectionTitle,
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(fields: presentation.contextFacts),
        for (final entry in presentation.sections.entries)
          if (entry.value.placement ==
                  LibraryMetadataSectionPlacement.context &&
              entry.value.values.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildMetadataSectionWidget(
              context: context,
              sectionKey: entry.key,
              section: entry.value,
              labels: presentation.labels,
              onValueTap: onFilterByValue,
            ),
          ],
      ],
    );
  }

  Widget buildDetailCreditsSection({
    required BuildContext context,
    required String singularLabel,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final presentation = buildMetadataPresentation(
      singularLabel: singularLabel,
      item: item,
      includeIdentityFacts: false,
      tapFor: _tapResolver(onFilterByValue),
    );
    final creditSections = presentation.sections.entries
        .where(
          (entry) =>
              entry.value.placement ==
                  LibraryMetadataSectionPlacement.credits &&
              entry.value.values.isNotEmpty,
        )
        .toList(growable: false);
    if (creditSections.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryDetailSection(
      title: presentation.labels.creditsSectionTitle,
      accentColor: accent,
      children: [
        for (var index = 0; index < creditSections.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _buildMetadataSectionWidget(
            context: context,
            sectionKey: creditSections[index].key,
            section: creditSections[index].value,
            labels: presentation.labels,
            onValueTap: onFilterByValue,
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

Widget _buildMetadataSectionWidget({
  required BuildContext context,
  required String sectionKey,
  required LibraryMetadataSection section,
  required LibraryMetadataLabels labels,
  ValueChanged<String>? onValueTap,
}) {
  final label = labels.labelFor(
    section.inlineLabelKey ?? sectionKey,
  );
  if (section.renderer == LibraryMetadataSectionRenderer.credits) {
    return LibraryMetadataCreditsList(
      title: label,
      credits: libraryMetadataCreditValues(section),
      onValueTap: onValueTap,
    );
  }
  return LibraryDetailChipGroupWidget(
    label: label,
    values: libraryMetadataTextValues(section),
    onValueTap: onValueTap,
  );
}
