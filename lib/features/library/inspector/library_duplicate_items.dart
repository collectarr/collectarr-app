import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';

class LibraryDuplicateGroup {
  const LibraryDuplicateGroup({
    required this.key,
    required this.label,
    required this.reason,
    required this.confidenceScore,
    required this.entries,
    this.entryLabels = const {},
  });

  final String key;
  final String label;
  final String reason;
  final int confidenceScore;
  final List<LibraryWorkspaceSource> entries;
  final Map<LibraryWorkspaceSource, String> entryLabels;

  int get count => entries.length;
}

List<LibraryDuplicateGroup> findDuplicateShelfGroups(
  List<LibraryWorkspaceSource> entries,
) {
  final candidatesByKey = <String, List<_CandidateEntry>>{};
  for (final entry in entries) {
    final module = defaultLibraryKindRegistry.tryGet(entry.mediaKind);
    if (module == null) continue;
    for (final candidate
        in module.presentation.builder.buildDuplicateCandidates(entry)) {
      candidatesByKey
          .putIfAbsent(candidate.key, () => [])
          .add(_CandidateEntry(candidate, entry));
    }
  }

  final buckets = <String, _DuplicateBucket>{};
  final occupiedByStrongerMatch = <LibraryWorkspaceSource>{};
  final orderedCandidates = candidatesByKey.values.toList()
    ..sort((left, right) =>
        _candidateScore(right).compareTo(_candidateScore(left)));
  for (final candidateEntries in orderedCandidates) {
    final distinctEntries = candidateEntries.map((item) => item.entry).toSet();
    if (distinctEntries.length < 2) continue;
    final score = _candidateScore(candidateEntries);
    if (score < 70 && distinctEntries.every(occupiedByStrongerMatch.contains)) {
      continue;
    }
    for (final candidateEntry in candidateEntries) {
      _addToBucket(
        buckets,
        candidate: candidateEntry.candidate,
        entry: candidateEntry.entry,
      );
    }
    if (score >= 70) {
      occupiedByStrongerMatch.addAll(distinctEntries);
    }
  }

  final groups = _duplicateGroups(buckets);
  groups.sort((a, b) {
    final scoreOrder = b.confidenceScore.compareTo(a.confidenceScore);
    if (scoreOrder != 0) {
      return scoreOrder;
    }
    final reasonOrder = _duplicateReasonOrder(a.reason).compareTo(
      _duplicateReasonOrder(b.reason),
    );
    if (reasonOrder != 0) {
      return reasonOrder;
    }
    return a.label.toLowerCase().compareTo(b.label.toLowerCase());
  });
  return groups;
}

Future<void> showDuplicateItemsDialog(
  BuildContext context, {
  required List<LibraryDuplicateGroup> duplicateGroups,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _DuplicateItemsDialog(
      duplicateGroups: duplicateGroups,
    ),
  );
}

class _DuplicateItemsDialog extends StatelessWidget {
  const _DuplicateItemsDialog({
    required this.duplicateGroups,
  });

