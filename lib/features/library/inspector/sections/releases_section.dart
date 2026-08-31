import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:flutter/material.dart';

class InspectorReleasesSection extends StatelessWidget {
  const InspectorReleasesSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final payload =
        request.item.source.catalogItem?.toSyncPayload() ?? const {};
    final video = (payload['video'] as Map?) ?? payload;
    final nrDiscs =
        video['nr_discs'] is num ? (video['nr_discs'] as num).toInt() : null;
    final runtimeMinutes = video['runtime_minutes'] is num
        ? (video['runtime_minutes'] as num).toInt()
        : null;
    final editions =
        request.item.source.catalogItem?.editions ?? const [];
    final discCount = nrDiscs ??
        editions.fold<int>(
          0,
          (total, edition) => total + edition.discs.length,
        );
    if (discCount == 0 && editions.isEmpty) {
      return const SizedBox.shrink();
    }
    return LibraryDetailSection(
      title: 'Releases / discs',
      accentColor: request.accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(
                label: 'Releases', value: editions.length.toString()),
            LibraryDetailField(label: 'Discs', value: discCount.toString()),
            if (runtimeMinutes != null)
              LibraryDetailField(
                  label: 'Runtime', value: '$runtimeMinutes min'),
          ],
        ),
        if (editions.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final edition in editions)
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
                        edition.title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (edition.format?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          edition.format!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (edition.discs.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final disc in edition.discs)
                              Chip(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                label: Text(
                                  disc.discName ?? 'Disc ${disc.discNumber}',
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
