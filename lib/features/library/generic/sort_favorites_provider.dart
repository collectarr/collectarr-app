import 'package:collectarr_app/features/library/generic/sort_preset_store.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final librarySavedSortFavoritesProvider =
    FutureProvider.family<List<LibrarySortFavorite>, LibraryKindRegistration>(
        (ref, type) async => [
              for (final preset in (await LibrarySortPresetStore(type).read())
                  .where((preset) => preset.id != null))
                LibrarySortFavorite(
                  id: preset.id!,
                  label: preset.label,
                  icon: AppIcons.sortAlpha,
                  rules: preset.rules,
                ),
            ]);
