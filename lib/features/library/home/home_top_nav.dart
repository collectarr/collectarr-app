import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_nav_button.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/home/home_overflow_menu.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MediaLibraryNav extends ConsumerWidget {
  const MediaLibraryNav({
    super.key,
    required this.types,
    required this.counts,
    this.overdueLoanCount = 0,
    this.selectedOverdueLoanCount = 0,
    required this.selectedLabel,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
    this.animationDuration = kAppAnimNormal,
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = selectedLibraryHomeType(types, selectedKind);
    final accent = libraryAccentForKind(selected.kind);
    final selectedIcon = registry.byKind(selected.kind)?.workspace.icon ??
        libraryIconForKind(selected.kind);

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      height: 42,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color:
                Color.alphaBlend(Colors.black.withValues(alpha: 0.24), accent),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sideWidth = _headerSideWidth(
            labels: types.map((type) => type.pluralLabel),
            maxWidth: constraints.maxWidth,
          );
          return Row(
            children: [
              SizedBox(
                width: sideWidth,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _MediaLibraryTitle(
                      icon: selectedIcon,
                      label: selected.pluralLabel,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: MediaLibraryNavStrip(
                  types: types,
                  counts: counts,
                  registry: registry,
                  selectedKind: selected.kind,
                  onSelected: onSelected,
                  animationDuration: animationDuration,
                ),
              ),
              SizedBox(
                width: sideWidth,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _MediaLibraryHeaderActions(
                    accent: accent,
                    overdueLoanCount: overdueLoanCount,
                    selectedOverdueLoanCount: selectedOverdueLoanCount,
                    selectedLabel: selectedLabel,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MediaLibraryTitleBar extends ConsumerWidget {
  const MediaLibraryTitleBar({
    super.key,
    required this.type,
    this.overdueLoanCount = 0,
    this.selectedOverdueLoanCount = 0,
    required this.selectedLabel,
    required this.registry,
    this.animationDuration = kAppAnimNormal,
  });

  final CatalogMediaType type;
  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;
  final LibraryTypeRegistry registry;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = libraryAccentForKind(type.kind);
    final icon = registry.byKind(type.kind)?.workspace.icon ??
        libraryIconForKind(type.kind);
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      height: 42,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: Color.alphaBlend(
              Colors.black.withValues(alpha: 0.24),
              accent,
            ),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sideWidth = _headerSideWidth(
            labels: [type.pluralLabel],
            maxWidth: constraints.maxWidth,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                SizedBox(
                  width: sideWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _MediaLibraryTitle(
                      icon: icon,
                      label: type.pluralLabel,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: sideWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _MediaLibraryHeaderActions(
                      accent: accent,
                      overdueLoanCount: overdueLoanCount,
                      selectedOverdueLoanCount: selectedOverdueLoanCount,
                      selectedLabel: selectedLabel,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MediaLibraryTitle extends StatelessWidget {
  const _MediaLibraryTitle({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaLibraryHeaderActions extends ConsumerWidget {
  const _MediaLibraryHeaderActions({
    required this.accent,
    required this.overdueLoanCount,
    required this.selectedOverdueLoanCount,
    required this.selectedLabel,
  });

  final Color accent;
  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    final navPrefs = ref.watch(libraryNavPreferencesProvider);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderActionButton(
            tooltip: navPrefs.collapsed
                ? 'Show library selector'
                : 'Hide library selector',
            label: '',
            icon: navPrefs.collapsed
                ? Icons.expand_more
                : Icons.expand_less,
            onPressed: () => ref
                .read(libraryNavPreferencesProvider.notifier)
                .toggleCollapsed(),
          ),
          const SizedBox(width: 2),
          if (overdueLoanCount > 0) ...[
            _OverdueLoanChip(
              overdueLoanCount: overdueLoanCount,
              selectedOverdueLoanCount: selectedOverdueLoanCount,
              selectedLabel: selectedLabel,
              onPressed: () => context.go('${AppRoutes.shelf}?filter=overdue'),
            ),
            const SizedBox(width: 6),
          ],
          _HeaderActionButton(
            tooltip: sync.isSyncing
                ? 'Personal sync is running'
                : 'Run personal sync now',
            label: sync.isSyncing
                ? 'Syncing'
                : sync.pendingCount > 0
                    ? 'Sync ${sync.pendingCount}'
                    : 'Sync now',
            subtitle: sync.isSyncing ? null : _formatSyncAge(sync.lastSyncedAt),
            icon: sync.isOffline
                ? Icons.cloud_off_outlined
                : _syncIcon(sync),
            iconColor: _syncIconColor(sync),
            onPressed: sync.isSyncing
                ? null
                : () => ref.read(syncControllerProvider.notifier).syncNow(),
          ),
        ],
      ),
    );
  }
}

class _OverdueLoanChip extends StatelessWidget {
  const _OverdueLoanChip({
    required this.overdueLoanCount,
    required this.selectedOverdueLoanCount,
    required this.selectedLabel,
    required this.onPressed,
  });

  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = '$overdueLoanCount overdue';
    final tooltip = selectedOverdueLoanCount > 0
        ? '$overdueLoanCount overdue loan${overdueLoanCount == 1 ? '' : 's'} · '
            '$selectedOverdueLoanCount in $selectedLabel · Open Shelf'
        : '$overdueLoanCount overdue loan${overdueLoanCount == 1 ? '' : 's'} · Open Shelf';
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kAppOverdueBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kAppOverdueBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: kAppOverdueText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.tooltip,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.subtitle,
    this.iconColor,
  });

  final String tooltip;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? subtitle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          backgroundColor: Colors.black.withValues(alpha: 0.12),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        icon: Icon(icon, size: 16, color: iconColor),
        label: subtitle == null
            ? Text(label)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

double _headerSideWidth({
  required Iterable<String> labels,
  required double maxWidth,
}) {
  var maxLabelLength = 0;
  for (final label in labels) {
    if (label.length > maxLabelLength) {
      maxLabelLength = label.length;
    }
  }
  final estimated = (20.0 + 7 + maxLabelLength * 9 + 18)
      .clamp(132.0, 360.0)
      .toDouble();
  final available = maxWidth / 3;
  if (available <= 0) {
    return estimated;
  }
  if (available < 132) {
    return available;
  }
  return estimated.clamp(132.0, available).toDouble();
}

const Duration _staleSyncThreshold = Duration(hours: 24);

String? _formatSyncAge(DateTime? lastSyncedAt) {
  if (lastSyncedAt == null) return null;
  final diff = DateTime.now().toUtc().difference(lastSyncedAt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${diff.inDays ~/ 7}w ago';
}

IconData _syncIcon(SyncState sync) {
  if (sync.lastSyncedAt == null) return Icons.sync_outlined;
  final diff = DateTime.now().toUtc().difference(sync.lastSyncedAt!);
  if (diff > _staleSyncThreshold) return Icons.sync_problem;
  return Icons.sync_outlined;
}

Color? _syncIconColor(SyncState sync) {
  if (sync.isOffline) return Colors.orange;
  if (sync.lastSyncedAt == null) return null;
  final diff = DateTime.now().toUtc().difference(sync.lastSyncedAt!);
  if (diff > _staleSyncThreshold) return Colors.orange;
  return null;
}

class MediaLibraryNavStrip extends StatelessWidget {
  const MediaLibraryNavStrip({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
    this.animationDuration = kAppAnimNormal,
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxButtons =
            ((constraints.maxWidth - 42) / 116).floor().clamp(1, types.length);
        final split = splitLibraryNavTypes(types, selectedKind, maxButtons);
        return Row(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final type in split.visible)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: MediaLibraryNavButton(
                            type: type,
                            color: libraryAccentForKind(type.kind),
                            icon: registry.byKind(type.kind)?.workspace.icon ??
                                libraryIconForKind(type.kind),
                            selected: type.kind == selectedKind,
                            count: counts[type.kind]?.total ?? 0,
                            onPressed: () => onSelected(type),
                            animationDuration: animationDuration,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (split.overflow.isNotEmpty)
              MediaLibraryOverflowMenu(
                types: split.overflow,
                counts: counts,
                registry: registry,
                onSelected: onSelected,
              ),
          ],
        );
      },
    );
  }
}

class MediaLibraryCollapsedStrip extends ConsumerWidget {
  const MediaLibraryCollapsedStrip({
    super.key,
    required this.accent,
  });

  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            message: 'Show library selector',
            child: InkWell(
              onTap: () => ref
                  .read(libraryNavPreferencesProvider.notifier)
                  .toggleCollapsed(),
              child: Container(
                width: 42,
                height: 6,
                color: Colors.white.withValues(alpha: 0.18),
                child: const Icon(
                  Icons.expand_more,
                  size: 6,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MediaLibraryCollapsedRailStrip extends ConsumerWidget {
  const MediaLibraryCollapsedRailStrip({
    super.key,
    required this.accent,
  });

  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 6,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            message: 'Show library selector',
            child: InkWell(
              onTap: () => ref
                  .read(libraryNavPreferencesProvider.notifier)
                  .toggleCollapsed(),
              child: Container(
                width: 6,
                height: 42,
                color: Colors.white.withValues(alpha: 0.18),
                child: const Icon(
                  Icons.chevron_right,
                  size: 6,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
