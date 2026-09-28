import 'dart:convert';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/barcode/scanned_code.dart';
import 'package:collectarr_app/features/library/data/catalog_item_v1_workspace_repository.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:collectarr_app/features/library/domain/catalog_item_v1_schema.dart';
import 'package:collectarr_app/features/library/state/catalog_item_v1_providers.dart';
import 'package:collectarr_app/features/library/v1/owned_copy_v1_form.dart';
import 'package:collectarr_app/features/library/config/library_kind_identity.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active Catalog Item + Owned Copy workspace shared by all library kinds.
final class CatalogItemV1WorkspacePage extends ConsumerWidget {
  const CatalogItemV1WorkspacePage({
    required this.kind,
    required this.identity,
    required this.topBar,
    required this.accent,
    super.key,
  });

  final CatalogMediaKind kind;
  final LibraryKindIdentity identity;
  final Widget topBar;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(catalogItemV1WorkspaceByKindProvider(kind));
    final canEditCatalog = ref.watch(authControllerProvider).canEditCatalog;
    return Column(
      children: [
        topBar,
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        identity.pluralLabel,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh Catalog Items',
                      onPressed: () {
                        ref
                            .read(catalogItemV1WorkspaceRepositoryProvider)
                            .clearCatalogCache();
                        ref.invalidate(
                          catalogItemV1WorkspaceByKindProvider(kind),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openAddDialog(
                        context,
                        canEditCatalog: canEditCatalog,
                      ),
                      icon: const Icon(Icons.add),
                      label: Text('Add ${identity.singularLabel}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: workspace.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: _WorkspaceMessage(
                      icon: Icons.error_outline,
                      message: 'Could not load owned copies: $error',
                    ),
                  ),
                  data: (items) => _CatalogItemWorkspaceList(
                    items: items,
                    identity: identity,
                    accent: accent,
                    canEditCatalog: canEditCatalog,
                    onEditCatalog: (item) => _editCatalogItem(
                      context,
                      ref,
                      item.catalogItem!,
                    ),
                    onEditCopy: (copy) => _editOwnedCopy(context, ref, copy),
                    onAddCopy: (item) => _addOwnedCopies(context, ref, item),
                    onDeleteCopy: (copy) =>
                        _deleteOwnedCopy(context, ref, copy),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openAddDialog(
    BuildContext context, {
    required bool canEditCatalog,
  }) async {
    await showCatalogItemV1AddDialog(
      context: context,
      kind: kind,
      singularLabel: identity.singularLabel,
      accent: accent,
      canEditCatalog: canEditCatalog,
    );
  }

  Future<void> _editCatalogItem(
    BuildContext context,
    WidgetRef ref,
    CatalogItemV1Dto item,
  ) async {
    final result = await showDialog<CatalogItemWriteV1Dto>(
      context: context,
      builder: (context) => _CatalogItemCommonEditor(
        title: 'Edit ${identity.singularLabel}',
        accent: accent,
        kind: item.reference.kind,
        initialDetails: item.details.toJson(),
      ),
    );
    if (result == null || !context.mounted) return;
    try {
      final updated = await ref
          .read(libraryCatalogItemV1AddServiceProvider)
          .update(item.reference, result);
      ref.read(catalogItemV1WorkspaceRepositoryProvider).remember(updated);
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, _catalogWriteError(error));
    }
  }

  Future<void> _editOwnedCopy(
    BuildContext context,
    WidgetRef ref,
    OwnedCopyV1 copy,
  ) async {
    final updated = await showDialog<OwnedCopyV1>(
      context: context,
      builder: (context) => _OwnedCopyEditor(
        copy: copy,
        title: identity.singularLabel,
        accent: accent,
      ),
    );
    if (updated == null || !context.mounted) return;
    try {
      await ref.read(ownedCopyV1RepositoryProvider).upsert(updated);
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not save this copy: $error');
    }
  }

  Future<void> _addOwnedCopies(
    BuildContext context,
    WidgetRef ref,
    CatalogItemV1WorkspaceItem item,
  ) async {
    final draft = await showDialog<OwnedCopyV1FormDraft>(
      context: context,
      builder: (context) => _OwnedCopyAddDialog(
        title: item.title,
        kind: item.reference.kind,
        accent: accent,
      ),
    );
    if (draft == null || !context.mounted) return;
    final validationError = draft.validationError;
    if (validationError != null) {
      _showMessage(context, validationError);
      return;
    }
    try {
      await ref.read(libraryCatalogItemV1AddServiceProvider).addCopies(
            item: item.reference,
            quantity: draft.quantity,
            status: draft.status,
            startingIndex: draft.indexNumber,
            locationId: draft.locationId,
            owner: draft.owner,
            isDigital: draft.isDigital,
            condition: draft.condition,
            purchaseDate: draft.purchaseDate,
            purchasePrice: draft.purchasePrice,
            purchaseStore: draft.purchaseStore,
            currentValue: draft.currentValue,
            soldAt: draft.soldAt,
            soldTo: draft.soldTo,
            salePrice: draft.salePrice,
            rating: draft.rating,
            notes: draft.notes,
            tags: draft.tags,
            personalImages: draft.personalImages,
            customFields: draft.customFields,
            kindDetails: draft.kindDetails,
          );
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not add this copy: $error');
    }
  }

  Future<void> _deleteOwnedCopy(
    BuildContext context,
    WidgetRef ref,
    OwnedCopyV1 copy,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove owned copy?'),
        content: Text(
            'Remove this ${identity.singularLabel} copy from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(ownedCopyV1RepositoryProvider)
          .markDeleted(copy.ref, DateTime.now().toUtc());
      ref.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not remove this copy: $error');
    }
  }
}

final class _CatalogItemWorkspaceList extends StatefulWidget {
  const _CatalogItemWorkspaceList({
    required this.items,
    required this.identity,
    required this.accent,
    required this.canEditCatalog,
    required this.onEditCatalog,
    required this.onEditCopy,
    required this.onAddCopy,
    required this.onDeleteCopy,
  });

  final List<CatalogItemV1WorkspaceItem> items;
  final LibraryKindIdentity identity;
  final Color accent;
  final bool canEditCatalog;
  final Future<void> Function(CatalogItemV1WorkspaceItem item) onEditCatalog;
  final Future<void> Function(OwnedCopyV1 copy) onEditCopy;
  final Future<void> Function(CatalogItemV1WorkspaceItem item) onAddCopy;
  final Future<void> Function(OwnedCopyV1 copy) onDeleteCopy;

  @override
  State<_CatalogItemWorkspaceList> createState() =>
      _CatalogItemWorkspaceListState();
}

final class _CatalogItemWorkspaceListState
    extends State<_CatalogItemWorkspaceList> {
  final _searchController = TextEditingController();
  late List<({CatalogItemV1WorkspaceItem item, String searchText})>
      _searchIndex = _buildSearchIndex(widget.items);
  String _query = '';
  String _sortField = 'title';
  String _groupField = '';
  bool _ascending = true;

  @override
  void didUpdateWidget(covariant _CatalogItemWorkspaceList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items)) {
      _searchIndex = _buildSearchIndex(widget.items);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visibleItems = <CatalogItemV1WorkspaceItem>[
      for (final entry in _searchIndex)
        if (query.isEmpty || entry.searchText.contains(query)) entry.item,
    ]..sort(_compareItems);
    final copyCount = visibleItems.fold<int>(
      0,
      (count, item) =>
          count +
          item.copies
              .where((copy) => copy.status != OwnedCopyStatusV1.sold)
              .length,
    );
    final groupFields = _availableGroupFields();
    final sortFields = _availableSortFields();
    final workspaceRows = _groupedWorkspaceRows(visibleItems);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: 'Search ${widget.identity.pluralLabel}',
              hintText: 'Title, catalog details, or copy notes',
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                tooltip: 'Group Catalog Items',
                icon: const Icon(Icons.folder_copy_outlined),
                onSelected: (value) => setState(() => _groupField = value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '', child: Text('No grouping')),
                  for (final field in groupFields)
                    PopupMenuItem(
                      value: field,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: _groupField == field
                                ? const Icon(Icons.check, size: 18)
                                : null,
                          ),
                          Text(_humanize(field)),
                        ],
                      ),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                tooltip: 'Sort Catalog Items',
                icon: const Icon(Icons.sort),
                onSelected: (value) => setState(() => _sortField = value),
                itemBuilder: (context) => [
                  for (final field in sortFields)
                    PopupMenuItem(
                      value: field,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: _sortField == field
                                ? const Icon(Icons.check, size: 18)
                                : null,
                          ),
                          Text(_fieldLabel(field)),
                        ],
                      ),
                    ),
                ],
              ),
              IconButton(
                tooltip: _ascending ? 'Sort descending' : 'Sort ascending',
                onPressed: () => setState(() => _ascending = !_ascending),
                icon: Icon(
                  _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${visibleItems.length} ${widget.identity.pluralLabel.toLowerCase()} · '
              '$copyCount active ${copyCount == 1 ? 'copy' : 'copies'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: visibleItems.isEmpty
              ? _WorkspaceMessage(
                  icon: widget.identity.icon,
                  message: widget.items.isEmpty
                      ? 'No ${widget.identity.pluralLabel.toLowerCase()} in your collection yet.'
                      : 'No Catalog Items match this search.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                  itemCount: workspaceRows.length,
                  itemBuilder: (context, index) {
                    final row = workspaceRows[index];
                    final item = row.item;
                    if (item == null) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                        child: Text(
                          row.groupLabel!,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CatalogItemCard(
                        key: ValueKey(item.reference),
                        item: item,
                        identity: widget.identity,
                        accent: widget.accent,
                        canEditCatalog: widget.canEditCatalog,
                        onEditCatalog: item.catalogItem == null
                            ? null
                            : () => widget.onEditCatalog(item),
                        onEditCopy: widget.onEditCopy,
                        onAddCopy: () => widget.onAddCopy(item),
                        onDeleteCopy: widget.onDeleteCopy,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<({CatalogItemV1WorkspaceItem item, String searchText})>
      _buildSearchIndex(List<CatalogItemV1WorkspaceItem> items) => [
            for (final item in items)
              (
                item: item,
                searchText: _catalogItemSearchText(item),
              ),
          ];

  String _catalogItemSearchText(CatalogItemV1WorkspaceItem item) {
    final parts = <String>[
      item.title,
      item.reference.kind.apiValue,
      if (item.catalogItem != null)
        jsonEncode(item.catalogItem!.details.toJson()),
    ];
    for (final copy in item.copies) {
      parts.addAll([
        copy.status.apiValue,
        copy.indexNumber?.toString() ?? '',
        copy.locationId ?? '',
        copy.owner?.label ?? '',
        copy.condition ?? '',
        copy.purchaseStore ?? '',
        copy.soldTo ?? '',
        copy.notes ?? '',
        ...copy.tags,
        ...copy.kindDetails.toJson().values.map((value) => '$value'),
      ]);
    }
    return parts.join(' ').toLowerCase();
  }

  int _compareItems(
    CatalogItemV1WorkspaceItem left,
    CatalogItemV1WorkspaceItem right,
  ) {
    final leftValue = _sortValue(left, _sortField);
    final rightValue = _sortValue(right, _sortField);
    final result = _compareValues(leftValue, rightValue);
    if (leftValue == null || rightValue == null) {
      return result;
    }
    return _ascending ? result : -result;
  }

  Object? _sortValue(CatalogItemV1WorkspaceItem item, String field) {
    if (field == 'active_copy_count') return _activeCopyCount(item);
    if (field == 'updated_at') return item.catalogItem?.updatedAt;
    if (field == 'title') return item.title;
    final details = item.catalogItem?.details.toJson();
    final value = details?[field];
    if (value is Map && value['year'] is int) {
      final year = value['year'] as int;
      final month = value['month'] is int ? value['month'] as int : 0;
      final day = value['day'] is int ? value['day'] as int : 0;
      return year * 10000 + month * 100 + day;
    }
    if (value is num || value is bool) return value;
    return _summaryText(value);
  }

  int _compareValues(Object? left, Object? right) {
    if (left == null) return right == null ? 0 : 1;
    if (right == null) return -1;
    if (left is num && right is num) return left.compareTo(right);
    if (left is DateTime && right is DateTime) return left.compareTo(right);
    if (left is bool && right is bool) {
      return (left ? 1 : 0).compareTo(right ? 1 : 0);
    }
    return left.toString().toLowerCase().compareTo(
          right.toString().toLowerCase(),
        );
  }

  List<String> _availableSortFields() {
    final firstItem = widget.items.firstOrNull;
    final fields = <String>{
      'title',
      'active_copy_count',
      'updated_at',
    };
    if (firstItem == null) return fields.toList(growable: false);
    final properties =
        _kindDetailsSchema(firstItem.reference.kind)['properties']
            as Map<String, dynamic>;
    for (final entry in properties.entries) {
      if (entry.key == 'release_date' ||
          _isScalarCatalogSchema(entry.value as Map<String, dynamic>)) {
        fields.add(entry.key);
      }
    }
    return fields.toList(growable: false);
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'title':
        return 'Title';
      case 'active_copy_count':
        return 'Active copy count';
      case 'updated_at':
        return 'Recently updated';
    }
    final properties = _kindDetailsSchema(widget.identity.kind)['properties'];
    if (properties is Map<String, dynamic>) {
      final schema = properties[field];
      if (schema is Map<String, dynamic> && schema['title'] is String) {
        return schema['title'] as String;
      }
    }
    return _humanize(field);
  }

  int _activeCopyCount(CatalogItemV1WorkspaceItem item) =>
      item.copies.where((copy) => copy.status != OwnedCopyStatusV1.sold).length;

  List<String> _availableGroupFields() {
    final firstItem = widget.items.firstOrNull;
    if (firstItem == null) return const [];
    final properties =
        _kindDetailsSchema(firstItem.reference.kind)['properties']
            as Map<String, dynamic>;
    return [
      for (final entry in properties.entries)
        if (!{'kind', 'title', 'sort_title', 'subtitle'}.contains(entry.key) &&
            (entry.key == 'release_date' ||
                _isScalarCatalogSchema(
                  entry.value as Map<String, dynamic>,
                )))
          entry.key,
    ];
  }

  List<({CatalogItemV1WorkspaceItem? item, String? groupLabel})>
      _groupedWorkspaceRows(List<CatalogItemV1WorkspaceItem> items) {
    if (_groupField.isEmpty) {
      return [for (final item in items) (item: item, groupLabel: null)];
    }
    final groups = <String, List<CatalogItemV1WorkspaceItem>>{};
    for (final item in items) {
      final rawValue = item.catalogItem?.details.toJson()[_groupField];
      final value = _summaryText(rawValue) ?? 'Not set';
      groups.putIfAbsent(value, () => []).add(item);
    }
    final labels = groups.keys.toList()
      ..sort(
          (left, right) => left.toLowerCase().compareTo(right.toLowerCase()));
    return [
      for (final label in labels) ...[
        (item: null, groupLabel: '${_humanize(_groupField)}: $label'),
        for (final item in groups[label]!) (item: item, groupLabel: null),
      ],
    ];
  }
}

bool _isScalarCatalogSchema(Map<String, dynamic> schema) {
  if (schema[r'$ref'] case final String ref) {
    final definition = catalogItemV1SchemaDefinitions[ref.split('/').last];
    return definition is Map<String, dynamic> &&
        _isScalarCatalogSchema(definition);
  }
  if (schema['anyOf'] case final List<dynamic> variants) {
    return variants
        .whereType<Map<String, dynamic>>()
        .any(_isScalarCatalogSchema);
  }
  return const {'string', 'integer', 'number', 'boolean'}
      .contains(schema['type']);
}

final class _WorkspaceMessage extends StatelessWidget {
  const _WorkspaceMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 36, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

final class _CatalogItemCard extends StatelessWidget {
  const _CatalogItemCard({
    required this.item,
    required this.identity,
    required this.accent,
    required this.onEditCopy,
    required this.onAddCopy,
    required this.onDeleteCopy,
    required this.canEditCatalog,
    this.onEditCatalog,
    super.key,
  });

  final CatalogItemV1WorkspaceItem item;
  final LibraryKindIdentity identity;
  final Color accent;
  final bool canEditCatalog;
  final Future<void> Function(OwnedCopyV1 copy) onEditCopy;
  final VoidCallback onAddCopy;
  final Future<void> Function(OwnedCopyV1 copy) onDeleteCopy;
  final VoidCallback? onEditCatalog;

  @override
  Widget build(BuildContext context) {
    final copies = item.copies;
    final activeCopyCount =
        copies.where((copy) => copy.status != OwnedCopyStatusV1.sold).length;
    final soldCopyCount = copies.length - activeCopyCount;
    final cover = _catalogCover(item.catalogItem);
    final metadata = item.catalogItem == null
        ? const <String>[]
        : _summaryRows(item.catalogItem!);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cover != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      cover,
                      width: 72,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('$activeCopyCount active '
                          '${activeCopyCount == 1 ? 'copy' : 'copies'}'
                          '${soldCopyCount == 0 ? '' : ' · $soldCopyCount sold'}'),
                      if (metadata.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            metadata.take(3).join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      if (item.catalogError != null)
                        Text(
                          'Catalog details are unavailable while Core is offline.',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Add another owned copy',
                  onPressed: onAddCopy,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                if (canEditCatalog && onEditCatalog != null)
                  IconButton(
                    tooltip: 'Edit shared catalog details',
                    onPressed: onEditCatalog,
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            const Divider(height: 24),
            for (final copy in copies)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.inventory_2_outlined, color: accent),
                title: Text(_ownedCopySummary(copy)),
                subtitle: Text(_ownedCopyDetails(copy)),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Owned copy actions',
                  onSelected: (action) {
                    if (action == 'edit') onEditCopy(copy);
                    if (action == 'remove') onDeleteCopy(copy);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit copy')),
                    PopupMenuItem(value: 'remove', child: Text('Remove copy')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String? _catalogCover(CatalogItemV1Dto? item) {
  if (item == null) return null;
  final details = item.details.toJson();
  final images = details['images'];
  if (images is! List) return null;
  for (final image in images) {
    if (image is Map && image['url'] is String) {
      final url = (image['url'] as String).trim();
      if (url.isNotEmpty) return url;
    }
  }
  return null;
}

String _ownedCopySummary(OwnedCopyV1 copy) {
  final index = copy.indexNumber == null ? '' : ' #${copy.indexNumber}';
  return '${copy.status.apiValue.replaceAll('_', ' ')}$index';
}

String _ownedCopyDetails(OwnedCopyV1 copy) {
  final values = <String>[];
  if (copy.locationId != null && copy.locationId!.isNotEmpty) {
    values.add('Location ${copy.locationId}');
  }
  if (copy.condition != null && copy.condition!.isNotEmpty) {
    values.add(copy.condition!);
  }
  if (copy.notes != null && copy.notes!.isNotEmpty) values.add(copy.notes!);
  return values.join(' · ');
}

/// Opens the shared Catalog Item v1 Add flow from a workspace or a kind action.
Future<bool?> showCatalogItemV1AddDialog({
  required BuildContext context,
  required CatalogMediaKind kind,
  required String singularLabel,
  required Color accent,
  bool? canEditCatalog,
  String? initialQuery,
  String? initialIdentifier,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final canEdit =
      canEditCatalog ?? container.read(authControllerProvider).canEditCatalog;
  final added = await showDialog<bool>(
    context: context,
    builder: (context) => _CatalogItemV1AddDialog(
      kind: kind,
      singularLabel: singularLabel,
      accent: accent,
      canEditCatalog: canEdit,
      initialQuery: initialQuery,
      initialIdentifier: initialIdentifier,
    ),
  );
  if (added == true) {
    container
        .read(catalogItemV1WorkspaceRepositoryProvider)
        .clearCatalogCache();
    container.invalidate(catalogItemV1WorkspaceByKindProvider(kind));
  }
  return added;
}

final class _CatalogItemV1AddDialog extends ConsumerStatefulWidget {
  const _CatalogItemV1AddDialog({
    required this.kind,
    required this.singularLabel,
    required this.accent,
    required this.canEditCatalog,
    this.initialQuery,
    this.initialIdentifier,
  });

  final CatalogMediaKind kind;
  final String singularLabel;
  final Color accent;
  final bool canEditCatalog;
  final String? initialQuery;
  final String? initialIdentifier;

  @override
  ConsumerState<_CatalogItemV1AddDialog> createState() =>
      _CatalogItemV1AddDialogState();
}

final class _CatalogItemV1AddDialogState
    extends ConsumerState<_CatalogItemV1AddDialog> {
  final _queryController = TextEditingController();
  final _titleController = TextEditingController();
  final _sortTitleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _releaseYearController = TextEditingController();
  final _releaseMonthController = TextEditingController();
  final _releaseDayController = TextEditingController();
  List<CatalogItemSummaryV1Dto> _results = const [];
  CatalogItemSummaryV1Dto? _selected;
  CatalogItemV1Dto? _selectedDetails;
  bool _loadingSelectedDetails = false;
  String? _selectedDetailsError;
  late OwnedCopyV1FormDraft _copyDraft =
      OwnedCopyV1FormDraft.empty(widget.kind);
  bool _manual = false;
  bool _busy = false;
  bool _searchIdentifierOnly = false;
  String? _error;
  Map<String, dynamic> _kindDetails = {};

  @override
  void initState() {
    super.initState();
    final initialIdentifier = widget.initialIdentifier?.trim();
    final hasInitialIdentifier =
        initialIdentifier != null && initialIdentifier.isNotEmpty;
    _queryController.text =
        hasInitialIdentifier ? initialIdentifier : widget.initialQuery ?? '';
    _searchIdentifierOnly = hasInitialIdentifier;
    if (_searchIdentifierOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search();
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _titleController.dispose();
    _sortTitleController.dispose();
    _subtitleController.dispose();
    _releaseYearController.dispose();
    _releaseMonthController.dispose();
    _releaseDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Add ${widget.singularLabel}'),
        content: SizedBox(
          width: 620,
          height: 500,
          child: Column(
            children: [
              SegmentedButton<bool>(
                segments: [
                  const ButtonSegment(
                    value: false,
                    label: Text('Search Core'),
                  ),
                  if (widget.canEditCatalog)
                    const ButtonSegment(
                      value: true,
                      label: Text('Create manually'),
                    ),
                ],
                selected: {_manual},
                onSelectionChanged: (values) => setState(() {
                  _manual = values.single;
                  _error = null;
                  _results = const [];
                  _selected = null;
                  _selectedDetails = null;
                  _loadingSelectedDetails = false;
                  _selectedDetailsError = null;
                }),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    if (_manual) ...[
                      _CatalogItemCommonFields(
                        titleController: _titleController,
                        sortTitleController: _sortTitleController,
                        subtitleController: _subtitleController,
                        releaseYearController: _releaseYearController,
                        releaseMonthController: _releaseMonthController,
                        releaseDayController: _releaseDayController,
                      ),
                      _CatalogItemV1KindFields(
                        kind: widget.kind,
                        values: _kindDetails,
                        onChanged: (values) => setState(() {
                          _kindDetails = values;
                        }),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _queryController,
                              autofocus: true,
                              enabled: !_busy,
                              decoration: const InputDecoration(
                                labelText: 'Title or identifier',
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (_) => setState(() {
                                _searchIdentifierOnly = false;
                                _results = const [];
                                _selected = null;
                                _selectedDetails = null;
                                _loadingSelectedDetails = false;
                                _selectedDetailsError = null;
                                _error = null;
                              }),
                              onSubmitted: (_) => _search(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Scan barcode',
                            onPressed: _busy ? null : _scanBarcode,
                            icon: const Icon(Icons.qr_code_scanner),
                          ),
                          FilledButton(
                            onPressed: _busy ? null : _search,
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_results.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('Search the shared catalog.'),
                          ),
                        )
                      else
                        for (final result in _results)
                          ListTile(
                            selected: _selected?.id == result.id,
                            title: Text(result.title),
                            subtitle: Text(
                              [
                                result.artist,
                                if (result.releaseDate?.year != null)
                                  result.releaseDate!.year.toString(),
                                result.format,
                                result.country,
                                result.label,
                                result.barcode,
                              ].whereType<String>().join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: _selected?.id == result.id
                                ? Icon(Icons.check_circle, color: widget.accent)
                                : null,
                            onTap: () => _selectSearchResult(result),
                          ),
                    ],
                    if (_selected != null) ...[
                      const SizedBox(height: 8),
                      _SelectedCatalogItemDetails(
                        summary: _selected!,
                        details: _selectedDetails,
                        loading: _loadingSelectedDetails,
                        error: _selectedDetailsError,
                        accent: widget.accent,
                      ),
                    ],
                    const Divider(height: 24),
                    OwnedCopyV1Form(
                      key: const ValueKey('add-owned-copy-form'),
                      initial: _copyDraft,
                      showQuantity: true,
                      showAdvanced: true,
                      onChanged: (draft) => setState(() {
                        _copyDraft = draft;
                      }),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(_manual ? 'Create and add copy' : 'Add to collection'),
          ),
        ],
      );

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;
    final identifierOnly =
        _searchIdentifierOnly || RegExp(r'^\d{8,14}$').hasMatch(query);
    setState(() {
      _busy = true;
      _error = null;
      _selected = null;
      _selectedDetails = null;
      _loadingSelectedDetails = false;
      _selectedDetailsError = null;
    });
    try {
      final results =
          await ref.read(libraryCatalogItemV1AddServiceProvider).search(
                kind: widget.kind,
                query: identifierOnly ? null : query,
                identifier: identifierOnly ? query : null,
              );
      if (!mounted) return;
      setState(() => _results = results);
    } catch (error) {
      if (mounted) setState(() => _error = 'Catalog search failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scanBarcode() async {
    final scanned = await showModalBottomSheet<ScannedCode>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BarcodeScanSheet(
        title: 'Search by barcode',
        description:
            'Scan or enter an identifier to search the shared catalog.',
        manualLabel: 'Barcode / ISBN / identifier',
        submitLabel: 'Search catalog',
      ),
    );
    if (!mounted || scanned == null) return;
    _queryController.text = scanned.value;
    _searchIdentifierOnly = true;
    await _search();
  }

  Future<void> _selectSearchResult(CatalogItemSummaryV1Dto result) async {
    setState(() {
      _selected = result;
      _selectedDetails = null;
      _selectedDetailsError = null;
      _loadingSelectedDetails = true;
      _error = null;
    });
    try {
      final details = await ref
          .read(libraryCatalogItemV1AddServiceProvider)
          .get(result.reference);
      if (!mounted || _selected?.id != result.id) return;
      ref.read(catalogItemV1WorkspaceRepositoryProvider).remember(details);
      setState(() => _selectedDetails = details);
    } catch (error) {
      if (!mounted || _selected?.id != result.id) return;
      setState(() => _selectedDetailsError = error.toString());
    } finally {
      if (mounted && _selected?.id == result.id) {
        setState(() => _loadingSelectedDetails = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_copyDraft.validationError != null) {
      setState(() => _error = _copyDraft.validationError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = ref.read(libraryCatalogItemV1AddServiceProvider);
      CatalogItemRef reference;
      if (_manual) {
        final title = _titleController.text.trim();
        if (title.isEmpty) throw const FormatException('Title is required.');
        final releaseDate = _parseCatalogPartialDate(
          _releaseYearController.text,
          _releaseMonthController.text,
          _releaseDayController.text,
        );
        final details = <String, dynamic>{
          'kind': widget.kind.apiValue,
          'title': title,
          'sort_title': _nullableText(_sortTitleController.text),
          'subtitle': _nullableText(_subtitleController.text),
          if (releaseDate != null) 'release_date': releaseDate.toJson(),
          ..._kindDetails,
        };
        final typedDetails = catalogItemWriteDetailsFromJson(details);
        final matchesById = <String, CatalogItemSummaryV1Dto>{};
        for (final identifier in _catalogIdentitySearchValues(details)) {
          final matches = await service.search(
            kind: widget.kind,
            identifier: identifier,
            limit: 50,
          );
          for (final match in matches) {
            matchesById.putIfAbsent(match.id, () => match);
          }
        }
        if (matchesById.isNotEmpty) {
          final matches = matchesById.values.toList(growable: false);
          setState(() {
            _manual = false;
            _results = matches;
            _selected = null;
            _selectedDetails = null;
            _selectedDetailsError = null;
            _error = matches.length == 1
                ? 'This identifier already exists in the catalog. Review the item below before adding a copy.'
                : 'These identifiers match existing catalog items. Select the correct item below before adding a copy.';
          });
          if (matches.length == 1) {
            await _selectSearchResult(matches.single);
          }
          return;
        }
        final created = await service.create(
          CatalogItemWriteV1Dto(details: typedDetails),
        );
        ref.read(catalogItemV1WorkspaceRepositoryProvider).remember(created);
        reference = created.reference;
      } else {
        final selected = _selected;
        if (selected == null) {
          throw const FormatException('Select a Catalog Item first.');
        }
        reference = selected.reference;
      }

      await service.addCopies(
        item: reference,
        quantity: _copyDraft.quantity,
        status: _copyDraft.status,
        startingIndex: _copyDraft.indexNumber,
        locationId: _copyDraft.locationId,
        owner: _copyDraft.owner,
        isDigital: _copyDraft.isDigital,
        condition: _copyDraft.condition,
        purchaseDate: _copyDraft.purchaseDate,
        purchasePrice: _copyDraft.purchasePrice,
        purchaseStore: _copyDraft.purchaseStore,
        currentValue: _copyDraft.currentValue,
        soldAt: _copyDraft.soldAt,
        soldTo: _copyDraft.soldTo,
        salePrice: _copyDraft.salePrice,
        rating: _copyDraft.rating,
        notes: _copyDraft.notes,
        tags: _copyDraft.tags,
        personalImages: _copyDraft.personalImages,
        customFields: _copyDraft.customFields,
        kindDetails: _copyDraft.kindDetails,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = _catalogWriteError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

final class _CatalogItemCommonFields extends StatelessWidget {
  const _CatalogItemCommonFields({
    required this.titleController,
    required this.sortTitleController,
    required this.subtitleController,
    required this.releaseYearController,
    required this.releaseMonthController,
    required this.releaseDayController,
  });

  final TextEditingController titleController;
  final TextEditingController sortTitleController;
  final TextEditingController subtitleController;
  final TextEditingController releaseYearController;
  final TextEditingController releaseMonthController;
  final TextEditingController releaseDayController;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title *'),
          ),
          TextField(
            controller: sortTitleController,
            decoration: const InputDecoration(labelText: 'Sort Title'),
          ),
          TextField(
            controller: subtitleController,
            decoration: const InputDecoration(labelText: 'Subtitle'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Release date',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: releaseYearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          hintText: 'YYYY',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: releaseMonthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          hintText: 'MM',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: releaseDayController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Day',
                          hintText: 'DD',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
}

final class _SelectedCatalogItemDetails extends StatelessWidget {
  const _SelectedCatalogItemDetails({
    required this.summary,
    required this.details,
    required this.loading,
    required this.error,
    required this.accent,
  });

  final CatalogItemSummaryV1Dto summary;
  final CatalogItemV1Dto? details;
  final bool loading;
  final String? error;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final rows = details == null ? const <String>[] : _summaryRows(details!);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.album_outlined, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (loading)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 6),
              Text(
                'Could not load item details: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ] else if (rows.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(rows.join(' · ')),
            ],
          ],
        ),
      ),
    );
  }
}

List<String> _summaryRows(CatalogItemV1Dto item) {
  final details = item.details.toJson();
  const skip = {
    'kind',
    'title',
    'sort_title',
    'subtitle',
    'images',
    'tracks',
    'episodes',
    'credits',
    'contributors',
    'links',
    'identifiers',
  };
  final schema = _kindDetailsSchema(catalogMediaKindFromApiValue(item.kind));
  final properties = schema['properties'] as Map<String, dynamic>;
  final rows = <String>[];
  for (final entry in properties.entries) {
    if (skip.contains(entry.key)) continue;
    final text = _summaryText(details[entry.key]);
    if (text == null) continue;
    final fieldSchema = entry.value as Map<String, dynamic>;
    final label = fieldSchema['title'] as String? ?? _humanize(entry.key);
    rows.add('$label $text');
    if (rows.length == 6) break;
  }
  return rows;
}

List<String> _catalogNames(Object? value) {
  if (value is! List) return const [];
  return [
    for (final entry in value)
      if (entry is String && entry.trim().isNotEmpty)
        entry.trim()
      else if (entry is Map && entry['name'] is String)
        (entry['name'] as String).trim(),
  ];
}

String? _summaryText(Object? value) {
  if (value is String) return value.trim().isEmpty ? null : value.trim();
  if (value is num || value is bool) return value.toString();
  if (value is List) {
    final values = _catalogNames(value);
    return values.isEmpty ? null : values.join(', ');
  }
  if (value is Map && value['year'] is int) {
    final year = value['year'];
    final month = value['month'];
    final day = value['day'];
    if (month is int && day is int) {
      return '$year-${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';
    }
    if (month is int) return '$year-${month.toString().padLeft(2, '0')}';
    return '$year';
  }
  return null;
}

Map<String, dynamic> _kindDetailsSchema(CatalogMediaKind kind) {
  return catalogItemV1WriteSchemaForKind(kind);
}

Map<String, dynamic> _kindDetailValues(
  CatalogMediaKind kind,
  Map<String, dynamic> details,
) {
  final properties =
      _kindDetailsSchema(kind)['properties'] as Map<String, dynamic>;
  final values = <String, dynamic>{};
  for (final entry in properties.entries) {
    if (_commonCatalogKeys.contains(entry.key) || entry.key == 'kind') continue;
    if (details.containsKey(entry.key)) {
      values[entry.key] = _sanitizeCatalogValue(
        details[entry.key],
        entry.value as Map<String, dynamic>,
      );
    }
  }
  return values;
}

Map<String, dynamic> _sanitizeKindWriteDetails(
  CatalogMediaKind kind,
  Map<String, dynamic> details,
) {
  final properties =
      _kindDetailsSchema(kind)['properties'] as Map<String, dynamic>;
  final sanitized = <String, dynamic>{};
  for (final entry in properties.entries) {
    if (details.containsKey(entry.key)) {
      sanitized[entry.key] = _sanitizeCatalogValue(
        details[entry.key],
        entry.value as Map<String, dynamic>,
      );
    }
  }
  return sanitized;
}

const _commonCatalogKeys = {'title', 'sort_title', 'subtitle', 'release_date'};

List<String> _catalogIdentitySearchValues(Map<String, dynamic> details) {
  const uniqueIdentifierTypes = {
    'barcode',
    'ean',
    'gtin',
    'isbn',
    'isbn10',
    'isbn13',
    'upc',
  };
  final values = <String>{};
  void add(Object? value) {
    if (value is String && value.trim().isNotEmpty) values.add(value.trim());
  }

  add(details['barcode']);
  final identifiers = details['identifiers'];
  if (identifiers is List) {
    for (final identifier in identifiers) {
      if (identifier is! Map) continue;
      final rawType = identifier['identifier_type'];
      if (rawType is! String) continue;
      final type =
          rawType.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '');
      if (uniqueIdentifierTypes.contains(type)) add(identifier['value']);
    }
  }
  return values.toList(growable: false);
}

Object? _sanitizeCatalogValue(
  Object? value,
  Map<String, dynamic> schema,
) {
  final defs = catalogItemV1SchemaDefinitions;
  if (schema[r'$ref'] case final String ref) {
    final definition = defs[ref.split('/').last];
    if (definition is Map<String, dynamic>) {
      return _sanitizeCatalogValue(value, definition);
    }
  }
  if (schema['anyOf'] case final List<dynamic> variants) {
    final nonNull = variants.cast<Map<String, dynamic>>().where(
          (candidate) => candidate['type'] != 'null',
        );
    if (nonNull.isNotEmpty) {
      return _sanitizeCatalogValue(value, nonNull.first);
    }
  }
  if (schema['type'] == 'array' && value is List) {
    final itemSchema = schema['items'];
    if (itemSchema is Map<String, dynamic>) {
      return [
        for (final item in value) _sanitizeCatalogValue(item, itemSchema),
      ];
    }
  }
  if (schema['type'] == 'object' && value is Map) {
    final properties = schema['properties'];
    if (properties is Map<String, dynamic>) {
      return {
        for (final entry in properties.entries)
          if (value.containsKey(entry.key))
            entry.key: _sanitizeCatalogValue(
              value[entry.key],
              entry.value as Map<String, dynamic>,
            ),
      };
    }
  }
  return value;
}

final class _CatalogItemV1KindFields extends StatefulWidget {
  const _CatalogItemV1KindFields({
    required this.kind,
    required this.values,
    required this.onChanged,
  });

  final CatalogMediaKind kind;
  final Map<String, dynamic> values;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_CatalogItemV1KindFields> createState() =>
      _CatalogItemV1KindFieldsState();
}

final class _CatalogItemV1KindFieldsState
    extends State<_CatalogItemV1KindFields> {
  late final Map<String, dynamic> _properties =
      _kindDetailsSchema(widget.kind)['properties'] as Map<String, dynamic>;
  late Map<String, dynamic> _values =
      _kindDetailValues(widget.kind, widget.values);

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[];
    for (final entry in _properties.entries) {
      final key = entry.key;
      if (_commonCatalogKeys.contains(key) || key == 'kind') continue;
      final schema = entry.value as Map<String, dynamic>;
      final label = schema['title'] as String? ?? _humanize(key);
      fields.add(
        _CatalogItemSchemaField(
          key: ValueKey('catalog-field-${widget.kind.apiValue}-$key'),
          label: label,
          schema: schema,
          value: _values[key],
          onChanged: (value) => _setValue(key, value),
        ),
      );
    }
    if (fields.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Kind details', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...fields,
        ],
      ),
    );
  }

  void _setValue(String key, Object? value) {
    _values = Map<String, dynamic>.from(_values)..[key] = value;
    widget.onChanged(Map<String, dynamic>.from(_values));
  }
}

/// Renders primitive and repeated child fields from the pinned Core schema.
/// Object arrays are edited as rows, so users never need to hand-write JSON
/// for tracks, episodes, credits, images, identifiers, or similar children.
final class _CatalogItemSchemaField extends StatefulWidget {
  const _CatalogItemSchemaField({
    required this.label,
    required this.schema,
    required this.value,
    required this.onChanged,
    this.depth = 0,
    super.key,
  });

  final String label;
  final Map<String, dynamic> schema;
  final Object? value;
  final ValueChanged<Object?> onChanged;
  final int depth;

  @override
  State<_CatalogItemSchemaField> createState() =>
      _CatalogItemSchemaFieldState();
}

final class _CatalogItemSchemaFieldState
    extends State<_CatalogItemSchemaField> {
  late final TextEditingController _controller = TextEditingController(
    text: _fieldText(widget.value, widget.schema),
  );
  String? _lastEmittedText;

  @override
  void didUpdateWidget(covariant _CatalogItemSchemaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _lastEmittedText == null &&
        _fieldText(oldWidget.value, widget.schema) !=
            _fieldText(widget.value, widget.schema)) {
      _controller.value = TextEditingValue(
        text: _fieldText(widget.value, widget.schema),
        selection: TextSelection.collapsed(
          offset: _fieldText(widget.value, widget.schema).length,
        ),
      );
    }
    _lastEmittedText = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schema = _resolvedSchema(widget.schema);
    final enumValues = _enumValues(schema);
    if (enumValues != null) {
      final current = widget.value is String ? widget.value as String : null;
      return DropdownButtonFormField<String>(
        initialValue: current,
        decoration: InputDecoration(labelText: widget.label),
        items: [
          for (final value in enumValues)
            DropdownMenuItem(value: value, child: Text(value)),
        ],
        onChanged: widget.onChanged,
      );
    }

    final type = _fieldType(schema);
    if (type == 'boolean') {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(widget.label),
        value: widget.value == true,
        onChanged: widget.onChanged,
      );
    }
    if (type == 'array') return _buildArray(context, schema);
    if (type == 'object') return _buildObject(context, schema);

    return TextField(
      controller: _controller,
      keyboardType: type == 'integer' || type == 'number'
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (text) {
        _lastEmittedText = text;
        widget.onChanged(_parseFieldText(text, schema));
      },
    );
  }

  Widget _buildArray(BuildContext context, Map<String, dynamic> schema) {
    final itemSchemaRaw = schema['items'];
    if (itemSchemaRaw is! Map<String, dynamic>) {
      return _unsupportedField(context);
    }
    final itemSchema = _resolvedSchema(itemSchemaRaw);
    final values = widget.value is List
        ? List<Object?>.from(widget.value as List)
        : <Object?>[];
    final itemType = _fieldType(itemSchema);
    if (itemType != 'object' && itemType != 'array') {
      return TextField(
        controller: _controller,
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: 'Enter one value per line.',
          alignLabelWithHint: true,
        ),
        onChanged: (text) {
          _lastEmittedText = text;
          widget.onChanged(_parseFieldText(text, schema));
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                onPressed: () => widget.onChanged([
                  ...values,
                  _emptySchemaValue(itemSchema),
                ]),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          for (var index = 0; index < values.length; index++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Remove ${widget.label} item',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          final updated = List<Object?>.from(values)
                            ..removeAt(index);
                          widget.onChanged(updated);
                        },
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                    _CatalogItemSchemaField(
                      key: ValueKey(
                          'catalog-child-${widget.label}-$index-${widget.depth}'),
                      label: '${widget.label} ${index + 1}',
                      schema: itemSchema,
                      value: values[index],
                      depth: widget.depth + 1,
                      onChanged: (value) {
                        final updated = List<Object?>.from(values);
                        updated[index] = value;
                        widget.onChanged(updated);
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildObject(BuildContext context, Map<String, dynamic> schema) {
    final properties = schema['properties'];
    if (properties is! Map<String, dynamic>) {
      return _unsupportedField(context);
    }
    if (widget.value is! Map) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => widget.onChanged(_emptySchemaValue(schema)),
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add ${widget.label}'),
          ),
        ),
      );
    }
    final value = Map<String, dynamic>.from(widget.value as Map);
    return Padding(
      padding: EdgeInsets.only(top: widget.depth == 0 ? 8 : 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.depth == 0)
            Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          for (final entry in properties.entries)
            _CatalogItemSchemaField(
              key: ValueKey(
                  'catalog-object-${widget.label}-${entry.key}-${widget.depth}'),
              label:
                  (entry.value as Map<String, dynamic>)['title'] as String? ??
                      _humanize(entry.key),
              schema: entry.value as Map<String, dynamic>,
              value: value[entry.key],
              depth: widget.depth + 1,
              onChanged: (updatedValue) {
                widget.onChanged(Map<String, dynamic>.from(value)
                  ..[entry.key] = updatedValue);
              },
            ),
        ],
      ),
    );
  }

  Widget _unsupportedField(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '${widget.label} uses an unsupported schema shape.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}

Map<String, dynamic> _resolvedSchema(Map<String, dynamic> schema) {
  final defs = catalogItemV1SchemaDefinitions;
  if (schema[r'$ref'] case final String ref) {
    final definition = defs[ref.split('/').last];
    if (definition is Map<String, dynamic>) return definition;
  }
  if (schema['anyOf'] case final List<dynamic> variants) {
    for (final variant in variants.whereType<Map<String, dynamic>>()) {
      if (variant['type'] != 'null') return _resolvedSchema(variant);
    }
  }
  return schema;
}

Object? _emptySchemaValue(Map<String, dynamic> schema) {
  final resolved = _resolvedSchema(schema);
  final type = _fieldType(resolved);
  if (type == 'object') {
    final properties = resolved['properties'];
    if (properties is Map<String, dynamic>) {
      return {
        for (final entry in properties.entries)
          entry.key: _emptySchemaValue(entry.value as Map<String, dynamic>),
      };
    }
    return <String, dynamic>{};
  }
  if (type == 'array') return <Object?>[];
  if (type == 'boolean') return false;
  if (type == 'string') return '';
  return null;
}

String _fieldType(Map<String, dynamic> schema) =>
    _resolvedSchema(schema)['type'] as String? ?? 'string';

List<String>? _enumValues(Map<String, dynamic> schema) {
  if (schema['enum'] case final List<dynamic> values) {
    return values.whereType<String>().toList(growable: false);
  }
  if (schema['anyOf'] case final List<dynamic> variants) {
    for (final variant in variants.cast<Map<String, dynamic>>()) {
      final nested = _enumValues(variant);
      if (nested != null) return nested;
    }
  }
  return null;
}

String _fieldText(Object? value, Map<String, dynamic> schema) {
  if (value == null) return '';
  if (_fieldType(schema) == 'array' && value is List) {
    final itemSchema = schema['items'];
    if (itemSchema is Map<String, dynamic> && itemSchema['type'] == 'string') {
      return value.whereType<String>().join('\n');
    }
    return jsonEncode(value);
  }
  if (_fieldType(schema) == 'object' || _fieldType(schema) == 'array') {
    return jsonEncode(value);
  }
  return value.toString();
}

Object? _parseFieldText(String text, Map<String, dynamic> schema) {
  final type = _fieldType(schema);
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return _schemaAllowsNull(schema)
        ? null
        : switch (type) {
            'array' => <Object?>[],
            'string' => '',
            _ => null,
          };
  }
  if (type == 'array') {
    final itemSchema = schema['items'];
    if (itemSchema is Map<String, dynamic> && itemSchema['type'] == 'string') {
      return text
          .split('\n')
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList(growable: false);
    }
    if (itemSchema is Map<String, dynamic> && itemSchema['type'] == 'integer') {
      return text
          .split('\n')
          .map((entry) => int.tryParse(entry.trim()) ?? entry.trim())
          .where((entry) => entry.toString().isNotEmpty)
          .toList(growable: false);
    }
    try {
      final value = jsonDecode(text);
      return value is List ? value : text;
    } on FormatException {
      return text;
    }
  }
  if (type == 'object') {
    try {
      final value = jsonDecode(text);
      return value is Map ? value : text;
    } on FormatException {
      return text;
    }
  }
  if (type == 'integer') return int.tryParse(trimmed) ?? text;
  if (type == 'number') return num.tryParse(trimmed) ?? text;
  return text;
}

bool _schemaAllowsNull(Map<String, dynamic> schema) =>
    schema['anyOf'] is List &&
    (schema['anyOf'] as List).any(
      (variant) => variant is Map && variant['type'] == 'null',
    );

String _humanize(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

final class _CatalogItemCommonEditor extends StatefulWidget {
  const _CatalogItemCommonEditor({
    required this.title,
    required this.accent,
    required this.kind,
    required this.initialDetails,
  });

  final String title;
  final Color accent;
  final CatalogMediaKind kind;
  final Map<String, dynamic> initialDetails;

  @override
  State<_CatalogItemCommonEditor> createState() =>
      _CatalogItemCommonEditorState();
}

final class _CatalogItemCommonEditorState
    extends State<_CatalogItemCommonEditor> {
  late final TextEditingController _title = TextEditingController(
      text: widget.initialDetails['title'] as String? ?? '');
  late final TextEditingController _sortTitle = TextEditingController(
      text: widget.initialDetails['sort_title'] as String? ?? '');
  late final TextEditingController _subtitle = TextEditingController(
      text: widget.initialDetails['subtitle'] as String? ?? '');
  late final TextEditingController _releaseYear = TextEditingController(
    text: _partialDateComponent(widget.initialDetails['release_date'], 'year'),
  );
  late final TextEditingController _releaseMonth = TextEditingController(
    text: _partialDateComponent(widget.initialDetails['release_date'], 'month'),
  );
  late final TextEditingController _releaseDay = TextEditingController(
    text: _partialDateComponent(widget.initialDetails['release_date'], 'day'),
  );
  late Map<String, dynamic> _kindValues =
      _kindDetailValues(widget.kind, widget.initialDetails);
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _sortTitle.dispose();
    _subtitle.dispose();
    _releaseYear.dispose();
    _releaseMonth.dispose();
    _releaseDay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          width: 480,
          height: 560,
          child: Column(
            children: [
              _CatalogItemCommonFields(
                titleController: _title,
                sortTitleController: _sortTitle,
                subtitleController: _subtitle,
                releaseYearController: _releaseYear,
                releaseMonthController: _releaseMonth,
                releaseDayController: _releaseDay,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: _CatalogItemV1KindFields(
                    kind: widget.kind,
                    values: _kindValues,
                    onChanged: (values) => setState(() {
                      _kindValues = values;
                    }),
                  ),
                ),
              ),
              if (_error != null)
                Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      );

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }
    final details = _sanitizeKindWriteDetails(
      widget.kind,
      widget.initialDetails,
    )
      ..['title'] = title
      ..['sort_title'] = _nullableText(_sortTitle.text)
      ..['subtitle'] = _nullableText(_subtitle.text)
      ..addAll(_kindValues);
    try {
      details['release_date'] = _parseCatalogPartialDate(
        _releaseYear.text,
        _releaseMonth.text,
        _releaseDay.text,
      )?.toJson();
      final typedDetails = catalogItemWriteDetailsFromJson(details);
      Navigator.pop(context, CatalogItemWriteV1Dto(details: typedDetails));
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }
}

final class _OwnedCopyEditor extends StatefulWidget {
  const _OwnedCopyEditor({
    required this.copy,
    required this.title,
    required this.accent,
  });

  final OwnedCopyV1 copy;
  final String title;
  final Color accent;

  @override
  State<_OwnedCopyEditor> createState() => _OwnedCopyEditorState();
}

final class _OwnedCopyAddDialog extends StatefulWidget {
  const _OwnedCopyAddDialog({
    required this.title,
    required this.kind,
    required this.accent,
  });

  final String title;
  final CatalogMediaKind kind;
  final Color accent;

  @override
  State<_OwnedCopyAddDialog> createState() => _OwnedCopyAddDialogState();
}

final class _OwnedCopyAddDialogState extends State<_OwnedCopyAddDialog> {
  late OwnedCopyV1FormDraft _draft = OwnedCopyV1FormDraft.empty(widget.kind);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Add copy of ${widget.title}'),
        content: SizedBox(
          width: 620,
          height: 560,
          child: SingleChildScrollView(
            child: OwnedCopyV1Form(
              key: const ValueKey('quick-owned-copy-form'),
              initial: _draft,
              showQuantity: true,
              showAdvanced: true,
              onChanged: (draft) => setState(() => _draft = draft),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: _draft.validationError == null
                ? () => Navigator.pop(context, _draft)
                : null,
            child: Text('Add ${_draft.quantity} copies'),
          ),
        ],
      );
}

final class _OwnedCopyEditorState extends State<_OwnedCopyEditor> {
  late OwnedCopyV1FormDraft _draft = OwnedCopyV1FormDraft.fromCopy(widget.copy);
  String? _error;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Edit ${widget.title} copy'),
        content: SizedBox(
          width: 620,
          height: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OwnedCopyV1Form(
                  key: const ValueKey('edit-owned-copy-form'),
                  initial: _draft,
                  showAdvanced: true,
                  onChanged: (draft) => setState(() => _draft = draft),
                ),
                if (_error != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: widget.accent),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      );

  void _save() {
    final validationError = _draft.validationError;
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    try {
      Navigator.pop(context, _draft.buildCopy(widget.copy));
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }
}

String? _nullableText(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}

String _partialDateComponent(Object? value, String component) {
  if (value is! Map) return '';
  final date = PartialDate.tryParse(value);
  return switch (component) {
    'year' => date?.year?.toString() ?? '',
    'month' => date?.month?.toString() ?? '',
    'day' => date?.day?.toString() ?? '',
    _ => '',
  };
}

PartialDate? _parseCatalogPartialDate(
  String rawYear,
  String rawMonth,
  String rawDay,
) {
  final yearText = rawYear.trim();
  final monthText = rawMonth.trim();
  final dayText = rawDay.trim();
  if (yearText.isEmpty && monthText.isEmpty && dayText.isEmpty) return null;
  final year = yearText.isEmpty ? null : int.tryParse(yearText);
  final month = monthText.isEmpty ? null : int.tryParse(monthText);
  final day = dayText.isEmpty ? null : int.tryParse(dayText);
  if ((yearText.isNotEmpty && year == null) ||
      (monthText.isNotEmpty && month == null) ||
      (dayText.isNotEmpty && day == null)) {
    throw const FormatException(
      'Release date components must be whole numbers.',
    );
  }
  if (year != null && (year < 1 || year > 9999) ||
      month != null && (month < 1 || month > 12) ||
      day != null && (day < 1 || day > 31)) {
    throw const FormatException(
      'Release date components are outside their valid ranges.',
    );
  }
  final date = PartialDate(year: year, month: month, day: day);
  if (date.isFullDate && date.asDateTime == null) {
    throw const FormatException('Release date is not a valid calendar date.');
  }
  return date;
}

String _catalogWriteError(Object error) {
  final value = error.toString();
  if (value.contains('403') || value.contains('catalog_editor_required')) {
    return 'Creating or editing shared Catalog Items requires an editor or admin account.';
  }
  return value;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(content: Text(message)),
  );
}
