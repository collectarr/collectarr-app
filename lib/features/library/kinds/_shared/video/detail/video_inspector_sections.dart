import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';

class InspectorVideoTitleMetadataSection extends StatelessWidget {
  const InspectorVideoTitleMetadataSection({
    super.key,
    required this.type,
    required this.item,
    required this.ownedReleaseCount,
    this.onFilterByValue,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
  final int ownedReleaseCount;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final metadataPresentation = _metadataPresentationForEntry(type, item);
    final creatorCredits = [
      for (final section in metadataPresentation.sections.values)
        if (section.renderer == LibraryMetadataSectionRenderer.credits)
          ...libraryMetadataCreditValues(section),
    ];
    final creatorNames = <String>[
      for (final credit in creatorCredits)
        if (credit['name']?.toString().trim().isNotEmpty == true)
          credit['name'].toString().trim(),
    ];
    final creatorsByRole = <String, List<String>>{};
    for (final credit in creatorCredits) {
      final name = credit['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final role = credit['role']?.toString().trim();
      final key = (role != null && role.isNotEmpty) ? role : 'Creator';
      creatorsByRole.putIfAbsent(key, () => <String>[]).add(name);
    }
    final hasRoles = creatorsByRole.keys.any((r) => r != 'Creator') ||
        creatorsByRole.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(label: 'Display title', value: dto.title),
            if (adapter?.publisher?.trim().isNotEmpty == true)
              LibraryDetailField(label: 'Studio', value: adapter!.publisher!),
            if (_metadataFactValue(metadataPresentation, 'Runtime')
                case final runtime?)
              LibraryDetailField(label: 'Runtime', value: runtime),
            if (_metadataFactValue(metadataPresentation, 'Released')
                case final released?)
              LibraryDetailField(label: 'Released', value: released),
            if (ownedReleaseCount > 0)
              LibraryDetailField(
                label: 'Editions',
                value: '$ownedReleaseCount in collection',
              ),
          ],
        ),
        if (creatorNames.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Cast & Crew',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          if (hasRoles)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in creatorsByRole.entries) ...[
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  LibraryDetailChipGroupWidget(
                    values: entry.value,
                    onValueTap: onFilterByValue,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            )
          else
            LibraryDetailChipGroupWidget(
              values: creatorNames,
              onValueTap: onFilterByValue,
            ),
        ],
        _buildEditionFormatBadges(item),
      ],
    );
  }
}

LibraryMetadataPresentation _metadataPresentationForEntry(
  LibraryKindRuntime type,
  LibraryProjectionRuntime item,
) {
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.identity.singularLabel,
    mediaFields: type.edit.mediaFields,
    releaseFields: type.edit.releaseFields,
    item: item,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
}

String? _metadataFactValue(
  LibraryMetadataPresentation presentation,
  String label,
) {
  for (final fact in presentation.allFacts) {
    if (fact.label == label) {
      final value = fact.value.trim();
      if (value.isNotEmpty && value != '-') {
        return value;
      }
    }
  }
  return null;
}

Widget _buildEditionFormatBadges(LibraryProjectionRuntime item) {
  final catalogItem = item.source.catalogItem;
  final editionsPayload =
      catalogItem?.kindMetadata.toSyncPayload()['editions'] as List?;
  final editions = editionsPayload != null
      ? editionsPayload
          .whereType<Map<Object?, Object?>>()
          .map((e) => CatalogEdition.fromJson(Map<String, dynamic>.from(e)))
          .toList()
      : const <CatalogEdition>[];
  if (editions.isEmpty) {
    return const SizedBox.shrink();
  }
  final seen = <String>{};
  final badges = <Widget>[];
  for (final edition in editions) {
    final id = edition.physicalFormat;
    if (id == null || !seen.add(id)) continue;
    badges.add(
      FormatBadge.fromFormat(
        id: id,
        label: edition.physicalFormatLabel ?? id,
      ),
    );
  }
  if (badges.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Wrap(spacing: 4, runSpacing: 4, children: badges),
  );
}

List<LibraryDetailSectionSpec> buildVideoInspectorSections(
  LibraryInspectorRequest request,
) {
  return [
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.identity,
      title: 'Title metadata',
      children: [
        InspectorVideoTitleMetadataSection(
          type: request.type,
          item: request.item,
          ownedReleaseCount: 1,
          onFilterByValue: request.onFilterByValue,
        ),
      ],
    ),
  ];
}
