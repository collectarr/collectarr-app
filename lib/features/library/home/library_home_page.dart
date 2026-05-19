import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_page.dart';
import 'package:collectarr_app/features/library/generic_library_page.dart';
import 'package:collectarr_app/features/library/home/library_home_catalog.dart';
import 'package:collectarr_app/features/library/home/library_home_counts.dart';
import 'package:collectarr_app/features/library/home/library_home_navigation.dart';
import 'package:collectarr_app/features/library/library_kind_style.dart';
import 'package:collectarr_app/features/library/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryHomePage extends ConsumerStatefulWidget {
  const LibraryHomePage({super.key});

  @override
  ConsumerState<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends ConsumerState<LibraryHomePage> {
  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final selectedKind = ref.watch(selectedLibraryKindProvider);
    final uiPreferences = ref.watch(uiPreferencesProvider);
    final animationDuration = uiPreferences.animationsEnabled
        ? const Duration(milliseconds: 320)
        : Duration.zero;
    final allTypes = orderedLibraryHomeTypes(catalog, navPreferences);
    final visibleTypes = visibleLibraryHomeTypes(allTypes, navPreferences);
    final selected = selectedLibraryHomeType(visibleTypes, selectedKind);
    final shelf = ref.watch(shelfProvider);
    final counts = shelf.maybeWhen(
      data: libraryCountsByKind,
      orElse: () => const <String, LibraryKindCount>{},
    );
    final registry = ref.watch(resolvedLibraryTypesProvider);
    final topBar = MediaLibraryNav(
      types: visibleTypes,
      counts: counts,
      registry: registry,
      selectedKind: selected.kind,
      animationDuration: animationDuration,
      onSelected: (type) =>
          ref.read(selectedLibraryKindProvider.notifier).state = type.kind,
    );
    final titleBar = MediaLibraryTitleBar(
      type: selected,
      registry: registry,
      animationDuration: animationDuration,
    );
    final selectedConfig = libraryConfigForCatalogType(selected, registry);
    final content = selected.kind == 'comic'
        ? ComicsPage(
            topBar: navPreferences.placement == LibraryNavPlacement.top
                ? topBar
                : titleBar,
          )
        : GenericLibraryPage(
            type: selectedConfig,
            topBar: navPreferences.placement == LibraryNavPlacement.top
                ? topBar
                : titleBar,
            accent: libraryAccentForKind(selected.kind),
          );

    if (navPreferences.placement == LibraryNavPlacement.left) {
      return Theme(
        data: kClzComicsTheme,
        child: Material(
          color: kClzCanvas,
          child: Row(
            children: [
              MediaLibraryRail(
                types: visibleTypes,
                counts: counts,
                registry: registry,
                selectedKind: selected.kind,
                onSelected: (type) => ref
                    .read(selectedLibraryKindProvider.notifier)
                    .state = type.kind,
              ),
              Expanded(child: content),
            ],
          ),
        ),
      );
    }

    return content;
  }
}
