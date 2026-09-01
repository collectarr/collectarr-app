import 'package:collectarr_app/features/library/config/library_group_mode_category_models.dart';

List<LibraryGroupModeCategory> buildComicGroupModeCategories(
  List<String> modes,
) {
  String modeId(Object mode) {
    final normalized = mode.toString().contains('.')
        ? mode.toString().split('.').last
        : mode.toString();
    return normalized
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
  }

  const mainIds = {
    'series',
    'age_rating',
    'country',
    'crossover',
    'genre',
    'imprint',
    'language',
    'publisher',
    'release_date',
    'release_month',
    'release_year',
    'series_group',
    'story_arc',
  };
  const valueIds = {
    'grade',
    'condition',
    'is_key_comic',
    'raw_or_slabbed',
    'my_rating',
    'purchase_date',
    'purchase_month',
    'purchase_year',
    'purchase_store',
    'owner',
  };
  const editionIds = {
    'cover_date',
    'cover_month',
    'cover_year',
    'format',
  };
  const creatorsAndCharactersIds = {
    'creator',
    'artist',
    'character',
    'colorist',
    'cover_artist',
    'cover_colorist',
    'cover_inker',
    'cover_painter',
    'cover_penciller',
    'cover_separator',
    'editor',
    'editor_in_chief',
    'inker',
    'layouts',
    'letterer',
    'painter',
    'penciller',
    'plotter',
    'scripter',
    'separator',
    'translator',
    'writer',
  };
  final main = modes.where((mode) => mainIds.contains(modeId(mode))).toList();
  final value = modes.where((mode) => valueIds.contains(modeId(mode))).toList();
  final edition =
      modes.where((mode) => editionIds.contains(modeId(mode))).toList();
  final creatorsAndCharacters = modes
      .where((mode) => creatorsAndCharactersIds.contains(modeId(mode)))
      .toList();
  final personal = modes
      .where((mode) =>
          !mainIds.contains(modeId(mode)) &&
          !valueIds.contains(modeId(mode)) &&
          !editionIds.contains(modeId(mode)) &&
          !creatorsAndCharactersIds.contains(modeId(mode)))
      .toList();
  return [
    if (main.isNotEmpty) LibraryGroupModeCategory('Main', main),
    if (value.isNotEmpty) LibraryGroupModeCategory('Value', value),
    if (edition.isNotEmpty) LibraryGroupModeCategory('Edition', edition),
    if (creatorsAndCharacters.isNotEmpty)
      LibraryGroupModeCategory('Creators & Characters', creatorsAndCharacters),
    if (personal.isNotEmpty) LibraryGroupModeCategory('Personal', personal),
  ];
}
