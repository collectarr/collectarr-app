import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_nav_button.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
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
    final palette = appPalette(context);
    final selectedIcon = registry.byKind(selected.kind)?.workspace.icon ??
        libraryIconForKind(selected.kind);

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      height: 42,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          brightness: palette.brightness,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: libraryChromeBorderColor(
              accent,
              brightness: palette.brightness,
            ),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final titleWidth = _headerTitleWidth(
            labels: types.map((type) => type.pluralLabel),
            maxWidth: constraints.maxWidth,
          );
          return Row(
            children: [
              SizedBox(
                width: titleWidth,
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
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _MediaLibraryHeaderActions(
                  accent: accent,
                  overdueLoanCount: overdueLoanCount,
                  selectedOverdueLoanCount: selectedOverdueLoanCount,
                  selectedLabel: selectedLabel,
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
    final palette = appPalette(context);
    final icon = registry.byKind(type.kind)?.workspace.icon ??
        libraryIconForKind(type.kind);
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      height: 42,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          brightness: palette.brightness,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: libraryChromeBorderColor(
              accent,
              brightness: palette.brightness,
            ),
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final titleWidth = _headerTitleWidth(
            labels: [type.pluralLabel],
            maxWidth: constraints.maxWidth,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                SizedBox(
                  width: titleWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _MediaLibraryTitle(
                      icon: icon,
                      label: type.pluralLabel,
                    ),
                  ),
                ),
                const Spacer(),
                _MediaLibraryHeaderActions(
                  accent: accent,
                  overdueLoanCount: overdueLoanCount,
                  selectedOverdueLoanCount: selectedOverdueLoanCount,
                  selectedLabel: selectedLabel,
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
    final palette = appPalette(context);
    final titleColor = palette.isDark ? Colors.white : palette.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 20, color: titleColor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              color: titleColor,
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
    final navPrefs = ref.watch(libraryNavPreferencesProvider);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (overdueLoanCount > 0) ...[
            _OverdueLoanChip(
              overdueLoanCount: overdueLoanCount,
              selectedOverdueLoanCount: selectedOverdueLoanCount,
              selectedLabel: selectedLabel,
              onPressed: () => context.go('${AppRoutes.shelf}?filter=overdue'),
            ),
            const SizedBox(width: 6),
          ],
          const _TopBarSyncButton(),
          const SizedBox(width: 2),
          _HeaderActionButton(
            tooltip: navPrefs.collapsed
                ? 'Show library selector'
                : 'Hide library selector',
            label: '',
            icon: navPrefs.collapsed ? Icons.expand_more : Icons.expand_less,
            onPressed: () => ref
                .read(libraryNavPreferencesProvider.notifier)
                .toggleCollapsed(),
          ),
        ],
      ),
    );
  }
}

class _TopBarSyncButton extends ConsumerWidget {
  const _TopBarSyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    final palette = appPalette(context);
    final controlBackground = palette.isDark
        ? Colors.black.withValues(alpha: 0.12)
        : Color.alphaBlend(
            palette.accent.withValues(alpha: 0.08),
            palette.surfaceSubtle,
          );
    final controlBorder = palette.isDark
        ? Colors.white24
        : Color.alphaBlend(
            palette.accent.withValues(alpha: 0.16),
            palette.divider,
          );
    final iconColor = palette.isDark ? Colors.white : palette.textPrimary;
    return Tooltip(
      message: sync.isSyncing
          ? 'Personal sync is running'
          : sync.pendingCount > 0
              ? 'Run personal sync now (${sync.pendingCount} pending)'
              : 'Run personal sync now',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: sync.isSyncing
              ? null
              : () => ref.read(syncControllerProvider.notifier).syncNow(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: controlBackground,
              border: Border.all(color: controlBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  sync.isOffline
                      ? Icons.cloud_off_outlined
                      : Icons.sync_outlined,
                  size: 18,
                  color: sync.isSyncing
                      ? (palette.isDark ? Colors.white54 : palette.textMuted)
                      : sync.isOffline
                        ? (palette.isDark
                          ? Colors.orange.shade200
                          : Colors.orange.shade700)
                        : iconColor,
                ),
                if (!sync.isSyncing && sync.pendingCount > 0)
                  Positioned(
                    right: -6,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: palette.isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : palette.selection,
                        border: Border.all(
                          color: palette.isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : palette.divider,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sync.pendingCount > 99
                            ? '99+'
                            : sync.pendingCount.toString(),
                        style: TextStyle(
                          fontSize: 9,
                          color: iconColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
  });

  final String tooltip;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          foregroundColor:
              palette.isDark ? Colors.white : palette.textPrimary,
          side: BorderSide(
            color: palette.isDark
                ? Colors.white24
                : Color.alphaBlend(
                    palette.accent.withValues(alpha: 0.16),
                    palette.divider,
                  ),
          ),
          backgroundColor: palette.isDark
              ? Colors.black.withValues(alpha: 0.12)
              : Color.alphaBlend(
                  palette.accent.withValues(alpha: 0.08),
                  palette.surfaceSubtle,
                ),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        icon: Icon(icon, size: 16),
        label: Text(label),
      ),
    );
  }
}

