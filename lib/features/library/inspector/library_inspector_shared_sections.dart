import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryInspectorTitleStatusCard extends StatelessWidget {
  const LibraryInspectorTitleStatusCard({
    super.key,
    required this.title,
    required this.accent,
    required this.statusIcon,
    required this.statusLabel,
    this.eyebrow,
  });

  final String title;
  final String? eyebrow;
  final Color accent;
  final IconData statusIcon;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null && eyebrow!.isNotEmpty)
              Text(
                eyebrow!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            if (eyebrow != null && eyebrow!.isNotEmpty)
              const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.panel,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: palette.divider),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: accent),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> buildLibraryInspectorEditorSections({
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  required Color accent,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
}) {
  return [
    if (ownedItem != null)
      InspectorPersonalDetailsEditor(
        ownedItem: ownedItem,
        accent: accent,
      ),
    if (trackingEntry != null)
      InspectorTrackingDetailsEditor(
        itemId: entry.id,
        mediaType: entry.mediaType,
        trackingEntry: trackingEntry,
        profile: type.trackingProfile,
        editions: entry.editions,
        accent: accent,
      ),
  ];
}

List<Widget> buildLibraryInspectorKindSections({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryWorkspaceEntry entry,
  required Color accent,
  ValueChanged<String>? onFilterByValue,
}) {
  return type.presentation.builder.buildInspectorSections(
    context: context,
    entry: entry,
    accent: accent,
    onFilterByValue: onFilterByValue,
  );
}