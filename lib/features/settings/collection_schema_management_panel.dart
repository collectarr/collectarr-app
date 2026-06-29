import 'dart:collection';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/settings/custom_fields_settings.dart';
import 'package:collectarr_app/features/settings/location_management_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _schemaExplorerProvider =
    FutureProvider.autoDispose<_SchemaExplorerSnapshot>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final tables = await Future.wait(
    db.allTables.map((table) async {
      final tableName = table.actualTableName;
      final quotedName = _quoteSqlIdentifier(tableName);
      final tableInfoRows =
          await db.customSelect('PRAGMA table_info($quotedName)').get();
      final foreignKeyRows =
          await db.customSelect('PRAGMA foreign_key_list($quotedName)').get();
      final rowCountRow =
          await db.customSelect('SELECT COUNT(*) AS row_count FROM $quotedName').getSingle();
      final columns = [
        for (final row in tableInfoRows)
          _SchemaColumnSnapshot(
            name: row.read<String>('name'),
            type: row.read<String>('type'),
            notNull: row.read<int>('notnull') == 1,
            defaultValue: row.read<String?>('dflt_value'),
            isPrimaryKey: row.read<int>('pk') > 0,
          ),
      ];
      final foreignKeys = [
        for (final row in foreignKeyRows)
          _SchemaForeignKeySnapshot(
            column: row.read<String>('from'),
            targetTable: row.read<String>('table'),
            targetColumn: row.read<String>('to'),
            onUpdate: row.read<String>('on_update'),
            onDelete: row.read<String>('on_delete'),
          ),
      ];
      return _SchemaTableSnapshot(
        name: tableName,
        rowCount: rowCountRow.read<int>('row_count'),
        columns: columns,
        foreignKeys: foreignKeys,
      );
    }),
  );
  return _SchemaExplorerSnapshot(tables: tables);
});

final _collectionSchemaSnapshotProvider =
    FutureProvider.autoDispose<_CollectionSchemaSnapshot>((ref) async {
  final db = ref.watch(localDatabaseProvider);
    final results = await Future.wait<Object>([
      LocationRepository(db).getAll(),
      CustomFieldRepository(db).listDefinitions(),
    ]);
    final locations = results[0] as List<StorageLocation>;
    final definitions = results[1] as List<CustomFieldDefinition>;
    final locationCount = locations.length;
    final rootCount = locations.where((entry) => entry.parentId == null).length;
    final customFieldCount = definitions.length;
    final scopedFieldCount = definitions
        .where((entry) => (entry.mediaKind?.trim().isNotEmpty ?? false))
        .length;
    final customFieldCountsByKind = <String, int>{};
    var globalCustomFieldCount = 0;
    for (final definition in definitions) {
      final mediaKind = definition.mediaKind?.trim();
      if (mediaKind == null || mediaKind.isEmpty) {
        globalCustomFieldCount += 1;
        continue;
      }
      customFieldCountsByKind.update(mediaKind, (value) => value + 1,
          ifAbsent: () => 1);
    }
    return _CollectionSchemaSnapshot(
      locationCount: locationCount,
      rootLocationCount: rootCount,
      customFieldCount: customFieldCount,
      scopedCustomFieldCount: scopedFieldCount,
      globalCustomFieldCount: globalCustomFieldCount,
      customFieldCountsByKind: customFieldCountsByKind,
    );
  },
);

class CollectionSchemaManagementPanel extends ConsumerWidget {
  const CollectionSchemaManagementPanel({
    super.key,
    required this.db,
  });

  final LocalDatabase db;

  Future<void> _openLocationManager(BuildContext context, WidgetRef ref) async {
    await showLocationManagementDialog(
      context: context,
      db: db,
    );
    ref.invalidate(_collectionSchemaSnapshotProvider);
  }

  Future<void> _createRootLocation(BuildContext context, WidgetRef ref) async {
    await showLocationManagementDialog(
      context: context,
      db: db,
      startCreating: true,
    );
    ref.invalidate(_collectionSchemaSnapshotProvider);
  }

  Future<void> _openCustomFieldManager(BuildContext context, WidgetRef ref) async {
    await showCustomFieldsManagementDialog(
      context: context,
      db: db,
    );
    ref.invalidate(_collectionSchemaSnapshotProvider);
  }

