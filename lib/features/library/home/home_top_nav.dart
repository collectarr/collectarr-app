import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_nav_button.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';

import 'package:collectarr_app/ui/library_accent_scope.dart';
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
    final accentData = LibraryAccentScope.of(context);

    return AnimatedLibraryChromeGradient(
      accent: accentData.accent,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      borderBuilder: (animatedAccent, brightness) => Border(
        top: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
        bottom: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
      ),
      child: SizedBox(
        height: 36,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 4),
              child: _MediaLibraryOverdueActions(
                overdueLoanCount: overdueLoanCount,
                selectedOverdueLoanCount: selectedOverdueLoanCount,
                selectedLabel: selectedLabel,
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
              padding: const EdgeInsets.only(left: 4, right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LibraryTopNavSyncButton(),
                  const SizedBox(width: 4),
                  const _LibraryNavCollapseButton(),
                ],
              ),
            ),
          ],
        ),
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
  });

  final CatalogMediaType type;
  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;
  final LibraryTypeRegistry registry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentData = LibraryAccentScope.of(context);
    final palette = appPalette(context);
    final icon = registry.byKind(type.kind)?.workspace.icon ??
        libraryIconForKind(type.kind);
    return AnimatedLibraryChromeGradient(
      accent: accentData.accent,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      borderBuilder: (animatedAccent, brightness) => Border(
        top: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
        bottom: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
      ),
      child: SizedBox(
        height: 36,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final titleWidth = _headerTitleWidth(
              labels: [type.pluralLabel],
              maxWidth: constraints.maxWidth,
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: palette.divider)),
                    ),
                    child: SizedBox(
                      width: titleWidth,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _MediaLibraryTitle(
                          icon: icon,
                          label: type.pluralLabel,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MediaLibraryOverdueActions(
                        overdueLoanCount: overdueLoanCount,
                        selectedOverdueLoanCount: selectedOverdueLoanCount,
                        selectedLabel: selectedLabel,
                      ),
                      const SizedBox(width: 6),
                      const _LibraryTopNavSyncButton(),
                      const SizedBox(width: 4),
                      const _LibraryNavCollapseButton(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
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
    final titleColor = palette.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: 18, color: palette.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MediaLibraryOverdueActions extends StatelessWidget {
  const _MediaLibraryOverdueActions({
    required this.overdueLoanCount,
    required this.selectedOverdueLoanCount,
    required this.selectedLabel,
  });

  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => context.go(AppRoutes.loans),
            ),
          ],
        ],
      ),
    );
  }
}

