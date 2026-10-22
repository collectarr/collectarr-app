import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_value_summary.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:flutter/material.dart';

/// Folder fields of the reference Games folder menu, by category.
enum GameGroupingField {
  audienceRating('audience_rating', 'Audience Rating', 'Main'),
  developer('developer', 'Developer', 'Main'),
  genre('genre', 'Genre', 'Main'),
  platform('platform', 'Platform', 'Main'),
  publisher('publisher', 'Publisher', 'Main'),
  releaseDate('release_date', 'Release Date', 'Main'),
  releaseMonth('release_month', 'Release Month', 'Main'),
  releaseYear('release_year', 'Release Year', 'Main'),
  series('series', 'Series', 'Main'),
  completeness('completeness', 'Completeness', 'Value'),
  condition('condition', 'Condition', 'Value'),
  purchaseDate('purchase_date', 'Purchase Date', 'Value'),
  purchaseMonth('purchase_month', 'Purchase Month', 'Value'),
  purchaseStore('purchase_store', 'Purchase Store', 'Value'),
  purchaseYear('purchase_year', 'Purchase Year', 'Value'),
  valueLocked('value_locked', 'Value Locked', 'Value'),
  edition('edition', 'Edition', 'Edition'),
  format('format', 'Format', 'Edition'),
  region('region', 'Region', 'Edition'),
  addedDate('added_date', 'Added Date', 'Personal'),
  addedMonth('added_month', 'Added Month', 'Personal'),
  addedYear('added_year', 'Added Year', 'Personal'),
  collectionStatus('collection_status', 'Collection Status', 'Personal'),
  completed('completed', 'Completed', 'Personal'),
  completedDate('completed_date', 'Completed Date', 'Personal'),
  completedMonth('completed_month', 'Completed Month', 'Personal'),
  completedYear('completed_year', 'Completed Year', 'Personal'),
  location('location', 'Location', 'Personal'),
  modifiedDate('modified_date', 'Modified Date', 'Personal'),
  modifiedMonth('modified_month', 'Modified Month', 'Personal'),
  rating('rating', 'My Rating', 'Personal'),
  owner('owner', 'Owner', 'Personal'),
  storageDevice('storage_device', 'Storage Device', 'Personal'),
  tags('tags', 'Tags', 'Personal');

  const GameGroupingField(this._key, this.label, this.category);

  final String _key;
  final String label;
  final String category;

  String get id => 'game.$_key';

  /// Folders that read the copy rather than the catalog item.
  bool get personal => category == 'Value' || category == 'Personal';
}

const gameGroupingCategories = ['Main', 'Value', 'Edition', 'Personal'];

List<LibraryGroupDefinition<GameKind, GameWorkspaceDto, Object?>>
    gameWorkspaceGroupDefinitions({required bool includePersonal}) => [
          for (final field in GameGroupingField.values)
            if (includePersonal || !field.personal)
              LibraryGroupDefinition(
                id: LibraryGroupId<GameKind, Object?>(
                  field.id,
                  semantic: field == GameGroupingField.location
                      ? LibraryGroupSemantic.location
                      : LibraryGroupSemantic.value,
                ),
                label: field.label,
                sidebarTitle: field.label,
                category: field.category,
                icon: switch (field.category) {
                  'Personal' => Icons.person_outline,
                  'Value' => Icons.attach_money,
                  'Edition' => Icons.album_outlined,
                  _ => Icons.folder_outlined,
                },
                getValue: (context) => _groupValue(field, context),
              ),
        ];

Object? _groupValue(
  GameGroupingField field,
  LibraryProjectionContext<GameWorkspaceDto> context,
) {
  final metadata = context.dto.metadata;
  final entry = GameLibraryEntryProjection.fromDispatch(
      context.item.libraryEntryDispatch);
  final personal = entry?.personal;
  final release = metadata.releaseDateParts;
  final purchase =
      personal?.purchaseDateParts ?? _parts(personal?.purchaseDate);
  final completed = personal?.details.completedDate;
  final added = _parts(entry?.createdAt ?? context.addedAt);
  final modified = _parts(entry?.updatedAt ?? context.updatedAt);
  return switch (field) {
    GameGroupingField.audienceRating => metadata.audienceRating,
    GameGroupingField.developer => metadata.developers,
    GameGroupingField.genre => metadata.genres,
    GameGroupingField.platform => metadata.platforms.firstOrNull,
    GameGroupingField.publisher => splitGamePublishers(metadata.publisher),
    GameGroupingField.releaseDate => release?.isoString,
    GameGroupingField.releaseMonth => _monthLabel(release),
    GameGroupingField.releaseYear => release?.year,
    GameGroupingField.series => metadata.seriesTitle,
    GameGroupingField.completeness => gameCompletenessOptions
        .where((option) => option.$1 == personal?.details.completeness)
        .firstOrNull
        ?.$2,
    GameGroupingField.condition => personal?.condition,
    GameGroupingField.purchaseDate => purchase?.isoString,
    GameGroupingField.purchaseMonth => _monthLabel(purchase),
    GameGroupingField.purchaseStore => personal?.purchaseStore,
    GameGroupingField.purchaseYear => purchase?.year,
    GameGroupingField.valueLocked =>
      personal == null ? null : _yesNo(personal.details.valueIsLocked == true),
    GameGroupingField.edition => metadata.editionTitle,
    GameGroupingField.format =>
      metadata.physicalFormatLabel ?? metadata.physicalFormat,
    GameGroupingField.region => metadata.releaseRegion,
    GameGroupingField.addedDate => added?.isoString,
    GameGroupingField.addedMonth => _monthLabel(added),
    GameGroupingField.addedYear => added?.year,
    GameGroupingField.collectionStatus => personal == null
        ? null
        : libraryCollectionStatusFromValue(personal.collectionStatus).label,
    GameGroupingField.completed =>
      personal == null ? null : _yesNo(personal.details.completed == true),
    GameGroupingField.completedDate => completed?.isoString,
    GameGroupingField.completedMonth => _monthLabel(completed),
    GameGroupingField.completedYear => completed?.year,
    GameGroupingField.location => context.personal.locationPath,
    GameGroupingField.modifiedDate => modified?.isoString,
    GameGroupingField.modifiedMonth => _monthLabel(modified),
    GameGroupingField.rating => personal?.rating,
    GameGroupingField.owner => personal?.ownerLabel,
    GameGroupingField.storageDevice => personal?.details.storageDevice,
    GameGroupingField.tags => [
        for (final tag in (personal?.tags ?? '').split(RegExp('[|,]')))
          if (tag.trim().isNotEmpty) tag.trim(),
      ],
  };
}

PartialDate? _parts(DateTime? value) =>
    value == null ? null : PartialDate.fromDateTime(value);

String _yesNo(bool value) => value ? 'Yes' : 'No';

String? _monthLabel(PartialDate? value) {
  final month = value?.month;
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
    'December',
  ];
  return '${month.toString().padLeft(2, '0')} - ${names[month - 1]}';
}
