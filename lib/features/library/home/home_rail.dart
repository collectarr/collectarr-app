import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaLibraryRail extends ConsumerStatefulWidget {
  const MediaLibraryRail({
    super.key,
    required this.types,
    required this.counts,
    required this.registry,
    required this.selectedKind,
    required this.onSelected,
  });

  final List<CatalogMediaType> types;
  final Map<String, LibraryKindCount> counts;
  final LibraryTypeRegistry registry;
  final String selectedKind;
  final ValueChanged<CatalogMediaType> onSelected;

  @override
  ConsumerState<MediaLibraryRail> createState() => _MediaLibraryRailState();
}

class _MediaLibraryRailState extends ConsumerState<MediaLibraryRail> {
  final _scrollController = ScrollController();
  bool _showUp = false;
  bool _showDown = false;

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
    final up = pos.pixels > 0;
    final down = pos.pixels < pos.maxScrollExtent - 1;
    if (up != _showUp || down != _showDown) {
      setState(() {
        _showUp = up;
        _showDown = down;
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
    final selected = selectedLibraryHomeType(widget.types, widget.selectedKind);
    final accent = libraryAccentForKind(selected.kind);
    final palette = appPalette(context);
    final selectedIcon = widget.registry.byKind(selected.kind)?.workspace.icon ??
        libraryIconForKind(selected.kind);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accent),
      duration: kAppAnimNormal,
      curve: Curves.easeOutCubic,
      builder: (context, color, _) {
        final animatedAccent = color ?? accent;
        return Container(
          width: 78,
          decoration: BoxDecoration(
            gradient: libraryChromeGradient(
              animatedAccent,
              brightness: palette.brightness,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              right: BorderSide(
                color: libraryChromeBorderColor(
                  animatedAccent,
                  brightness: palette.brightness,
                ),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 42,
                  child: Center(
                    child: Icon(
                      selectedIcon,
                      color: palette.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
                const Divider(height: 1, color: kAppDivider),
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: widget.types.length,
                        itemBuilder: (context, index) {
                          final type = widget.types[index];
                          final typeAccent = libraryAccentForKind(type.kind);
                          final selectedType = type.kind == widget.selectedKind;
                          final tileFill = selectedType
                            ? (palette.isDark
                              ? typeAccent.withValues(alpha: 0.34)
                              : Color.alphaBlend(
                                typeAccent.withValues(alpha: 0.16),
                                palette.surfaceSubtle,
                              ))
                            : (palette.isDark
                              ? Colors.black.withValues(alpha: 0.20)
                              : Color.alphaBlend(
                                typeAccent.withValues(alpha: 0.04),
                                palette.surfaceSubtle,
                              ));
                          final selectedTileForeground =
                            ThemeData.estimateBrightnessForColor(tileFill) ==
                                Brightness.dark
                              ? Colors.white
                              : palette.textPrimary;
                          final unselectedTileForeground =
                            ThemeData.estimateBrightnessForColor(tileFill) ==
                                Brightness.dark
                              ? Colors.white
                              : palette.textPrimary;
                      return Tooltip(
                        message: type.pluralLabel,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: selectedType ? null : () => widget.onSelected(type),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: tileFill,
                                border: Border.all(
                                  color: selectedType
                                      ? selectedTileForeground.withValues(alpha: 0.72)
                                      : (palette.isDark
                                          ? typeAccent
                                          : Color.alphaBlend(
                                              typeAccent.withValues(alpha: 0.28),
                                              palette.divider,
                                            )),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SizedBox(
                                height: 48,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.registry
                                              .byKind(type.kind)
                                              ?.workspace
                                              .icon ??
                                          libraryIconForKind(type.kind),
                                      size: 19,
                                      color: selectedType
                                          ? selectedTileForeground
                                          : typeAccent,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (widget.counts[type.kind]?.total ?? 0)
                                          .toString(),
                                      style: TextStyle(
                                        color: selectedType
                                            ? selectedTileForeground
                                            : unselectedTileForeground,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_showUp)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _scrollBy(-120),
                          child: Builder(
                            builder: (context) {
                              final buttonBackground = Color.alphaBlend(
                                animatedAccent.withValues(alpha: 0.12),
                                palette.surfaceSubtle.withValues(
                                  alpha: palette.isDark ? 0.9 : 1,
                                ),
                              );
                              final buttonForeground =
                                  ThemeData.estimateBrightnessForColor(
                                            buttonBackground,
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : palette.textPrimary;
                              return Container(
                            width: 28,
                            height: 18,
                            decoration: BoxDecoration(
                              color: buttonBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.expand_less,
                              size: 16,
                              color: buttonForeground,
                            ),
                          );
                            },
                          ),
                        ),
                      ),
                    ),
                  if (_showDown)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => _scrollBy(120),
                          child: Builder(
                            builder: (context) {
                              final buttonBackground = Color.alphaBlend(
                                animatedAccent.withValues(alpha: 0.12),
                                palette.surfaceSubtle.withValues(
                                  alpha: palette.isDark ? 0.9 : 1,
                                ),
                              );
                              final buttonForeground =
                                  ThemeData.estimateBrightnessForColor(
                                            buttonBackground,
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : palette.textPrimary;
                              return Container(
                            width: 28,
                            height: 18,
                            decoration: BoxDecoration(
                              color: buttonBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.expand_more,
                              size: 16,
                              color: buttonForeground,
                            ),
                          );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
                const Divider(height: 1, color: kAppDivider),
                const _RailSyncButton(),
                const Divider(height: 1, color: kAppDivider),
                Tooltip(
                  message: 'Collapse library selector',
                  child: InkWell(
                    onTap: () => ref
                        .read(libraryNavPreferencesProvider.notifier)
                        .toggleCollapsed(),
                    child: SizedBox(
                      height: 36,
                      child: Center(
                        child: Icon(
                          Icons.chevron_left,
                          size: 18,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RailSyncButton extends ConsumerWidget {
  const _RailSyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    final palette = appPalette(context);
    final pendingBadgeBackground = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.18 : 0.12),
      palette.selection,
    );
    final pendingBadgeBorder = Color.alphaBlend(
      palette.accent.withValues(alpha: palette.isDark ? 0.2 : 0.12),
      palette.divider,
    );
    final pendingBadgeForeground =
        ThemeData.estimateBrightnessForColor(pendingBadgeBackground) ==
                Brightness.dark
            ? Colors.white
            : palette.textPrimary;
    return Tooltip(
      message: sync.isSyncing
          ? 'Personal sync is running'
          : sync.pendingCount > 0
              ? 'Run personal sync now (${sync.pendingCount} pending)'
              : 'Run personal sync now',
      child: InkWell(
        onTap: sync.isSyncing
            ? null
            : () => ref.read(syncControllerProvider.notifier).syncNow(),
        child: SizedBox(
          height: 36,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  sync.isOffline ? Icons.cloud_off_outlined : Icons.sync_outlined,
                  size: 18,
                  color: sync.isSyncing
                    ? palette.textMuted
                      : sync.isOffline
                      ? (palette.isDark
                        ? Colors.orange.shade200
                        : Colors.orange.shade700)
                      : palette.textPrimary,
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
                        color: pendingBadgeBackground,
                        border: Border.all(
                          color: pendingBadgeBorder,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sync.pendingCount > 99
                            ? '99+'
                            : sync.pendingCount.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: pendingBadgeForeground,
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
