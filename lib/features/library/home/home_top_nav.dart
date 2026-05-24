import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_nav_button.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/home/home_overflow_menu.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/settings/sync_settings_dialog.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaLibraryNav extends ConsumerWidget {
  const MediaLibraryNav({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
    this.animationDuration = const Duration(milliseconds: 320),
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
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
                  child: _MediaLibraryHeaderActions(accent: accent),
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
    required this.registry,
    this.animationDuration = const Duration(milliseconds: 320),
  });

  final CatalogMediaType type;
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
                    child: _MediaLibraryHeaderActions(accent: accent),
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
  const _MediaLibraryHeaderActions({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          tooltip: 'Library navigation options',
          child: PopupMenuButton<_LibraryNavMenuAction>(
            tooltip: 'Library navigation options',
            onSelected: (action) => _handleNavMenuAction(ref, action),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            icon: const Icon(Icons.grid_view_outlined, size: 18),
            iconColor: Colors.white,
            itemBuilder: (context) {
              final preferences = ref.read(libraryNavPreferencesProvider);
              return [
                CheckedPopupMenuItem<_LibraryNavMenuAction>(
                  value: _LibraryNavMenuAction.topNav,
                  checked: preferences.placement == LibraryNavPlacement.top,
                  child: const Text('Top navigation'),
                ),
                CheckedPopupMenuItem<_LibraryNavMenuAction>(
                  value: _LibraryNavMenuAction.leftRail,
                  checked: preferences.placement == LibraryNavPlacement.left,
                  child: const Text('Left rail navigation'),
                ),
              ];
            },
          ),
        ),
        const SizedBox(width: 6),
        _HeaderIconButton(
          tooltip: 'Account and sync',
          child: PopupMenuButton<_AccountMenuAction>(
            tooltip: 'Account and sync',
            onSelected: (action) => _handleAccountAction(context, ref, action),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            icon: const Icon(Icons.person_outline, size: 18),
            iconColor: Colors.white,
            itemBuilder: (context) => const [
              PopupMenuItem<_AccountMenuAction>(
                value: _AccountMenuAction.syncSettings,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.sync),
                  title: Text('Sync settings'),
                ),
              ),
              PopupMenuItem<_AccountMenuAction>(
                value: _AccountMenuAction.refreshAccount,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.manage_accounts_outlined),
                  title: Text('Refresh account'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<_AccountMenuAction>(
                value: _AccountMenuAction.signOut,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.logout),
                  title: Text('Sign out'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleNavMenuAction(
    WidgetRef ref,
    _LibraryNavMenuAction action,
  ) async {
    final controller = ref.read(libraryNavPreferencesProvider.notifier);
    switch (action) {
      case _LibraryNavMenuAction.topNav:
        await controller.setPlacement(LibraryNavPlacement.top);
      case _LibraryNavMenuAction.leftRail:
        await controller.setPlacement(LibraryNavPlacement.left);
    }
  }

  Future<void> _handleAccountAction(
    BuildContext context,
    WidgetRef ref,
    _AccountMenuAction action,
  ) async {
    switch (action) {
      case _AccountMenuAction.syncSettings:
        await showSyncSettingsDialog(context: context, accent: accent);
      case _AccountMenuAction.refreshAccount:
        try {
          await ref.read(authControllerProvider.notifier).refreshCurrentUser();
          if (!context.mounted) {
            return;
          }
          final auth = ref.read(authControllerProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                auth.isAdmin
                    ? 'Account permissions refreshed: admin'
                    : 'Account permissions refreshed: standard account',
              ),
            ),
          );
        } catch (error) {
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account refresh failed: $error')),
          );
        }
      case _AccountMenuAction.signOut:
        await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.child,
  });

  final String tooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 30,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Tooltip(message: tooltip, child: child),
      ),
    );
  }
}

enum _LibraryNavMenuAction { topNav, leftRail }

enum _AccountMenuAction { syncSettings, refreshAccount, signOut }

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
      .clamp(132.0, 240.0)
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

class MediaLibraryNavStrip extends StatelessWidget {
  const MediaLibraryNavStrip({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
    this.animationDuration = const Duration(milliseconds: 320),
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
