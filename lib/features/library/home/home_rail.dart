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

class MediaLibraryRail extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = selectedLibraryHomeType(types, selectedKind);
    final accent = libraryAccentForKind(selected.kind);
    final selectedIcon = registry.byKind(selected.kind)?.workspace.icon ??
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              right: BorderSide(
                color: Color.alphaBlend(
                  Colors.white.withValues(alpha: 0.14),
                  animatedAccent,
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
                    child: Icon(selectedIcon, color: Colors.white, size: 22),
                  ),
                ),
                const Divider(height: 1, color: kAppDivider),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final type = types[index];
                      final typeAccent = libraryAccentForKind(type.kind);
                      final selectedType = type.kind == selectedKind;
                      return Tooltip(
                        message: type.pluralLabel,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: selectedType ? null : () => onSelected(type),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: selectedType
                                    ? typeAccent.withValues(alpha: 0.34)
                                    : Colors.black.withValues(alpha: 0.20),
                                border: Border.all(
                                  color: selectedType
                                      ? Colors.white70
                                      : typeAccent,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SizedBox(
                                height: 48,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      registry
                                              .byKind(type.kind)
                                              ?.workspace
                                              .icon ??
                                          libraryIconForKind(type.kind),
                                      size: 19,
                                      color: selectedType
                                          ? Colors.white
                                          : typeAccent,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      (counts[type.kind]?.total ?? 0)
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
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
                    child: const SizedBox(
                      height: 36,
                      child: Center(
                        child: Icon(
                          Icons.chevron_left,
                          size: 18,
                          color: Colors.white,
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
                      ? Colors.white54
                      : sync.isOffline
                          ? Colors.orange.shade200
                          : Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sync.pendingCount > 99
                            ? '99+'
                            : sync.pendingCount.toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
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
