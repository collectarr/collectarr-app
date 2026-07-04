import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
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
  });

  final String key;
  final String label;
  final String reason;
  final int confidenceScore;
  final List<ShelfEntry> entries;

  int get count => entries.length;
}

List<LibraryDuplicateGroup> findDuplicateShelfGroups(
  List<ShelfEntry> entries,
) {
  final barcodeBuckets = <String, _DuplicateBucket>{};
  for (final entry in entries) {
    final item = entry.catalogItem;
    final barcode = _normalizedBarcode(item?.barcode);
    if (barcode == null) {
      continue;
    }
    _addToBucket(
      barcodeBuckets,
      key: 'barcode:$barcode',
      label: 'Barcode ${item!.barcode!.trim()}',
      reason: 'Same barcode',
      entry: entry,
    );
  }

  final groups = _duplicateGroups(barcodeBuckets);
  final barcodeDuplicateItemIds = {
    for (final group in groups)
      for (final entry in group.entries) entry.itemId,
  };

  final issueBuckets = <String, _DuplicateBucket>{};
  for (final entry in entries) {
    if (barcodeDuplicateItemIds.contains(entry.itemId)) {
      continue;
    }
    final item = entry.catalogItem;
    if (item == null) {
      continue;
    }
    final title = _normalizedText(item.title);
    final issue = _normalizedText(item.itemNumber);
    if (title == null || issue == null) {
      continue;
    }
    final publisher = _normalizedText(item.publisher) ?? '';
    final year =
        item.releaseYear?.toString() ?? item.releaseDate?.year.toString() ?? '';
    final variant = _normalizedText(item.variant) ?? '';
    _addToBucket(
      issueBuckets,
      key: 'issue:$title|$issue|$publisher|$year|$variant',
      label: _issueDuplicateLabel(entry),
      reason: 'Same issue metadata',
      entry: entry,
    );
  }

  groups.addAll(_duplicateGroups(issueBuckets));
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
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.42)),
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
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                                background: palette.surfaceSubtle.withValues(alpha: 0.9),
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
                for (final entry in group.entries) _DuplicateEntryRow(entry: entry),
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
  const _DuplicateEntryRow({required this.entry});

  final ShelfEntry entry;

  @override
  Widget build(BuildContext context) {
    final item = entry.catalogItem;
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
                color: (entry.isOwned ? colorScheme.primary : colorScheme.tertiary)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                entry.isOwned ? Icons.inventory_2 : Icons.star_border,
                size: 15,
                color: entry.isOwned ? colorScheme.primary : colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item == null
                        ? entry.title
                        : _itemTitle(item.title, item.itemNumber),
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
  });

  final String label;
  final String reason;
  final List<ShelfEntry> entries = [];
}

void _addToBucket(
  Map<String, _DuplicateBucket> buckets, {
  required String key,
  required String label,
  required String reason,
  required ShelfEntry entry,
}) {
  final bucket = buckets.putIfAbsent(
    key,
    () => _DuplicateBucket(label: label, reason: reason),
  );
  bucket.entries.add(entry);
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
        ),
  ];
}

int _duplicateConfidenceScore(_DuplicateBucket bucket) {
  final catalogItems = [
    for (final entry in bucket.entries)
      if (entry.catalogItem != null) entry.catalogItem!,
  ];
  if (catalogItems.length < 2) {
    return 0;
  }

  var score = switch (bucket.reason) {
    'Same barcode' => 78,
    'Same issue metadata' => 52,
    _ => 40,
  };

  if (_allShareValue(catalogItems.map((item) => _normalizedText(item.title)))) {
    score += 8;
  }
  if (_allShareValue(
    catalogItems.map((item) => _normalizedText(item.itemNumber)),
  )) {
    score += 5;
  }
  if (_allShareValue(
    catalogItems.map((item) => _normalizedText(item.publisher)),
  )) {
    score += 4;
  }
  if (_allShareValue(catalogItems.map(_releaseYearToken))) {
    score += 3;
  }
  if (_allShareValue(
    catalogItems.map((item) => _normalizedText(item.variant)),
  )) {
    score += 2;
  }

  final ownedCount = bucket.entries.where((entry) => entry.isOwned).length;
  if (ownedCount > 0 && ownedCount < bucket.entries.length) {
    score += 2;
  }

  score += bucket.entries.length > 2 ? 2 : 0;
  return score.clamp(0, 99);
}

bool _allShareValue(Iterable<String?> values) {
  final normalized = values.whereType<String>().toSet();
  return normalized.length == 1 && normalized.isNotEmpty;
}

String? _releaseYearToken(LibraryMetadataItem item) {
  return item.releaseYear?.toString() ?? item.releaseDate?.year.toString();
}

List<ShelfEntry> _sortedEntries(List<ShelfEntry> entries) {
  return entries.toList(growable: false)
    ..sort((a, b) {
      final title = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (title != 0) {
        return title;
      }
      return a.itemId.compareTo(b.itemId);
    });
}

String _issueDuplicateLabel(ShelfEntry entry) {
  final item = entry.catalogItem;
  if (item == null) {
    return entry.title;
  }
  final pieces = [
    _itemTitle(item.title, item.itemNumber),
    if (_hasText(item.publisher)) item.publisher!.trim(),
    if (item.releaseYear != null)
      item.releaseYear.toString()
    else if (item.releaseDate != null)
      item.releaseDate!.year.toString(),
    if (_hasText(item.variant)) item.variant!.trim(),
  ];
  return pieces.join(' - ');
}

String _entrySubtitle(ShelfEntry entry) {
  final item = entry.catalogItem;
  final pieces = <String>[
    if (entry.isOwned) 'Owned',
    if (entry.isWishlisted) 'Wishlist',
    if (_hasText(item?.publisher)) item!.publisher!.trim(),
    if (item?.releaseYear != null)
      item!.releaseYear.toString()
    else if (item?.releaseDate != null)
      item!.releaseDate!.year.toString(),
    if (_hasText(item?.barcode)) 'Barcode ${item!.barcode!.trim()}',
    'ID ${entry.itemId}',
  ];
  return pieces.join(' - ');
}

String _itemTitle(String title, String? itemNumber) {
  final issue = itemNumber?.trim();
  if (issue == null || issue.isEmpty) {
    return title;
  }
  return '$title #$issue';
}

String? _normalizedBarcode(String? value) {
  final normalized = value?.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
  return normalized == null || normalized.isEmpty
      ? null
      : normalized.toLowerCase();
}

String? _normalizedText(String? value) {
  final normalized = value?.trim().replaceAll(RegExp(r'\s+'), ' ');
  return normalized == null || normalized.isEmpty
      ? null
      : normalized.toLowerCase();
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

int _duplicateReasonOrder(String reason) {
  return switch (reason) {
    'Same barcode' => 0,
    'Same issue metadata' => 1,
    _ => 2,
  };
}
