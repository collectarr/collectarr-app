import 'package:collectarr_app/features/library/config/library_group_mode_category_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/groups.dart';

/// The reference folder menu: its categories, each in the reference order.
List<LibraryGroupModeCategory> buildComicGroupModeCategories(
  List<String> modes,
) =>
    [
      for (final category in comicGroupingCategories)
        if (ComicGroupingField.values.any(
            (field) => field.category == category && modes.contains(field.id)))
          LibraryGroupModeCategory(category, [
            for (final field in ComicGroupingField.values)
              if (field.category == category && modes.contains(field.id))
                field.id,
          ]),
    ];
