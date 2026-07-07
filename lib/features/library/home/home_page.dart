import 'dart:async';

import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/core/utils/image_url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/home/home_rail.dart';
import 'package:collectarr_app/features/library/home/library_switch_transition.dart';
import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_pages.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot_provider.dart';
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
  String? _lastPrewarmedKind;
  LibraryLayoutSnapshot? _switchLayoutSnapshot;
  Timer? _switchLayoutSnapshotReset;

  String? _routeKind() {
    return canonicalLibraryNavKind(widget.routeUri.queryParameters['kind']);
  }

  void _replaceLibraryKind(String kind) {
    final normalized = canonicalLibraryNavKind(kind) ?? 'comic';
    final previousKind = ref.read(selectedLibraryKindProvider);
    if (previousKind != normalized) {
      _switchLayoutSnapshotReset?.cancel();
      _switchLayoutSnapshot = ref.read(libraryLayoutSnapshotProvider);
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
    final animationDuration = ref.read(uiPreferencesProvider).animationsEnabled
        ? kAppAnimNormal
        : Duration.zero;
    if (animationDuration == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _switchLayoutSnapshot = null;
        });
      });
      return;
    }
    _switchLayoutSnapshotReset = Timer(animationDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _switchLayoutSnapshot = null;
      });
    });
  }

  void _recordSwitchMetrics({
    required String previousKind,
    required String nextKind,
  }) {}

  @override
  void dispose() {
    _switchLayoutSnapshotReset?.cancel();
    super.dispose();
  }

  void _requestCoverPrewarm(
    BuildContext context,
    ShelfState shelfState,
    String kind, {
    int maxUrls = 32,
  }) {
    if (!mounted ||
        ref.read(uiPreferencesProvider).animationsEnabled == false ||
        _lastPrewarmedKind == kind) {
      return;
    }
    final urls = _firstCoverUrlsForKind(
      shelfState,
      kind,
      maxUrls: maxUrls,
    );
    if (urls.isEmpty) {
      return;
    }
    _lastPrewarmedKind = kind;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      for (final url in urls) {
        unawaited(
          precacheImage(
            CachedNetworkImageProvider(url),
            context,
          ),
        );
      }
    });
  }

  List<String> _firstCoverUrlsForKind(
    ShelfState shelfState,
    String kind, {
    int maxUrls = 32,
  }) {
    final urls = <String>[];
    final seen = <String>{};
    for (final entry in shelfState.entries) {
      final catalogItem = entry.catalogItem;
      if (catalogItem == null || catalogItem.kind != kind) {
        continue;
      }
      final candidates = [
        normalizeNetworkImageUrl(catalogItem.coverImageUrl),
        normalizeNetworkImageUrl(catalogItem.thumbnailImageUrl),
      ];
      for (final url in candidates.whereType<String>()) {
        if (url.isEmpty || !seen.add(url)) {
          continue;
        }
        urls.add(url);
        if (urls.length >= maxUrls) {
          return urls;
        }
      }
    }
    return urls;
  }

  Widget _buildCachedKindBody({
    required CatalogMediaType selected,
    required LibraryTypeConfig selectedConfig,
    required Widget resolvedTopBar,
    required Color accent,
    required Uri routeUri,
    required List<CatalogMediaType> visibleTypes,
    required Duration animationDuration,
    required LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    _cachedKindPages[selected.kind] = KeyedSubtree(
      key: ValueKey('library-kind-${selected.kind}'),
      child: buildLibraryKindPage(
        type: selectedConfig,
        topBar: resolvedTopBar,
        accent: accent,
        routeUri: routeUri,
        switchLayoutSnapshot: switchLayoutSnapshot,
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

    return LibrarySwitchTransition(
      duration: animationDuration,
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
    final shelfState = ref.watch(shelfProvider);
    final loadedShelf = shelfState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
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
    if (loadedShelf != null && uiPreferences.animationsEnabled) {
      _requestCoverPrewarm(context, loadedShelf, selected.kind);
    }
    final Widget resolvedTopBar;
    if (navPreferences.placement == LibraryNavPlacement.top) {
      resolvedTopBar = collapsed
          ? _CoverPrewarmTrigger(
              onIntent: loadedShelf == null
                  ? null
                  : () => _requestCoverPrewarm(
                        context,
                        loadedShelf,
                        selected.kind,
                      ),
              child: MediaLibraryCollapsedStrip(accent: accent),
            )
          : _CoverPrewarmTrigger(
              onIntent: loadedShelf == null
                  ? null
                  : () => _requestCoverPrewarm(
                        context,
                        loadedShelf,
                        selected.kind,
                      ),
              child: topBar,
            );
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
            switchLayoutSnapshot: _switchLayoutSnapshot,
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
              _CoverPrewarmTrigger(
                onIntent: loadedShelf == null
                    ? null
                    : () => _requestCoverPrewarm(
                          context,
                          loadedShelf,
                          selected.kind,
                        ),
                child: MediaLibraryCollapsedRailStrip(accent: accent),
              )
            else
              _CoverPrewarmTrigger(
                onIntent: loadedShelf == null
                    ? null
                    : () => _requestCoverPrewarm(
                          context,
                          loadedShelf,
                          selected.kind,
                        ),
                child: MediaLibraryRail(
                  types: visibleTypes,
                  counts: counts,
                  registry: registry,
                  selectedKind: selected.kind,
                  onSelected: (type) => _replaceLibraryKind(type.kind),
                ),
              ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return content;
  }
}

class _CoverPrewarmTrigger extends StatelessWidget {
  const _CoverPrewarmTrigger({
    required this.child,
    this.onIntent,
  });

  final Widget child;
  final VoidCallback? onIntent;

  @override
  Widget build(BuildContext context) {
    if (onIntent == null) {
      return child;
    }
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          onIntent!();
        }
      },
      child: MouseRegion(
        onEnter: (_) => onIntent!(),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => onIntent!(),
          child: child,
        ),
      ),
    );
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
