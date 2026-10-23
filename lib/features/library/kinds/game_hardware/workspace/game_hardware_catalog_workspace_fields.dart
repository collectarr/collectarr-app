import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_ids.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_groups.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class GameHardwareCatalogWorkspaceFields {
  static final title =
      _text('title', 'Title', (dto) => dto.metadata.title, groupable: false);
  static final sortTitle = _text('sort_title', 'Sort Title',
      (dto) => dto.metadata.sortKey ?? dto.metadata.title,
      groupable: false);
  static final barcode = _text(
      'barcode', 'Barcode', (dto) => dto.metadata.barcode,
      groupable: false);
  static final releaseDate = _text('release_date', 'Release Date',
      (dto) => dto.metadata.releaseDateParts?.isoString);
  static final releaseMonth = _text('release_month', 'Release Month',
      (dto) => dto.metadata.releaseDateParts?.month?.toString().padLeft(2, '0'),
      source: LibraryFieldSource.derived);
  static final releaseYear = _text('release_year', 'Release Year',
      (dto) => dto.metadata.releaseDateParts?.year?.toString(),
      source: LibraryFieldSource.derived);
  static final series =
      _text('series', 'Series', (dto) => dto.metadata.seriesTitle);
  static final platform =
      _text('platform', 'Platform', (dto) => dto.metadata.platform);
  static final hardwareType = _text(
      'hardware_type', 'Hardware Type', (dto) => dto.metadata.hardwareType);

  static final platformIcon = LibraryFieldDefinition<GameHardwareKind,
      GameHardwareWorkspaceDto, String?>(
    id: const LibraryFieldId('game_hardware.platform_icon'),
    metadata: const LibraryKindFieldMetadata(
        id: 'game_hardware.platform_icon',
        label: 'Platform Icon',
        valueType: LibraryFieldValueType.text,
        cardinality: LibraryFieldCardinality.one,
        source: LibraryFieldSource.derived,
        sourcePath: 'platform'),
    getValue: (context) => context.dto.metadata.platform,
  );

  static final frontImage =
      _imageField('front_image', 'Device Image', 'front_cover');
  static final boxImage = _imageField('box_image', 'Box Image', 'back_cover');
  static final hasFront = _imageFlag('has_front', 'Has Device', 'front_cover');
  static final hasBoxImage = _imageFlag('has_box', 'Has Box', 'back_cover');

  /// Text fields listed in the column chooser and sort menu.
  static final all = [
    hasFront,
    hasBoxImage,
    title,
    sortTitle,
    barcode,
    releaseDate,
    releaseMonth,
    releaseYear,
    series,
    platform,
    hardwareType,
  ];
}

LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, String?>
    _text(String key, String label,
            String? Function(GameHardwareWorkspaceDto dto) getValue,
            {LibraryFieldSource source = LibraryFieldSource.catalog,
            bool groupable = true}) =>
        keyedTextField('game_hardware', key, label, getValue,
            source: source, groupable: groupable);

LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, String?>
    _imageField(String key, String label, String imageType) =>
        LibraryFieldDefinition(
          id: LibraryFieldId('game_hardware.$key'),
          metadata: LibraryKindFieldMetadata(
              id: 'game_hardware.$key',
              label: label,
              valueType: LibraryFieldValueType.text,
              cardinality: LibraryFieldCardinality.one,
              source: LibraryFieldSource.derived,
              sourcePath: 'images.$imageType'),
          getValue: (context) => imageType == 'front_cover'
              ? context.dto.metadata.coverImageUrl
              : null,
        );

LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, String?>
    _imageFlag(String key, String label, String imageType) =>
        LibraryFieldDefinition(
          id: LibraryFieldId('game_hardware.$key'),
          metadata: LibraryKindFieldMetadata(
              id: 'game_hardware.$key',
              label: label,
              valueType: LibraryFieldValueType.text,
              cardinality: LibraryFieldCardinality.one,
              source: LibraryFieldSource.derived,
              sourcePath: 'images.$imageType',
              sortable: true,
              groupable: true),
          getValue: (context) =>
              gameHardwareWorkspaceImageTypes(context).contains(imageType)
                  ? 'Yes'
                  : 'No',
        );
