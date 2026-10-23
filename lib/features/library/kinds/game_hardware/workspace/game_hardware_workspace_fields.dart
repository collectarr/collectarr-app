import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

typedef _Catalog = GameHardwareCatalogWorkspaceFields;
typedef _Personal = GameHardwarePersonalWorkspaceFields;

/// Text fields of the catalog, followed by those of the copy.
List<
    LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto,
        String?>> gameHardwareTextFields({required bool personal}) => [
      ..._Catalog.all,
      if (personal) ..._Personal.all,
    ];

/// The reference column chooser and sort menu category of [field].
String gameHardwareFieldCategory(
    LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, Object?>
        field) {
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
    _Personal.priceChartingId,
    _Personal.manual
  }.contains(field)) {
    return 'Value';
  }
  if ({_Catalog.hardwareType, _Personal.serialNumber}.contains(field)) {
    return 'Hardware';
  }
  return _Personal.all.contains(field) ? 'Personal' : 'Main';
}