  final List<LibraryDuplicateGroup> duplicateGroups;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Local duplicate candidates'),
      content: SizedBox(
        width: 620,
        child: duplicateGroups.isEmpty
            ? const Text('No local duplicate candidates detected.')
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 520),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: duplicateGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _DuplicateGroupTile(group: duplicateGroups[index]);
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DuplicateGroupTile extends StatelessWidget {
  const _DuplicateGroupTile({required this.group});

  final LibraryDuplicateGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = appPalette(context);
    final surfaceColor = Color.alphaBlend(
      colorScheme.surfaceContainerHigh.withValues(alpha: 0.84),
      colorScheme.surface,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.42)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const SizedBox(width: 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        Icons.content_copy,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _DuplicateInfoChip(
                                label: '${group.confidenceScore}% match',
                                background: colorScheme.secondaryContainer,
                                foreground: colorScheme.onSecondaryContainer,
                              ),
                              _DuplicateInfoChip(
                                label: '${group.count} items',
                                background: palette.surfaceSubtle
                                    .withValues(alpha: 0.9),
                                foreground: palette.textPrimary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  group.reason,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 10),
                for (final entry in group.entries)
                  _DuplicateEntryRow(
                    entry: entry,
                    label: group.entryLabels[entry] ?? entry.title,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DuplicateInfoChip extends StatelessWidget {
  const _DuplicateInfoChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DuplicateEntryRow extends StatelessWidget {
  const _DuplicateEntryRow({required this.entry, required this.label});

  final LibraryWorkspaceSource entry;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.divider.withValues(alpha: 0.75)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color:
                    (entry.isOwned ? colorScheme.primary : colorScheme.tertiary)
                        .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                entry.isOwned ? Icons.inventory_2 : Icons.star_border,
                size: 15,
                color:
                    entry.isOwned ? colorScheme.primary : colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _entrySubtitle(entry),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuplicateBucket {
  _DuplicateBucket({
    required this.label,
    required this.reason,
    required this.confidenceScore,
  });

  final String label;
  final String reason;
  int confidenceScore;
  final List<LibraryWorkspaceSource> entries = [];
  final Map<LibraryWorkspaceSource, String> entryLabels = {};
}

final class _CandidateEntry {
  const _CandidateEntry(this.candidate, this.entry);

  final LibraryDuplicateCandidate candidate;
  final LibraryWorkspaceSource entry;
}

int _candidateScore(List<_CandidateEntry> candidates) {
  return candidates.fold<int>(
      0,
      (score, candidate) => candidate.candidate.confidenceScore > score
          ? candidate.candidate.confidenceScore
          : score);
}

void _addToBucket(
  Map<String, _DuplicateBucket> buckets, {
  required LibraryDuplicateCandidate candidate,
  required LibraryWorkspaceSource entry,
}) {
  final bucket = buckets.putIfAbsent(
    candidate.key,
    () => _DuplicateBucket(
      label: candidate.label,
      reason: candidate.reason,
      confidenceScore: candidate.confidenceScore,
    ),
  );
  if (candidate.confidenceScore > bucket.confidenceScore) {
    bucket.confidenceScore = candidate.confidenceScore;
  }
  bucket.entries.add(entry);
  if (candidate.entryLabel case final label?) {
    bucket.entryLabels[entry] = label;
  }
}

List<LibraryDuplicateGroup> _duplicateGroups(
  Map<String, _DuplicateBucket> buckets,
) {
  return [
    for (final bucket in buckets.entries)
      if (bucket.value.entries.length > 1)
        LibraryDuplicateGroup(
          key: bucket.key,
          label: bucket.value.label,
          reason: bucket.value.reason,
          confidenceScore: _duplicateConfidenceScore(bucket.value),
          entries: _sortedEntries(bucket.value.entries),
          entryLabels: Map.unmodifiable(bucket.value.entryLabels),
        ),
  ];
}

int _duplicateConfidenceScore(_DuplicateBucket bucket) {
  var score = bucket.confidenceScore;
  final ownedCount = bucket.entries.where((entry) => entry.isOwned).length;
  if (ownedCount > 0 && ownedCount < bucket.entries.length) {
    score += 2;
  }

  score += bucket.entries.length > 2 ? 2 : 0;
  return score.clamp(0, 99);
}

List<LibraryWorkspaceSource> _sortedEntries(
    List<LibraryWorkspaceSource> entries) {
  return entries.toList(growable: false)
    ..sort((a, b) {
      final title = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (title != 0) {
        return title;
      }
      return a.itemId.compareTo(b.itemId);
    });
}

String _entrySubtitle(LibraryWorkspaceSource entry) {
  final pieces = <String>[
    if (entry.isOwned) 'Owned',
    if (entry.isWishlisted) 'Wishlist',
    'ID ${entry.itemId}',
  ];
  return pieces.join(' - ');
}

int _duplicateReasonOrder(String reason) {
  return switch (reason) {
    'Same barcode' => 0,
    'Same issue metadata' => 1,
    _ => 2,
  };
}
