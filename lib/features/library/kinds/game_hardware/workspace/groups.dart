import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'dto.dart';

enum GameHardwareGroupingField {
  hasBox('has_box', 'Has Box', 'Images'),
  hasFront('has_front', 'Has Device', 'Images'),
  imageType('image_type', 'Image Type', 'Images'),
  releaseDate('release_date', 'Release Date', 'Main'),
  releaseMonth('release_month', 'Release Month', 'Main'),
  releaseYear('release_year', 'Release Year', 'Main'),
  series('series', 'Series', 'Main'),
  platform('platform', 'Platform', 'Main'),
  hardwareType('hardware_type', 'Hardware Type', 'Main'),
  completeness('completeness', 'Completeness', 'Value'),
  condition('condition', 'Condition', 'Value'),
  purchaseDate('purchase_date', 'Purchase Date', 'Value'),
  purchaseMonth('purchase_month', 'Purchase Month', 'Value'),
  purchaseStore('purchase_store', 'Purchase Store', 'Value'),
  purchaseYear('purchase_year', 'Purchase Year', 'Value'),
  valueLocked('value_locked', 'Value Locked', 'Value'),
  addedDate('added_date', 'Added Date', 'Personal'),
  addedMonth('added_month', 'Added Month', 'Personal'),
  addedYear('added_year', 'Added Year', 'Personal'),
  collectionStatus('collection_status', 'Collection Status', 'Personal'),
  location('location', 'Location', 'Personal'),
  modifiedDate('modified_date', 'Modified Date', 'Personal'),
  modifiedMonth('modified_month', 'Modified Month', 'Personal'),
  rating('rating', 'My Rating', 'Personal'),
  owner('owner', 'Owner', 'Personal'),
  tags('tags', 'Tags', 'Personal');

  const GameHardwareGroupingField(this.key, this.label, this.category);
  final String key;
  final String label;
  final String category;
  String get id => 'game_hardware.$key';
  bool get personal => category == 'Value' || category == 'Personal';
}

List<LibraryGroupDefinition<TKind, GameHardwareWorkspaceDto, Object?>>
    gameHardwareWorkspaceGroupDefinitions<TKind>(
            {required bool includePersonal}) =>
        [
          for (final field in GameHardwareGroupingField.values)
            if (includePersonal || !field.personal)
              LibraryGroupDefinition<TKind, GameHardwareWorkspaceDto, Object?>(
                id: LibraryGroupId(field.id,
                    semantic: field == GameHardwareGroupingField.location
                        ? LibraryGroupSemantic.location
                        : LibraryGroupSemantic.value),
                label: field.label,
                category: field.category,
                presentation: LibraryGroupPresentation.folderGrid,
                getValue: (context) => _groupValue(field, context),
              ),
        ];

Object? _groupValue(GameHardwareGroupingField field,
    LibraryProjectionContext<GameHardwareWorkspaceDto> context) {
  final metadata = context.dto.metadata;
  final entry = context.dto.entry;
  final personal = entry?.personal;
  final release = metadata.releaseDateParts;
  final purchase =
      personal?.purchaseDateParts ?? _parts(personal?.purchaseDate);
  final added = _parts(entry?.createdAt ?? context.addedAt);
  final modified = _parts(entry?.updatedAt);
  final imageTypes = gameHardwareWorkspaceImageTypes(context);
  return switch (field) {
    GameHardwareGroupingField.hasBox =>
      _yesNo(imageTypes.contains('back_cover')),
    GameHardwareGroupingField.hasFront =>
      _yesNo(imageTypes.contains('front_cover')),
    GameHardwareGroupingField.imageType => imageTypes
        .map((type) => switch (type) {
              'front_cover' => 'Device Image',
              'back_cover' => 'Box Image',
              _ => type
            })
        .toList(),
    GameHardwareGroupingField.releaseDate => release?.isoString,
    GameHardwareGroupingField.releaseMonth => _monthLabel(release),
    GameHardwareGroupingField.releaseYear => release?.year,
    GameHardwareGroupingField.series => metadata.seriesTitle,
    GameHardwareGroupingField.platform => metadata.platform,
    GameHardwareGroupingField.hardwareType => metadata.hardwareType,
    GameHardwareGroupingField.completeness =>
      personal?.details.completeness?.label,
    GameHardwareGroupingField.condition => personal?.condition,
    GameHardwareGroupingField.purchaseDate => purchase?.isoString,
    GameHardwareGroupingField.purchaseMonth => _monthLabel(purchase),
    GameHardwareGroupingField.purchaseStore => personal?.purchaseStore,
    GameHardwareGroupingField.purchaseYear => purchase?.year,
    GameHardwareGroupingField.valueLocked =>
      personal == null ? null : _yesNo(personal.details.valueIsLocked == true),
    GameHardwareGroupingField.addedDate => added?.isoString,
    GameHardwareGroupingField.addedMonth => _monthLabel(added),
    GameHardwareGroupingField.addedYear => added?.year,
    GameHardwareGroupingField.collectionStatus => personal == null
        ? null
        : libraryCollectionStatusFromValue(personal.collectionStatus).label,
    GameHardwareGroupingField.location => context.personal.locationPath,
    GameHardwareGroupingField.modifiedDate => modified?.isoString,
    GameHardwareGroupingField.modifiedMonth => _monthLabel(modified),
    GameHardwareGroupingField.rating => personal?.rating,
    GameHardwareGroupingField.owner => personal?.ownerLabel,
    GameHardwareGroupingField.tags => personal?.tags ?? const <String>[],
  };
}

Set<String> gameHardwareWorkspaceImageTypes(
        LibraryProjectionContext<GameHardwareWorkspaceDto> context) =>
    <String>{
      if (context.dto.metadata.coverImageUrl?.trim().isNotEmpty == true ||
          context.item.presentation?.imageUrl?.trim().isNotEmpty == true)
        'front_cover',
      for (final image in context.personal.images) _imageType(image.imageType),
      for (final type in context.personal.imageTypes) _imageType(type),
    };

String _imageType(String value) =>
    value.startsWith('personal:') ? value.substring('personal:'.length) : value;
PartialDate? _parts(DateTime? date) =>
    date == null ? null : PartialDate.fromDateTime(date);
String _yesNo(bool value) => value ? 'Yes' : 'No';
String? _monthLabel(PartialDate? date) {
  final month = date?.month;
  if (month == null) return null;
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return '${month.toString().padLeft(2, '0')} - ${names[month - 1]}';
}
