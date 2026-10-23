import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/game_toy_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

typedef _Catalog = GameToyCatalogWorkspaceFields;
typedef _Personal = GameToyPersonalWorkspaceFields;

/// Text fields of the catalog, followed by those of the copy.
List<LibraryFieldDefinition<GameToyKind, GameToyWorkspaceDto, String?>>
    gameToyTextFields({required bool personal}) => [
          ..._Catalog.all,
          if (personal) ..._Personal.all,
        ];

/// The reference column chooser and sort menu category of [field].
String gameToyFieldCategory(
    LibraryFieldDefinition<GameToyKind, GameToyWorkspaceDto, Object?> field) {
  if ({
    _Catalog.frontImage,
    _Catalog.boxImage,
    _Catalog.hasFront,
    _Catalog.hasBoxImage
  }.contains(field)) {
    return 'Images';
  }
  if ({
    _Personal.value,
    _Personal.purchasePrice,
    _Personal.completeness,
    _Personal.condition,
    _Personal.purchaseDate,
    _Personal.purchaseMonth,
    _Personal.purchaseYear,
    _Personal.purchaseStore,
    _Personal.valueLocked,
    _Personal.box,
    _Personal.priceChartingId
  }.contains(field)) {
    return 'Value';
  }
  if ({_Catalog.toyType, _Catalog.toySubtype}.contains(field)) {
    return 'Toy';
  }
  return _Personal.all.contains(field) ? 'Personal' : 'Main';
}
