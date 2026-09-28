part of 'catalog_item_v1_workspace_page.dart';

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
  static const _columnPreferencePrefix = 'catalog_item_v1.visible_columns.';

  final _searchController = TextEditingController();
  late List<({CatalogItemV1WorkspaceItem item, String searchText})>
      _searchIndex = _buildSearchIndex(widget.items);
  String _query = '';
  String _sortField = 'title';
  String _groupField = '';
  bool _ascending = true;
  late Set<String> _visibleColumns = _defaultVisibleColumns();
  bool _columnsLoaded = false;
  bool _tableMode = false;

  @override
  void initState() {
    super.initState();
    _loadVisibleColumns();
  }

  @override
  void didUpdateWidget(covariant _CatalogItemWorkspaceList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items)) {
      _searchIndex = _buildSearchIndex(widget.items);
    }
    if (oldWidget.identity.kind != widget.identity.kind) {
      _columnsLoaded = false;
      _visibleColumns = _defaultVisibleColumns();
      _loadVisibleColumns();
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
                tooltip: 'Choose visible columns',
                onPressed: _columnsLoaded ? _configureColumns : null,
                icon: const Icon(Icons.view_column_outlined),
              ),
              IconButton(
                tooltip: _tableMode ? 'Show cards' : 'Show table',
                onPressed: () => setState(() => _tableMode = !_tableMode),
                icon: Icon(_tableMode ? Icons.grid_view : Icons.table_rows),
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
              '${visibleItems.length} ${widget.identity.pluralLabel.toLowerCase()} Â· '
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
              : _tableMode
                  ? _catalogTable(workspaceRows)
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
                            visibleColumns: _visibleColumns,
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

  Widget _catalogTable(
    List<({CatalogItemV1WorkspaceItem? item, String? groupLabel})> rows,
  ) {
    final detailColumns = [
      for (final field in _availableColumnFields())
        if (_visibleColumns.contains(field)) field,
    ];
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Catalog Item')),
              for (final field in detailColumns)
                DataColumn(label: Text(_fieldLabel(field))),
              const DataColumn(label: Text('Owned Copies')),
              const DataColumn(label: Text('Actions')),
            ],
            rows: [
              for (final row in rows)
                if (row.item == null)
                  DataRow(
                    cells: [
                      DataCell(Text(
                        row.groupLabel!,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      )),
                      for (var index = 0;
                          index < detailColumns.length + 2;
                          index++)
                        const DataCell(SizedBox.shrink()),
                    ],
                  )
                else
                  _catalogDataRow(row.item!, detailColumns),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _catalogDataRow(
    CatalogItemV1WorkspaceItem item,
    List<String> detailColumns,
  ) {
    final details = item.catalogItem?.details.toJson() ?? const {};
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(item.title, overflow: TextOverflow.ellipsis),
          ),
        ),
        for (final field in detailColumns)
          DataCell(Text(_summaryText(details[field]) ?? 'â€”')),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 210),
            child: item.copies.isEmpty
                ? const Text('Wishlist')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final copy in item.copies)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '${_ownedCopySummary(copy)} Â· ${_ownedCopyDetails(copy)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Owned copy actions',
                              onSelected: (action) {
                                if (action == 'edit') {
                                  widget.onEditCopy(copy);
                                } else if (action == 'remove') {
                                  widget.onDeleteCopy(copy);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit copy'),
                                ),
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove copy'),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
        ),
        DataCell(
          Wrap(
            children: [
              IconButton(
                tooltip: 'Add owned copy',
                onPressed: () => widget.onAddCopy(item),
                icon: const Icon(Icons.add_circle_outline),
              ),
              if (widget.canEditCatalog && item.catalogItem != null)
                IconButton(
                  tooltip: 'Edit catalog details',
                  onPressed: () => widget.onEditCatalog(item),
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
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

  List<String> _availableColumnFields() {
    final properties = _kindDetailsSchema(widget.identity.kind)['properties'];
    final fields = <String>[];
    if (properties is! Map<String, dynamic>) return fields;
    for (final entry in properties.entries) {
      if (entry.key == 'title' ||
          entry.key == 'sort_title' ||
          entry.key == 'subtitle' ||
          entry.key == 'images' ||
          entry.key == 'tracks' ||
          entry.key == 'episodes' ||
          entry.key == 'credits' ||
          entry.key == 'contributors' ||
          entry.key == 'links' ||
          entry.key == 'identifiers') {
        continue;
      }
      final schema = entry.value;
      if (schema is Map<String, dynamic> &&
          (entry.key == 'release_date' || _isScalarCatalogSchema(schema))) {
        fields.add(entry.key);
      }
    }
    return fields;
  }

  Set<String> _defaultVisibleColumns() {
    final available = _availableColumnFields();
    return {
      ...available.take(3),
    };
  }

  Future<void> _loadVisibleColumns() async {
    final preferences = await SharedPreferences.getInstance();
    final available = _availableColumnFields().toSet();
    final saved = preferences.getStringList(
      '$_columnPreferencePrefix${widget.identity.kind.apiValue}',
    );
    if (!mounted) return;
    setState(() {
      _visibleColumns = saved == null
          ? _defaultVisibleColumns()
          : saved.where(available.contains).toSet();
      _columnsLoaded = true;
    });
  }

  Future<void> _configureColumns() async {
    final available = _availableColumnFields();
    final selected = Set<String>.of(_visibleColumns);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Visible Catalog Item columns'),
          content: SizedBox(
            width: 380,
            height: 440,
            child: ListView(
              children: [
                for (final field in available)
                  CheckboxListTile(
                    dense: true,
                    value: selected.contains(field),
                    title: Text(_fieldLabel(field)),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (visible) => setDialogState(() {
                      visible == true
                          ? selected.add(field)
                          : selected.remove(field);
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                _defaultVisibleColumns(),
              ),
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selected),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    final normalized = result.intersection(available.toSet());
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      '$_columnPreferencePrefix${widget.identity.kind.apiValue}',
      normalized.toList()..sort(),
    );
    if (mounted) setState(() => _visibleColumns = normalized);
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
    required this.visibleColumns,
    this.onEditCatalog,
    super.key,
  });

  final CatalogItemV1WorkspaceItem item;
  final LibraryKindIdentity identity;
  final Color accent;
  final bool canEditCatalog;
  final Set<String> visibleColumns;
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
        : _visibleCatalogColumnRows(item.catalogItem!, visibleColumns);
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
                if (cover != null || canEditCatalog) ...[
                  CatalogItemV1CoverPanel(
                    reference: item.reference,
                    fallbackUrl: cover,
                    canEdit: canEditCatalog,
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
                          '${soldCopyCount == 0 ? '' : ' Â· $soldCopyCount sold'}'),
                      if (metadata.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            metadata.join(' Â· '),
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
  return values.join(' Â· ');
}

/// Opens the shared Catalog Item v1 Add flow from a workspace or a kind action.