class _LibraryNavCollapseButton extends ConsumerWidget {
  const _LibraryNavCollapseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navPrefs = ref.watch(libraryNavPreferencesProvider);
    final palette = appPalette(context);
    final iconColor = palette.isDark ? Colors.white : palette.textPrimary;
    return Tooltip(
      message: navPrefs.collapsed
          ? 'Show library selector'
          : 'Hide library selector',
      child: InkWell(
        onTap: () =>
            ref.read(libraryNavPreferencesProvider.notifier).toggleCollapsed(),
        child: SizedBox(
          width: 44,
          height: 36,
          child: Icon(
            navPrefs.collapsed ? Icons.expand_more : Icons.expand_less,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _LibraryTopNavSyncButton extends ConsumerWidget {
  const _LibraryTopNavSyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    return Tooltip(
      message: sync.isSyncing
          ? 'Personal sync is running'
          : sync.pendingCount > 0
              ? 'Run personal sync now (${sync.pendingCount} pending)'
              : 'Run personal sync now',
      child: SizedBox.square(
        dimension: kLibraryToolbarControlHeight,
        child: IconButton(
          onPressed: sync.isSyncing
              ? null
              : () => ref.read(syncControllerProvider.notifier).syncNow(),
          icon: Icon(
            sync.isOffline ? Icons.cloud_off_outlined : Icons.sync_outlined,
            size: 18,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: kLibraryToolbarControlHeight,
            height: kLibraryToolbarControlHeight,
          ),
          style: IconButton.styleFrom(
            foregroundColor: appPalette(context).textMuted,
            backgroundColor: appPalette(context).surface,
            side: BorderSide(color: appPalette(context).divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
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
            '$selectedOverdueLoanCount in $selectedLabel · Open Loans'
        : '$overdueLoanCount overdue loan${overdueLoanCount == 1 ? '' : 's'} · Open Loans';
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(3),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kAppOverdueBackground,
              borderRadius: BorderRadius.circular(3),
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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
  final estimated =
      (18.0 + 6 + maxLabelLength * 8.2 + 14).clamp(104.0, 240.0).toDouble();
  final available = maxWidth * 0.24;
  if (available <= 0) {
    return estimated;
  }
  return estimated.clamp(104.0, available).toDouble();
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
    final target = (_scrollController.offset + delta)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(target,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final groups = buildLibraryNavGroups(widget.types);
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && _scrollController.hasClients) {
          final delta = event.scrollDelta.dy != 0
              ? event.scrollDelta.dy
              : event.scrollDelta.dx;
          _scrollBy(delta);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: (constraints.maxWidth - 2)
                            .clamp(0.0, double.infinity),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var index = 0;
                                index < groups.length;
                                index += 1)
                              Builder(
                                builder: (context) {
                                  final group = groups[index];
                                  final representative = group.primaryType;
                                  final groupCount = group.types.fold<int>(
                                    0,
                                    (sum, type) =>
                                        sum +
                                        (widget.counts[type.kind]?.total ?? 0),
                                  );
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index == groups.length - 1 ? 0 : 1,
                                    ),
                                    child: MediaLibraryNavButton(
                                      type: representative,
                                      color: libraryAccentForKind(
                                        representative.kind,
                                      ),
                                      icon: widget.registry
                                              .byKind(representative.kind)
                                              ?.workspace
                                              .icon ??
                                          libraryIconForKind(
                                            representative.kind,
                                          ),
                                      label: group.label,
                                      tooltip: group.label,
                                      selected: group
                                          .containsKind(widget.selectedKind),
                                      count: groupCount,
                                      onPressed: () =>
                                          widget.onSelected(representative),
                                      animationDuration:
                                          widget.animationDuration,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
          );
        },
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
    final buttonBackground = palette.surface;
    final buttonForeground =
        ThemeData.estimateBrightnessForColor(buttonBackground) ==
                Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    return Semantics(
      button: true,
      label: icon == Icons.chevron_left ? 'Scroll left' : 'Scroll right',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 20,
          height: 28,
          decoration: BoxDecoration(
            color: buttonBackground,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.divider),
          ),
          child: Icon(
            icon,
            size: 16,
            color: buttonForeground,
          ),
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
    final accentData = LibraryAccentScope.of(context);
    final handleBackground = Color.alphaBlend(
      accentData.accent.withValues(alpha: 0.14),
      palette.surfaceSubtle.withValues(alpha: palette.isDark ? 0.9 : 1),
    );
    final handleForeground =
        ThemeData.estimateBrightnessForColor(handleBackground) ==
                Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    return AnimatedLibraryChromeGradient(
      accent: accentData.accent,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      child: SizedBox(
        height: 6,
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
                  color: handleBackground,
                  child: Icon(
                    Icons.expand_more,
                    size: 6,
                    color: handleForeground,
                  ),
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
    final accentData = LibraryAccentScope.of(context);
    final handleBackground = Color.alphaBlend(
      accentData.accent.withValues(alpha: 0.14),
      palette.surfaceSubtle.withValues(alpha: palette.isDark ? 0.9 : 1),
    );
    final handleForeground =
        ThemeData.estimateBrightnessForColor(handleBackground) ==
                Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    return AnimatedLibraryChromeGradient(
      accent: accentData.accent,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      child: SizedBox(
        width: 10,
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
                  color: handleBackground,
                  child: Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: handleForeground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
