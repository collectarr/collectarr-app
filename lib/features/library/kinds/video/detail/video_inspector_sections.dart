import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class InspectorVideoTitleMetadataSection extends StatelessWidget {
  const InspectorVideoTitleMetadataSection({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedReleaseCount,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final int ownedReleaseCount;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final metadataPresentation = _metadataPresentationForEntry(type, entry);
    final aliasValues = <String>{
      if (entry.originalTitle?.trim().isNotEmpty == true)
        entry.originalTitle!.trim(),
      if (entry.localizedTitle?.trim().isNotEmpty == true &&
          entry.localizedTitle!.trim() != entry.resolvedTitle.trim())
        entry.localizedTitle!.trim(),
      ...?entry.searchAliases,
    }.toList(growable: false);
    final creatorNames = <String>[
      for (final credit in metadataPresentation.creators)
        if (credit['name']?.toString().trim().isNotEmpty == true)
          credit['name'].toString().trim(),
    ];
    final creatorsByRole = <String, List<String>>{};
    for (final credit in metadataPresentation.creators) {
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
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Display title', entry.resolvedTitle),
            if (entry.originalTitle?.trim().isNotEmpty == true)
              LibraryInspectorFactData('Original title', entry.originalTitle!),
            if (entry.publisher?.trim().isNotEmpty == true)
              LibraryInspectorFactData('Studio', entry.publisher!),
            if (_metadataFactValue(metadataPresentation, 'Runtime')
                case final runtime?)
              LibraryInspectorFactData(
                'Runtime',
                runtime,
              ),
            LibraryInspectorFactData(
              'Releases',
              entry.editions.length.toString(),
            ),
            LibraryInspectorFactData(
              'Owned releases',
              ownedReleaseCount.toString(),
            ),
          ],
        ),
        _buildEditionFormatBadges(entry),
        if (metadataPresentation.genres case final genres when genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Genres',
            values: genres,
            onValueTap: onFilterByValue,
          ),
        ],
        if (creatorNames.isNotEmpty && hasRoles) ...[
          for (final entry in creatorsByRole.entries) ...[
            const SizedBox(height: 8),
            LibraryInspectorChipWrap(
              label: entry.key,
              values: entry.value,
              onValueTap: onFilterByValue,
            ),
          ],
        ] else if (creatorNames.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Cast / credits',
            values: creatorNames,
            onValueTap: onFilterByValue,
          ),
        ],
        if (aliasValues.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
            label: 'Search aliases',
            values: aliasValues,
            onValueTap: onFilterByValue,
          ),
        ],
      ],
    );
  }
}

LibraryMetadataPresentation _metadataPresentationForEntry(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
) {
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
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

Widget _buildEditionFormatBadges(LibraryWorkspaceEntry entry) {
  final seen = <String>{};
  final badges = <Widget>[];
  for (final edition in entry.editions) {
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
  final ownedReleaseIds = <String>{};
  for (final edition in request.entry.editions) {
    if (edition.id == request.entry.referenceEditionId) {
      ownedReleaseIds.add(edition.id);
      continue;
    }
    for (final variant in edition.variants) {
      if (variant.id == request.entry.referenceVariantId) {
        ownedReleaseIds.add(edition.id);
        break;
      }
    }
  }
  return [
    LibraryDetailSectionSpec(
      slot: LibraryDetailSectionSlot.identity,
      title: 'Title metadata',
      children: [
        InspectorVideoTitleMetadataSection(
          type: request.type,
          entry: request.entry,
          ownedReleaseCount: ownedReleaseIds.length,
          onFilterByValue: request.onFilterByValue,
        ),
      ],
    ),
  ];
}
