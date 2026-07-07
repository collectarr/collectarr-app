import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/home/home_rail.dart';
import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_pages.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

class LibraryHomePage extends ConsumerStatefulWidget {
  const LibraryHomePage({super.key, required this.routeUri});

  final Uri routeUri;

  @override
  ConsumerState<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends ConsumerState<LibraryHomePage> {
  final Map<String, Widget> _cachedKindPages = <String, Widget>{};
  final List<String> _cachedKindOrder = <String>[];

  String? _routeKind() {
    return canonicalLibraryNavKind(widget.routeUri.queryParameters['kind']);
  }

  void _replaceLibraryKind(String kind) {
    final normalized = canonicalLibraryNavKind(kind) ?? 'comic';
    final previousKind = ref.read(selectedLibraryKindProvider);
    if (previousKind != normalized) {
      _recordSwitchMetrics(previousKind: previousKind, nextKind: normalized);
    }
    ref.read(selectedLibraryKindProvider.notifier).select(normalized);
    final nextUri = widget.routeUri.replace(
      queryParameters: {'kind': normalized},
    );
    if (nextUri.toString() != widget.routeUri.toString() &&
        GoRouter.maybeOf(context) != null) {
      context.replace(nextUri.toString());
    }
  }

  void _recordSwitchMetrics({
    required String previousKind,
    required String nextKind,
  }) {}

  Widget _buildCachedKindBody({
    required CatalogMediaType selected,
    required LibraryTypeConfig selectedConfig,
    required Widget resolvedTopBar,
    required Color accent,
    required Uri routeUri,
    required List<CatalogMediaType> visibleTypes,
    required Duration animationDuration,
  }) {
    _cachedKindPages[selected.kind] = KeyedSubtree(
      key: ValueKey('library-kind-${selected.kind}'),
      child: buildLibraryKindPage(
        type: selectedConfig,
        topBar: resolvedTopBar,
        accent: accent,
        routeUri: routeUri,
      ),
    );

    _cachedKindOrder.remove(selected.kind);
    _cachedKindOrder.add(selected.kind);

    final visibleKindOrder = <String>{
      for (final type in visibleTypes) type.kind,
    };
    _cachedKindPages.removeWhere((kind, _) => !visibleKindOrder.contains(kind));

    _cachedKindOrder.removeWhere((kind) => !visibleKindOrder.contains(kind));

    const maxCachedKinds = 4;
    while (_cachedKindOrder.length > maxCachedKinds) {
      final removeIndex = _cachedKindOrder.indexWhere(
        (kind) => kind != selected.kind,
      );
      if (removeIndex < 0) {
        break;
      }
      final evictedKind = _cachedKindOrder.removeAt(removeIndex);
      _cachedKindPages.remove(evictedKind);
    }

    final cachedKinds = [
      for (final kind in _cachedKindOrder)
        if (_cachedKindPages.containsKey(kind)) kind,
    ];
    final selectedIndex = cachedKinds.indexOf(selected.kind);
    if (selectedIndex < 0) {
      return const SizedBox.shrink();
    }

    final stack = IndexedStack(
      index: selectedIndex,
      children: [
        for (final kind in cachedKinds)
          TickerMode(
            enabled: kind == selected.kind,
            child: RepaintBoundary(child: _cachedKindPages[kind]!),
          ),
      ],
    );

    if (animationDuration == Duration.zero) {
      return stack;
    }

    return AnimatedSwitcher(
      duration: animationDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.02, 0.01),
          end: Offset.zero,
        ).animate(animation);
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey('library-kind-stack-${selected.kind}'),
        child: stack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(mediaCatalogProvider);
    final catalog = catalogState.maybeWhen(
      data: (value) => value,
      orElse: () => fallbackMediaCatalog,
    );
    final isCatalogOffline = catalogState.hasError;
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final selectedKind = ref.watch(selectedLibraryKindProvider);
    final uiPreferences = ref.watch(uiPreferencesProvider);
    final animationDuration =
        uiPreferences.animationsEnabled ? kAppAnimNormal : Duration.zero;
    final allTypes = orderedLibraryHomeTypes(catalog, navPreferences);
    final visibleTypes = _ensureCoreKindsVisible(
      visibleLibraryHomeTypes(allTypes, navPreferences),
      allTypes,
    );
    final rawRouteKind =
        widget.routeUri.queryParameters['kind']?.trim().toLowerCase();
    final routeKind = _routeKind();
    final routeSelected = routeKind == null
        ? null
        : visibleTypes.where((type) => type.kind == routeKind).firstOrNull;
    final selected =
        routeSelected ?? selectedLibraryHomeType(visibleTypes, selectedKind);
    if (routeKind != null && rawRouteKind != routeKind) {
      final normalizedRouteKind = routeKind;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _replaceLibraryKind(normalizedRouteKind);
      });
    }
    if (selected.kind != selectedKind) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final currentKind = ref.read(selectedLibraryKindProvider);
        if (currentKind != selected.kind) {
          ref.read(selectedLibraryKindProvider.notifier).select(selected.kind);
        }
      });
    }
    final counts = ref.watch(shelfProvider.select((shelf) => shelf.maybeWhen(
          data: libraryCountsByKind,
          orElse: () => const <String, LibraryKindCount>{},
        )));
    final overdueLoanOwnedItemIds = ref
        .watch(overdueLoanOwnedItemIdsProvider)
        .maybeWhen(data: (value) => value, orElse: () => const <String>{});
    final shelfForOverdue = ref.watch(shelfProvider);
    final overdueCounts = shelfForOverdue.maybeWhen(
      data: (value) => overdueLoanCountsByKind(value, overdueLoanOwnedItemIds),
      orElse: () => const <String, int>{},
    );
    final overdueLoanCount = overdueLoanOwnedItemIds.length;
    final selectedOverdueLoanCount = overdueCounts[selected.kind] ?? 0;
    final registry = ref.watch(resolvedLibraryTypesProvider);
    final topBar = MediaLibraryNav(
      types: visibleTypes,
      counts: counts,
      overdueLoanCount: overdueLoanCount,
      selectedOverdueLoanCount: selectedOverdueLoanCount,
      selectedLabel: selected.pluralLabel,
      registry: registry,
      selectedKind: selected.kind,
      animationDuration: animationDuration,
      onSelected: (type) => _replaceLibraryKind(type.kind),
    );
    final selectedConfig = libraryConfigForCatalogType(selected, registry);
    final offlineBanner = isCatalogOffline
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: kAppSurfaceSubtle,
            child: Row(
              children: [
                Icon(Icons.cloud_off,
                    size: 14, color: appPalette(context).textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Using offline catalog — server unreachable',
                    style: TextStyle(
                        fontSize: 12, color: appPalette(context).textSecondary),
                  ),
                ),
              ],
            ),
          )
        : null;
    final collapsed = navPreferences.collapsed;
    final accent = LibraryAccentScope.of(context).accent;
    final Widget resolvedTopBar;
    if (navPreferences.placement == LibraryNavPlacement.top) {
      resolvedTopBar =
          collapsed ? MediaLibraryCollapsedStrip(accent: accent) : topBar;
    } else {
      // Left-rail mode owns the whole library chrome, so no top bar.
      resolvedTopBar = const SizedBox.shrink();
    }
    final content = Column(
      children: [
        if (offlineBanner != null) offlineBanner,
        Expanded(
          child: _buildCachedKindBody(
            selected: selected,
            selectedConfig: selectedConfig,
            resolvedTopBar: resolvedTopBar,
            accent: accent,
            routeUri: widget.routeUri,
            visibleTypes: visibleTypes,
            animationDuration: animationDuration,
          ),
        ),
      ],
    );

    if (navPreferences.placement == LibraryNavPlacement.left) {
      return Material(
        color: appPalette(context).canvas,
        child: Row(
          children: [
            if (collapsed)
              MediaLibraryCollapsedRailStrip(accent: accent)
            else
              MediaLibraryRail(
                types: visibleTypes,
                counts: counts,
                registry: registry,
                selectedKind: selected.kind,
                onSelected: (type) => _replaceLibraryKind(type.kind),
              ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return content;
  }
}

List<CatalogMediaType> _ensureCoreKindsVisible(
  List<CatalogMediaType> visible,
  List<CatalogMediaType> available,
) {
  const requiredKinds = {'anime', 'manga', 'tv'};
  final result = visible.toList(growable: true);
  final visibleKinds = {for (final type in result) type.kind};
  for (final kind in requiredKinds) {
    if (visibleKinds.contains(kind)) {
      continue;
    }
    for (final type in available) {
      if (type.kind == kind) {
        result.add(type);
        visibleKinds.add(kind);
        break;
      }
    }
  }
  return result;
}