  Future<void> _createCustomField(BuildContext context, WidgetRef ref) async {
    await showCustomFieldsManagementDialog(
      context: context,
      db: db,
      startCreating: true,
    );
    ref.invalidate(_collectionSchemaSnapshotProvider);
  }

  List<String> _customFieldKindStats(_CollectionSchemaSnapshot? data) {
    if (data == null) {
      return const ['All libraries: 0'];
    }
    final stats = <String>['All libraries: ${data.globalCustomFieldCount}'];
    for (final type in collectarrLibraryTypes.types) {
      final count =
          data.customFieldCountsByKind[type.workspace.kind.apiValue];
      if (count == null || count == 0) {
        continue;
      }
      stats.add('${type.countLabel(count)}: $count');
    }
    return stats;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(_collectionSchemaSnapshotProvider);
    final data = snapshot.value;
    final loading = snapshot.isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Manage the reusable schema behind add defaults, inspector fields, bulk edit flows, and library-specific metadata capture.',
        ),
        const SizedBox(height: 12),
        _SchemaExplorerCard(db: db),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              Expanded(
                child: _CollectionSchemaCard(
                  icon: Icons.place_outlined,
                  title: 'Locations',
                  description:
                      'Create, rename, re-parent, and delete the shared hierarchy used for physical storage and default placement.',
                  stats: [
                    '${data?.locationCount ?? 0} total',
                    '${data?.rootLocationCount ?? 0} roots',
                  ],
                  loading: loading,
                  actions: [
                    _CollectionSchemaAction(
                      icon: Icons.add_circle_outline,
                      label: 'New root location',
                      onPressed: () => _createRootLocation(context, ref),
                    ),
                    _CollectionSchemaAction(
                      icon: Icons.open_in_new_outlined,
                      label: 'Manage locations',
                      onPressed: () => _openLocationManager(context, ref),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CollectionSchemaCard(
                  icon: Icons.tune_outlined,
                  title: 'Custom fields',
                  description:
                      'Add, reorder, scope, and remove extra fields used in edit dialogs, inspectors, and exports.',
                  stats: [
                    '${data?.customFieldCount ?? 0} fields',
                    '${data?.scopedCustomFieldCount ?? 0} scoped',
                  ],
                  loading: loading,
                  footerStats: _customFieldKindStats(data),
                  actions: [
                    _CollectionSchemaAction(
                      icon: Icons.add_circle_outline,
                      label: 'New custom field',
                      onPressed: () => _createCustomField(context, ref),
                    ),
                    _CollectionSchemaAction(
                      icon: Icons.open_in_new_outlined,
                      label: 'Manage custom fields',
                      onPressed: () => _openCustomFieldManager(context, ref),
                    ),
                  ],
                ),
              ),
            ];
            if (constraints.maxWidth < 760) {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 12),
                  cards[1],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cards[0],
                const SizedBox(width: 12),
                cards[1],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CollectionSchemaCard extends StatelessWidget {
  const _CollectionSchemaCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.stats,
    required this.loading,
    this.footerStats = const [],
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> stats;
  final bool loading;
  final List<String> footerStats;
  final List<_CollectionSchemaAction> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).panelRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appPalette(context).divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: appPalette(context).textMuted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stat in stats)
                  Chip(
                    label: Text(loading ? 'Loading...' : stat),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (footerStats.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Field scope',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: appPalette(context).textMuted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final stat in footerStats)
                    Chip(
                      label: Text(loading ? 'Loading...' : stat),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final action in actions)
                    OutlinedButton.icon(
                      onPressed: action.onPressed,
                      icon: Icon(action.icon),
                      label: Text(action.label),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CollectionSchemaAction {
  const _CollectionSchemaAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _SchemaExplorerCard extends ConsumerStatefulWidget {
  const _SchemaExplorerCard({required this.db});

  final LocalDatabase db;

  @override
  ConsumerState<_SchemaExplorerCard> createState() =>
      _SchemaExplorerCardState();
}

class _SchemaExplorerCardState extends ConsumerState<_SchemaExplorerCard> {
  final _searchController = TextEditingController();
  final _pathStartController = TextEditingController();
  final _pathEndController = TextEditingController();
  final _selectedCategories = <_SchemaTableCategory>{
    ..._SchemaTableCategory.values,
  };
  bool _showZeroRowTables = true;
  bool _showOnlyConnected = false;
  String? _selectedTableName;

  @override
  void dispose() {
    _searchController.dispose();
    _pathStartController.dispose();
    _pathEndController.dispose();
    super.dispose();
  }

  void _selectTable(String tableName) {
    setState(() {
      _selectedTableName = tableName;
      _pathStartController.text = _pathStartController.text.isEmpty
          ? tableName
          : _pathStartController.text;
      _pathEndController.text = tableName;
    });
  }

  Future<void> _copySummary(_SchemaExplorerSnapshot snapshot) async {
    final buffer = StringBuffer();
    buffer.writeln('Collectarr schema explorer');
    for (final group in _SchemaTableCategory.values) {
      final tables = snapshot.tables
          .where((table) => table.category == group)
          .toList(growable: false);
      if (tables.isEmpty) {
        continue;
      }
      buffer.writeln('${group.label}: ${tables.length}');
      for (final table in tables.take(5)) {
        buffer.writeln(
          '- ${table.name} (${table.rowCount} rows, ${table.columns.length} columns)',
        );
      }
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trimRight()));
  }

  List<String> _tracePath(_SchemaExplorerSnapshot snapshot) {
    final start = _pathStartController.text.trim();
    final end = _pathEndController.text.trim();
    if (start.isEmpty || end.isEmpty || start == end) {
      return const [];
    }
    final queue = <String>[start];
    final previous = <String, String?>{start: null};
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == end) {
        break;
      }
      for (final next in snapshot.neighborsOf(current)) {
        if (previous.containsKey(next)) {
          continue;
        }
        previous[next] = current;
        queue.add(next);
      }
    }
    if (!previous.containsKey(end)) {
      return const [];
    }
    final path = <String>[];
    String? cursor = end;
    while (cursor != null) {
      path.add(cursor);
      cursor = previous[cursor];
    }
    return path.reversed.toList(growable: false);
  }

  List<_SchemaTableSnapshot> _filteredTables(_SchemaExplorerSnapshot snapshot) {
    final query = _searchController.text.trim().toLowerCase();
    return snapshot.tables.where((table) {
      if (!_selectedCategories.contains(table.category)) {
        return false;
      }
      if (!_showZeroRowTables && table.rowCount == 0) {
        return false;
      }
      if (_showOnlyConnected && !table.isConnected(snapshot)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack = [
        table.name,
        table.category.label,
        ...table.columns.map((column) => column.name),
        ...table.foreignKeys.map((fk) => fk.targetTable),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(_schemaExplorerProvider);
    final data = snapshot.value;
    final loading = snapshot.isLoading;
    final tables = data == null ? const <_SchemaTableSnapshot>[] : _filteredTables(data);
    final selected = data == null
        ? null
        : data.tableByName[_selectedTableName] ??
            (tables.isNotEmpty ? tables.first : null);
    final path = data == null ? const <String>[] : _tracePath(data);
    if (selected != null &&
        _pathStartController.text.isEmpty &&
        _pathEndController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            _pathStartController.text.isNotEmpty ||
            _pathEndController.text.isNotEmpty ||
            selected == null) {
          return;
        }
        setState(() {
          _pathStartController.text = selected.name;
          _pathEndController.text = selected.name;
        });
      });
    }
    return Material(
      color: appPalette(context).panelRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: appPalette(context).divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree_outlined, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Schema explorer',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: data == null ? null : () => _copySummary(data),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy summary'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Search tables and columns, inspect foreign keys, and trace relationships between storage areas, caches, and lookup tables.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: appPalette(context).textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Search tables, columns, or relations',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Show zero-row tables'),
                  selected: _showZeroRowTables,
                  onSelected: (value) => setState(() => _showZeroRowTables = value),
                ),
                FilterChip(
                  label: const Text('Only connected tables'),
                  selected: _showOnlyConnected,
                  onSelected: (value) => setState(() => _showOnlyConnected = value),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategories
                        ..clear()
                        ..addAll(_SchemaTableCategory.values);
                    });
                  },
                  icon: const Icon(Icons.select_all_outlined),
                  label: const Text('Reset filters'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in _SchemaTableCategory.values)
                  FilterChip(
                    label: Text(
                      data == null
                          ? category.label
                          : '${category.label} ${data.countFor(category)}',
                    ),
                    selected: _selectedCategories.contains(category),
                    selectedColor: category.color.withValues(alpha: 0.22),
                    onSelected: (value) => setState(() {
                      if (value) {
                        _selectedCategories.add(category);
                      } else if (_selectedCategories.length > 1) {
                        _selectedCategories.remove(category);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading) const LinearProgressIndicator(minHeight: 2),
            if (loading) const SizedBox(height: 12),
            SizedBox(
              height: 560,
              child: data == null
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 900;
                        final grouped = <_SchemaTableCategory, List<_SchemaTableSnapshot>>{};
                        for (final table in tables) {
                          grouped.putIfAbsent(table.category, () => []).add(table);
                        }
                        final listPane = _SchemaTableListPane(
                          groupedTables: grouped,
                          tables: tables,
                          selectedTableName: selected?.name,
                          onSelected: _selectTable,
                        );
                        final detailPane = _SchemaTableDetailPane(
                          snapshot: data,
                          table: selected,
                          activePath: path,
                          pathStartController: _pathStartController,
                          pathEndController: _pathEndController,
                          onTracePath: () => setState(() {}),
                        );
                        if (compact) {
                          return Column(
                            children: [
                              Expanded(child: listPane),
                              const SizedBox(height: 12),
                              Expanded(child: detailPane),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(flex: 5, child: listPane),
                            const SizedBox(width: 12),
                            Expanded(flex: 4, child: detailPane),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchemaTableListPane extends StatelessWidget {
  const _SchemaTableListPane({
    required this.groupedTables,
    required this.tables,
    required this.selectedTableName,
    required this.onSelected,
  });

  final Map<_SchemaTableCategory, List<_SchemaTableSnapshot>> groupedTables;
  final List<_SchemaTableSnapshot> tables;
  final String? selectedTableName;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: appPalette(context).divider),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final category in _SchemaTableCategory.values)
            if ((groupedTables[category] ?? const []).isNotEmpty)
              ExpansionTile(
                initiallyExpanded: category == _SchemaTableCategory.content,
                title: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${category.label} (${groupedTables[category]!.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                children: [
                  for (final table in groupedTables[category]!)
                    _SchemaTableTile(
                      table: table,
                      selected: table.name == selectedTableName,
                      onTap: () => onSelected(table.name),
                    ),
                ],
              ),
          if (tables.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No tables match the current filters.',
                style: TextStyle(color: appPalette(context).textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _SchemaTableTile extends StatelessWidget {
  const _SchemaTableTile({
    required this.table,
    required this.selected,
    required this.onTap,
  });

  final _SchemaTableSnapshot table;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? palette.accent.withValues(alpha: 0.14) : palette.panelRaised,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        table.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _MiniBadge(label: '${table.rowCount} rows'),
                    const SizedBox(width: 8),
                    _MiniBadge(label: '${table.columns.length} cols'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniBadge(label: table.category.label, color: table.category.color),
                    if (table.foreignKeys.isNotEmpty)
                      _MiniBadge(
                        label: '${table.foreignKeys.length} fk',
                        color: palette.textMuted,
                      ),
                    if (table.isJoinTable)
                      _MiniBadge(
                        label: 'join',
                        color: palette.textMuted,
                      ),
                    if (table.rowCount == 0)
                      const _MiniBadge(
                        label: 'empty',
                        color: Colors.orangeAccent,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SchemaTableDetailPane extends StatelessWidget {
  const _SchemaTableDetailPane({
    required this.snapshot,
    required this.table,
    required this.activePath,
    required this.pathStartController,
    required this.pathEndController,
    required this.onTracePath,
  });

  final _SchemaExplorerSnapshot snapshot;
  final _SchemaTableSnapshot? table;
  final List<String> activePath;
  final TextEditingController pathStartController;
  final TextEditingController pathEndController;
  final VoidCallback onTracePath;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (table == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.divider),
        ),
        child: const Center(
          child: Text('Select a table to inspect columns and relations.'),
        ),
      );
    }
    final current = table!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    current.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                _MiniBadge(label: current.category.label, color: current.category.color),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniBadge(label: '${current.rowCount} rows'),
                _MiniBadge(label: '${current.columns.length} columns'),
                _MiniBadge(label: '${current.primaryKeyColumns.length} PK'),
                _MiniBadge(label: '${current.foreignKeys.length} FK'),
                _MiniBadge(label: '${current.incomingReferences(snapshot).length} inbound'),
                if (current.isJoinTable) _MiniBadge(label: 'join table'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Trace path',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: pathStartController.text.isEmpty
                  ? current.name
                  : pathStartController.text,
              decoration: const InputDecoration(
                labelText: 'Start table',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final entry in snapshot.tables)
                  DropdownMenuItem(
                    value: entry.name,
                    child: Text(entry.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  pathStartController.text = value;
                }
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: pathEndController.text.isEmpty ? current.name : pathEndController.text,
              decoration: const InputDecoration(
                labelText: 'End table',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final entry in snapshot.tables)
                  DropdownMenuItem(
                    value: entry.name,
                    child: Text(entry.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  pathEndController.text = value;
                }
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onTracePath,
              icon: const Icon(Icons.alt_route_outlined),
              label: const Text('Trace path'),
            ),
            if (activePath.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final part in activePath)
                    _MiniBadge(label: part, color: palette.accent),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Columns',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 8),
            ...[
              for (final column in current.columns)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.panelRaised,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: palette.divider),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  column.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (column.isPrimaryKey) ...[
                                _MiniBadge(label: 'PK', color: palette.accent),
                                const SizedBox(width: 6),
                              ],
                              if (column.isForeignKey(current))
                                const _MiniBadge(
                                  label: 'FK',
                                  color: Colors.greenAccent,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${column.type.isEmpty ? 'unknown' : column.type}'
                            '${column.notNull ? ' · required' : ' · nullable'}'
                            '${column.defaultValue == null ? '' : ' · default ${column.defaultValue}'}',
                            style: TextStyle(color: palette.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 4),
            if (current.foreignKeys.isNotEmpty) ...[
              Text(
                'Foreign keys',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: palette.textMuted),
              ),
              const SizedBox(height: 8),
              for (final fk in current.foreignKeys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${fk.column} → ${fk.targetTable}.${fk.targetColumn} '
                    '(${fk.onDelete}, ${fk.onUpdate})',
                    style: TextStyle(color: palette.textMuted),
                  ),
                ),
            ],
            const SizedBox(height: 4),
            ...(() {
              final inbound = current.incomingReferences(snapshot).toList(growable: false);
              if (inbound.isEmpty) {
                return const <Widget>[];
              }
              return <Widget>[
                Text(
                  'Referenced by',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final ref in inbound)
                      _MiniBadge(label: ref, color: palette.textMuted),
                  ],
                ),
              ];
            })(),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedColor = color ?? palette.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: resolvedColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CollectionSchemaSnapshot {
  const _CollectionSchemaSnapshot({
    required this.locationCount,
    required this.rootLocationCount,
    required this.customFieldCount,
    required this.scopedCustomFieldCount,
    required this.globalCustomFieldCount,
    required this.customFieldCountsByKind,
  });

  final int locationCount;
  final int rootLocationCount;
  final int customFieldCount;
  final int scopedCustomFieldCount;
  final int globalCustomFieldCount;
  final Map<String, int> customFieldCountsByKind;
}

class _SchemaExplorerSnapshot {
  _SchemaExplorerSnapshot({required List<_SchemaTableSnapshot> tables})
      : tables = UnmodifiableListView(tables),
        tableByName = {
          for (final table in tables) table.name: table,
        } {
    for (final table in tables) {
      for (final fk in table.foreignKeys) {
        final outgoing = relationsBySource.putIfAbsent(table.name, () => <String>{});
        outgoing.add(fk.targetTable);
        final incoming = relationsByTarget.putIfAbsent(fk.targetTable, () => <String>{});
        incoming.add(table.name);
      }
    }
  }

  final UnmodifiableListView<_SchemaTableSnapshot> tables;
  final Map<String, _SchemaTableSnapshot> tableByName;
  final Map<String, Set<String>> relationsBySource = {};
  final Map<String, Set<String>> relationsByTarget = {};

  Set<String> neighborsOf(String tableName) {
    final neighbors = <String>{};
    neighbors.addAll(relationsBySource[tableName] ?? const {});
    neighbors.addAll(relationsByTarget[tableName] ?? const {});
    return neighbors;
  }

  int countFor(_SchemaTableCategory category) {
    return tables.where((table) => table.category == category).length;
  }
}

class _SchemaTableSnapshot {
  const _SchemaTableSnapshot({
    required this.name,
    required this.rowCount,
    required this.columns,
    required this.foreignKeys,
  });

  final String name;
  final int rowCount;
  final List<_SchemaColumnSnapshot> columns;
  final List<_SchemaForeignKeySnapshot> foreignKeys;

  _SchemaTableCategory get category => _inferCategory(name);

  List<_SchemaColumnSnapshot> get primaryKeyColumns =>
      columns.where((column) => column.isPrimaryKey).toList(growable: false);

  bool get isJoinTable =>
      foreignKeys.length >= 2 || name.endsWith('ItemsCache') || name.endsWith('ValuesCache');

  bool isConnected(_SchemaExplorerSnapshot snapshot) =>
      foreignKeys.isNotEmpty || incomingReferences(snapshot).isNotEmpty;

  Set<String> incomingReferences(_SchemaExplorerSnapshot snapshot) =>
      snapshot.relationsByTarget[name] ?? const {};
}

class _SchemaColumnSnapshot {
  const _SchemaColumnSnapshot({
    required this.name,
    required this.type,
    required this.notNull,
    required this.defaultValue,
    required this.isPrimaryKey,
  });

  final String name;
  final String type;
  final bool notNull;
  final String? defaultValue;
  final bool isPrimaryKey;

  bool isForeignKey(_SchemaTableSnapshot table) =>
      table.foreignKeys.any((fk) => fk.column == name);
}

class _SchemaForeignKeySnapshot {
  const _SchemaForeignKeySnapshot({
    required this.column,
    required this.targetTable,
    required this.targetColumn,
    required this.onUpdate,
    required this.onDelete,
  });

  final String column;
  final String targetTable;
  final String targetColumn;
  final String onUpdate;
  final String onDelete;
}

enum _SchemaTableCategory { content, cache, settings, lookup, sync, join, other }

extension on _SchemaTableCategory {
  String get label => switch (this) {
        _SchemaTableCategory.content => 'Content',
        _SchemaTableCategory.cache => 'Cache',
        _SchemaTableCategory.settings => 'Settings',
        _SchemaTableCategory.lookup => 'Lookup',
        _SchemaTableCategory.sync => 'Sync',
        _SchemaTableCategory.join => 'Join',
        _SchemaTableCategory.other => 'Other',
      };

  Color get color => switch (this) {
        _SchemaTableCategory.content => Colors.tealAccent,
        _SchemaTableCategory.cache => Colors.amberAccent,
        _SchemaTableCategory.settings => Colors.lightBlueAccent,
        _SchemaTableCategory.lookup => Colors.purpleAccent,
        _SchemaTableCategory.sync => Colors.greenAccent,
        _SchemaTableCategory.join => Colors.orangeAccent,
        _SchemaTableCategory.other => Colors.grey,
      };
}

String _quoteSqlIdentifier(String value) => '"${value.replaceAll('"', '""')}"';

_SchemaTableCategory _inferCategory(String tableName) {
  final lower = tableName.toLowerCase();
  if (lower.endsWith('cache')) {
    return _SchemaTableCategory.cache;
  }
  if (lower.contains('sync')) {
    return _SchemaTableCategory.sync;
  }
  if (lower.contains('settings') ||
      lower.contains('location') ||
      lower.contains('customfield') ||
      lower.contains('userfolder') ||
      lower.contains('smartlist') ||
      lower.contains('seriesregistry') ||
      lower.contains('picklist')) {
    return _SchemaTableCategory.settings;
  }
  if (lower.contains('value') ||
      lower.contains('lookup') ||
      lower.contains('tag') ||
      lower.contains('genre')) {
    return _SchemaTableCategory.lookup;
  }
  if (lower.contains('item') && (lower.contains('items') || lower.contains('units'))) {
    return _SchemaTableCategory.join;
  }
  if (lower.contains('catalog') ||
      lower.contains('owned') ||
      lower.contains('wishlist') ||
      lower.contains('tracking') ||
      lower.contains('watch') ||
      lower.contains('loan') ||
      lower.contains('series') ||
      lower.contains('release') ||
      lower.contains('customepisodes')) {
    return _SchemaTableCategory.content;
  }
  return _SchemaTableCategory.other;
}
