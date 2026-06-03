import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cached facet grouping buckets used by both comics and generic library pages.
class FacetBuckets {
  const FacetBuckets({
    required this.shelfSignature,
    required this.buckets,
    required this.itemIdsByBucket,
  });

  final String shelfSignature;
  final List<LibrarySeriesBucket> buckets;
  final Map<String, Set<String>> itemIdsByBucket;
}

/// Shared utilities for library pages (comics and generic).
mixin LibraryPageUtilities<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Map<String, List<String>> customFieldValuesByItem = const {};
  Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
      const {};
  List<CustomFieldDefinition> customFieldDefinitions = const [];

  Future<void> loadCustomFieldValues({
    String? mediaKind,
    bool Function()? canApply,
  }) async {
    final db = ref.read(localDatabaseProvider);
    final repo = CustomFieldRepository(db);
    final allValues = await repo.listAllValues();
    final definitions = await repo.listDefinitions(mediaKind: mediaKind);
    final flat = <String, List<String>>{};
    final structured = <String, Map<String, String>>{};
    for (final entry in allValues.entries) {
      final valuesByDefinition = <String, String>{};
      flat[entry.key] = [
        for (final v in entry.value)
          if (v.value != null && v.value!.trim().isNotEmpty) v.value!,
      ];
      for (final value in entry.value) {
        final normalized = value.value?.trim();
        if (normalized == null || normalized.isEmpty) {
          continue;
        }
        valuesByDefinition[value.fieldDefinitionId] = normalized;
      }
      if (valuesByDefinition.isNotEmpty) {
        structured[entry.key] = valuesByDefinition;
      }
    }
    if (mounted && (canApply?.call() ?? true)) {
      setState(() {
        customFieldValuesByItem = flat;
        customFieldValuesByDefinitionByItem = structured;
        customFieldDefinitions = definitions;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Row parsing helpers
  // ---------------------------------------------------------------------------

  static String? rowText(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static List<String> rowTextList(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is! Iterable) return const [];
    return [
      for (final item in value)
        if (item != null && item.toString().trim().isNotEmpty)
          item.toString().trim(),
    ];
  }

  // ---------------------------------------------------------------------------
  // Shelf signature
  // ---------------------------------------------------------------------------

  /// Compact change-detection signature for a set of item IDs.
  static String shelfSignature(Iterable<String> ids) {
    final sorted = ids.toList()..sort();
    return '${sorted.length}:${Object.hashAll(sorted)}';
  }

  // ---------------------------------------------------------------------------
  // Facet loading
  // ---------------------------------------------------------------------------

  /// Parse API facet rows into a bucket map keyed by facet name.
  static Map<String, Set<String>> parseFacetRows(
    List<Map<String, dynamic>> rows,
    Set<String> validItemIds,
  ) {
    final byBucket = <String, Set<String>>{};
    for (final row in rows) {
      final name = rowText(row, 'name');
      if (name == null) continue;
      for (final itemId in rowTextList(row, 'item_ids')) {
        if (validItemIds.contains(itemId)) {
          byBucket.putIfAbsent(name, () => <String>{}).add(itemId);
        }
      }
    }
    return byBucket;
  }

  /// Build sorted [FacetBuckets] from a bucket map.
  /// When [allBucketLabel] is non-null an "All …" entry is prepended.
  static FacetBuckets buildFacetBuckets({
    required String signature,
    required Map<String, Set<String>> byBucket,
    String? allBucketLabel,
    int? totalItemCount,
  }) {
    final sorted = [
      for (final entry in byBucket.entries)
        LibrarySeriesBucket(title: entry.key, count: entry.value.length),
    ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final buckets = <LibrarySeriesBucket>[
      if (allBucketLabel != null)
        LibrarySeriesBucket(
          title: allBucketLabel,
          count: totalItemCount ?? 0,
        ),
      ...sorted,
    ];

    return FacetBuckets(
      shelfSignature: signature,
      buckets: buckets,
      itemIdsByBucket: byBucket,
    );
  }

  /// Fetch facet rows from the API and build [FacetBuckets].
  Future<FacetBuckets> fetchFacetBuckets({
    required Set<String> itemIds,
    required String signature,
    required bool isStoryArc,
    String? allBucketLabel,
  }) async {
    final api = ref.read(apiClientProvider);
    final rows = isStoryArc
        ? await api.storyArcFacets(itemIds)
        : await api.characterFacets(itemIds);
    final byBucket = parseFacetRows(rows, itemIds);
    return buildFacetBuckets(
      signature: signature,
      byBucket: byBucket,
      allBucketLabel: allBucketLabel,
      totalItemCount: itemIds.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Bulk actions
  // ---------------------------------------------------------------------------

  LibraryBulkActions bulkActions() =>
      LibraryBulkActions(ref.read(collectionMutationsProvider));

  /// Show a confirmation dialog for bulk removal and return the user's choice.
  Future<bool> confirmBulkRemove(
    BuildContext context, {
    required int count,
    String itemLabel = 'items',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: Text('Remove selected $itemLabel?'),
        content: Text(
          'This removes $count selected item${count == 1 ? '' : 's'} '
          'from the local shelf and queues the change for sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<bool> confirmSingleRemove(
    BuildContext context, {
    required String title,
    required String itemLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: Text('Remove $itemLabel?'),
        content: Text(
          'Remove "$title" from the local shelf and queue the change for sync?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  /// Show the bulk edit dialog and return the selection (null = cancelled).
  Future<LibraryBulkEditSelection?> showBulkEditDialog(
    BuildContext context, {
    required LibraryTypeConfig type,
    required int selectedCount,
  }) {
    return showDialog<LibraryBulkEditSelection>(
      context: context,
      builder: (context) => LibraryBulkEditDialog(
        type: type,
        selectedCount: selectedCount,
      ),
    );
  }
}