double _headerTitleWidth({
  required Iterable<String> labels,
  required double maxWidth,
}) {
  var maxLabelLength = 0;
  for (final label in labels) {
    if (label.length > maxLabelLength) {
      maxLabelLength = label.length;
    }
  }
  // icon(20) + gap(7) + text(chars * 10 for bold w900) + padding(18)
  final estimated = (20.0 + 7 + maxLabelLength * 10 + 18)
      .clamp(132.0, 360.0)
      .toDouble();
  final available = maxWidth * 0.35;
  if (available <= 0) {
    return estimated;
  }
  return estimated.clamp(132.0, available).toDouble();
}

class MediaLibraryNavStrip extends StatefulWidget {
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
  State<MediaLibraryNavStrip> createState() => _MediaLibraryNavStripState();
}

class _MediaLibraryNavStripState extends State<MediaLibraryNavStrip> {
  final _scrollController = ScrollController();
  bool _showLeft = false;
  bool _showRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrows() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final left = pos.pixels > 0;
    final right = pos.pixels < pos.maxScrollExtent - 1;
    if (left != _showLeft || right != _showRight) {
      setState(() {
        _showLeft = left;
        _showRight = right;
      });
    }
  }

  void _scrollBy(double delta) {
    final target =
        (_scrollController.offset + delta).clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(target,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && _scrollController.hasClients) {
          final delta = event.scrollDelta.dy != 0 ? event.scrollDelta.dy : event.scrollDelta.dx;
          _scrollBy(delta);
        }
      },
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              itemCount: widget.types.length,
              itemBuilder: (context, index) {
                final type = widget.types[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: MediaLibraryNavButton(
                    type: type,
                    color: libraryAccentForKind(type.kind),
                    icon: widget.registry.byKind(type.kind)?.workspace.icon ??
                        libraryIconForKind(type.kind),
                    selected: type.kind == widget.selectedKind,
                    count: widget.counts[type.kind]?.total ?? 0,
                    onPressed: () => widget.onSelected(type),
                    animationDuration: widget.animationDuration,
                  ),
                );
              },
            ),
          ),
        if (_showLeft)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ScrollArrowButton(
                icon: Icons.chevron_left,
                onTap: () => _scrollBy(-120),
              ),
            ),
          ),
        if (_showRight)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ScrollArrowButton(
                icon: Icons.chevron_right,
                onTap: () => _scrollBy(120),
              ),
            ),
          ),
      ],
      ),
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  const _ScrollArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 28,
        decoration: BoxDecoration(
          color: palette.isDark
              ? Colors.black.withValues(alpha: 0.45)
              : Color.alphaBlend(
                  palette.accent.withValues(alpha: 0.12),
                  palette.surfaceSubtle,
                ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: palette.isDark ? Colors.white : palette.textPrimary,
        ),
      ),
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
    final palette = appPalette(context);
    return Container(
      height: 6,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          brightness: palette.brightness,
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
                color: palette.isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : Color.alphaBlend(
                        accent.withValues(alpha: 0.14),
                        palette.surfaceSubtle,
                      ),
                child: Icon(
                  Icons.expand_more,
                  size: 6,
                  color: palette.isDark ? Colors.white70 : palette.textPrimary,
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
    final palette = appPalette(context);
    return Container(
      width: 10,
      decoration: BoxDecoration(
        gradient: libraryChromeGradient(
          accent,
          brightness: palette.brightness,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            message: 'Show library selector',
            child: InkWell(
              onTap: () => ref
                  .read(libraryNavPreferencesProvider.notifier)
                  .toggleCollapsed(),
              child: Container(
                width: 10,
                height: 36,
                color: palette.isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : Color.alphaBlend(
                        accent.withValues(alpha: 0.14),
                        palette.surfaceSubtle,
                      ),
                child: Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: palette.isDark ? Colors.white70 : palette.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
