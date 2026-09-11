import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_bundle.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class LibraryVideoTitleMetadataSection extends StatelessWidget {
  const LibraryVideoTitleMetadataSection({
    super.key,
    required this.type,
    required this.item,
    required this.ownedReleaseCount,
    this.onFilterByValue,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final int ownedReleaseCount;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    final metadataPresentation = _metadataPresentationForEntry(type, item);
    final creatorCredits = <LibraryMetadataCredit>[
      for (final section in metadataPresentation.sections.values)
        if (section.renderer == LibraryMetadataSectionRenderer.credits)
          ...libraryMetadataCredits(section),
    ];
    final creatorNames = <String>[
      for (final credit in creatorCredits)
        if (credit.name.trim().isNotEmpty) credit.name.trim(),
    ];
    final creatorsByRole = <String, List<String>>{};
    for (final credit in creatorCredits) {
      final name = credit.name.trim();
      if (name.isEmpty) continue;
      final role = credit.role?.trim();
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
            if (_metadataFactValue(metadataPresentation, 'Studio') ??
                    _metadataFactValue(metadataPresentation, 'Publisher')
                case final studio?)
              LibraryDetailField(label: 'Studio', value: studio),
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
      ],
    );
  }
}

LibraryMetadataPresentation _metadataPresentationForEntry(
  LibraryKindRegistration type,
  LibraryProjectionView item,
) {
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.identity.singularLabel,
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
