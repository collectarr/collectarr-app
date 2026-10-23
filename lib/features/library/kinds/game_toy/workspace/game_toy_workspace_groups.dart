import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'game_toy_workspace_dto.dart';

enum GameToyGroupingField {
  hasBox('has_box', 'Has Box', 'Images'),
  hasFront('has_front', 'Has Figure', 'Images'),
  imageType('image_type', 'Image Type', 'Images'),
  releaseDate('release_date', 'Release Date', 'Main'),
  releaseMonth('release_month', 'Release Month', 'Main'),
  releaseYear('release_year', 'Release Year', 'Main'),
  series('series', 'Series', 'Main'),
  toySubtype('toy_subtype', 'Subtype', 'Toy'),
  toyType('toy_type', 'Type', 'Toy'),
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

  const GameToyGroupingField(this.key, this.label, this.category);
  final String key;
  final String label;
  final String category;
  String get id => 'game_toy.$key';
  bool get personal => category == 'Value' || category == 'Personal';
}

List<LibraryGroupDefinition<TKind, GameToyWorkspaceDto, Object?>>
    gameToyWorkspaceGroupDefinitions<TKind>({required bool includePersonal}) =>
        [
          for (final field in GameToyGroupingField.values)
            if (includePersonal || !field.personal)
              LibraryGroupDefinition<TKind, GameToyWorkspaceDto, Object?>(
                id: LibraryGroupId(field.id,
                    semantic: field == GameToyGroupingField.location
                        ? LibraryGroupSemantic.location
                        : LibraryGroupSemantic.value),
                label: field.label,
                category: field.category,
                presentation: LibraryGroupPresentation.folderGrid,
                getValue: (context) => _groupValue(field, context),
              ),
        ];

Object? _groupValue(GameToyGroupingField field,
    LibraryProjectionContext<GameToyWorkspaceDto> context) {
  final metadata = context.dto.metadata;
  final entry = context.dto.entry;
  final personal = entry?.personal;
  final release = metadata.releaseDateParts;
  final purchase =
      personal?.purchaseDateParts ?? _parts(personal?.purchaseDate);
  final added = _parts(entry?.createdAt ?? context.addedAt);
  final modified = _parts(entry?.updatedAt);
  final imageTypes = gameToyWorkspaceImageTypes(context);
  return switch (field) {
    GameToyGroupingField.hasBox => _yesNo(imageTypes.contains('back_cover')),
    GameToyGroupingField.hasFront => _yesNo(imageTypes.contains('front_cover')),
    GameToyGroupingField.imageType => imageTypes
        .map((type) => switch (type) {
              'front_cover' => 'Figure Image',
              'back_cover' => 'Box Image',
              _ => type
            })
        .toList(),
    GameToyGroupingField.releaseDate => release?.isoString,
    GameToyGroupingField.releaseMonth => _monthLabel(release),
    GameToyGroupingField.releaseYear => release?.year,
    GameToyGroupingField.series => metadata.seriesTitle,
    GameToyGroupingField.toySubtype => metadata.toySubtype,
    GameToyGroupingField.toyType => metadata.toyType,
    GameToyGroupingField.completeness => personal?.details.completeness.label,
    GameToyGroupingField.condition => personal?.condition,
    GameToyGroupingField.purchaseDate => purchase?.isoString,
    GameToyGroupingField.purchaseMonth => _monthLabel(purchase),
    GameToyGroupingField.purchaseStore => personal?.purchaseStore,
    GameToyGroupingField.purchaseYear => purchase?.year,
    GameToyGroupingField.valueLocked =>
      personal == null ? null : _yesNo(personal.details.valueIsLocked == true),
    GameToyGroupingField.addedDate => added?.isoString,
    GameToyGroupingField.addedMonth => _monthLabel(added),
    GameToyGroupingField.addedYear => added?.year,
    GameToyGroupingField.collectionStatus => personal == null
        ? null
        : libraryCollectionStatusFromValue(personal.collectionStatus).label,
    GameToyGroupingField.location => context.personal.locationPath,
    GameToyGroupingField.modifiedDate => modified?.isoString,
    GameToyGroupingField.modifiedMonth => _monthLabel(modified),
    GameToyGroupingField.rating => personal?.rating,
    GameToyGroupingField.owner => personal?.ownerLabel,
    GameToyGroupingField.tags => personal?.tags ?? const <String>[],
  };
}

Set<String> gameToyWorkspaceImageTypes(
        LibraryProjectionContext<GameToyWorkspaceDto> context) =>
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
