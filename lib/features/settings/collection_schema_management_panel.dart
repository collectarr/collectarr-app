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
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        color: kAppPanelRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAppDivider),
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
                  ?.copyWith(color: kAppTextMuted),
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
                    ?.copyWith(color: kAppTextMuted),
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