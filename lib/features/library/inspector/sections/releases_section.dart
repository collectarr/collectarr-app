import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_release_summary.dart';
import 'package:flutter/material.dart';

class InspectorReleasesSection extends StatelessWidget {
  const InspectorReleasesSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final releases = libraryPresentationForKind(request.type.kind)
        .builder
        .buildWorkspaceReleases(
          request.item.source,
        );
    final discCount = releases.fold<int>(
      0,
      (int total, LibraryWorkspaceReleaseSummary release) =>
          total + release.mediaCount,
    );
    final runtimeMinutes = releases
        .map((release) => release.runtimeMinutes)
        .whereType<int>()
        .firstOrNull;
    if (discCount == 0 && releases.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryDetailSection(
      title: 'Releases / discs',
      accentColor: request.accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(
                label: 'Releases', value: releases.length.toString()),
            LibraryDetailField(label: 'Discs', value: discCount.toString()),
            if (runtimeMinutes != null)
              LibraryDetailField(
                  label: 'Runtime', value: '$runtimeMinutes min'),
          ],
        ),
        if (releases.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final release in releases)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.65),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        release.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (release.formatLabel?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          release.formatLabel!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (release.mediaLabels.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final mediaLabel in release.mediaLabels)
                              Chip(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                label: Text(
                                  mediaLabel,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
