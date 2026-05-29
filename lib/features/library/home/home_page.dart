import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/generic/page.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_counts.dart';
import 'package:collectarr_app/features/library/home/home_rail.dart';
import 'package:collectarr_app/features/library/home/home_top_nav.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LibraryHomePage extends ConsumerStatefulWidget {
  const LibraryHomePage({super.key, required this.routeUri});

  final Uri routeUri;

  @override
  ConsumerState<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends ConsumerState<LibraryHomePage> {
  String? _routeKind() {
    final rawKind = widget.routeUri.queryParameters['kind'];
    final normalized = rawKind?.trim().toLowerCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  void _replaceLibraryKind(String kind) {
    final normalized = kind.trim().toLowerCase();
    ref.read(selectedLibraryKindProvider.notifier).select(normalized);
    final nextUri = widget.routeUri.replace(
      queryParameters: {'kind': normalized},
    );
    if (nextUri.toString() != widget.routeUri.toString()) {
      context.replace(nextUri.toString());
    }
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
    final animationDuration = uiPreferences.animationsEnabled
        ? kAppAnimNormal
        : Duration.zero;
    final allTypes = orderedLibraryHomeTypes(catalog, navPreferences);
    final visibleTypes = visibleLibraryHomeTypes(allTypes, navPreferences);
    final routeKind = _routeKind();
    final routeSelected = routeKind == null
        ? null
        : visibleTypes.where((type) => type.kind == routeKind).firstOrNull;
    final selected = routeSelected ??
        selectedLibraryHomeType(visibleTypes, selectedKind);
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
    final overdueLoanOwnedItemIds = ref.watch(overdueLoanOwnedItemIdsProvider)
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
                Icon(Icons.cloud_off, size: 14, color: appPalette(context).textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Using offline catalog — server unreachable',
                    style: TextStyle(fontSize: 12, color: appPalette(context).textSecondary),
                  ),
                ),
              ],
            ),
          )
        : null;
    final collapsed = navPreferences.collapsed;
    final accent = libraryAccentForKind(selected.kind);
    final Widget resolvedTopBar;
    if (navPreferences.placement == LibraryNavPlacement.top) {
      resolvedTopBar = collapsed
          ? MediaLibraryCollapsedStrip(accent: accent)
          : topBar;
    } else {
      // Left-rail mode owns the whole library chrome, so no top bar.
      resolvedTopBar = const SizedBox.shrink();
    }
    final content = Column(
      children: [
        if (offlineBanner != null) offlineBanner,
        Expanded(
          child: LibraryPage(
            type: selectedConfig,
            topBar: resolvedTopBar,
            accent: accent,
            routeUri: widget.routeUri,
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
