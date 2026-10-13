import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_grouping_field.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_workspace_group_helpers.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_personal_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;

const musicPersonalGroupingFields = <MusicGroupingField>{
  MusicGroupingField.mediaCondition,
  MusicGroupingField.condition,
  MusicGroupingField.storageDevice,
  MusicGroupingField.storageSlot,
  MusicGroupingField.addedAt,
  MusicGroupingField.addedMonth,
  MusicGroupingField.addedYear,
  MusicGroupingField.collectionStatus,
  MusicGroupingField.isSigned,
  MusicGroupingField.lastCleaned,
  MusicGroupingField.lastCleanedMonth,
  MusicGroupingField.lastCleanedYear,
  MusicGroupingField.location,
  MusicGroupingField.updatedAt,
  MusicGroupingField.updatedMonth,
  MusicGroupingField.rating,
  MusicGroupingField.owner,
  MusicGroupingField.played,
  MusicGroupingField.playedDate,
  MusicGroupingField.playedMonth,
  MusicGroupingField.playedYear,
  MusicGroupingField.purchaseDate,
  MusicGroupingField.purchaseMonth,
  MusicGroupingField.purchaseStore,
  MusicGroupingField.purchaseYear,
  MusicGroupingField.signedBy,
  MusicGroupingField.tags,
};

Object? musicPersonalGroupValue(
  MusicGroupingField field,
  LibraryProjectionContext<MusicWorkspaceProjection> context,
) {
  final dto = context.dto;
  final entryProjection = MusicLibraryEntryProjection.fromDispatch(
    context.item.libraryEntryDispatch,
  );
  final MusicPersonalData? personal = entryProjection?.personal;
  final purchase = personal?.purchaseDateParts ??
      musicGroupDateParts(personal?.purchaseDate);
  final cleaned = personal?.details.lastCleanedDateParts ??
      musicGroupDateParts(personal?.details.lastCleanedDate);
  final added =
      musicGroupDateParts(entryProjection?.createdAt ?? context.addedAt);
  final modified =
      musicGroupDateParts(entryProjection?.updatedAt ?? context.updatedAt);
  final played = musicGroupDateParts(dto.listeningSummary?.lastListened);

  return switch (field) {
    MusicGroupingField.mediaCondition => personal?.mediaCondition,
    MusicGroupingField.condition => personal?.condition,
    MusicGroupingField.storageDevice =>
      MusicPersonalWorkspaceFields.storageDevice.getValue(context),
    MusicGroupingField.storageSlot =>
      MusicPersonalWorkspaceFields.storageSlot.getValue(context),
    MusicGroupingField.addedAt => added?.isoString,
    MusicGroupingField.addedMonth => musicGroupMonthLabel(added),
    MusicGroupingField.addedYear => added?.year,
    MusicGroupingField.collectionStatus => personal == null
        ? null
        : libraryCollectionStatusFromValue(personal.collectionStatus).label,
    MusicGroupingField.isSigned =>
      musicGroupYesNo(musicGroupHasText(personal?.details.signedBy)),
    MusicGroupingField.lastCleaned => cleaned?.isoString,
    MusicGroupingField.lastCleanedMonth => musicGroupMonthLabel(cleaned),
    MusicGroupingField.lastCleanedYear => cleaned?.year,
    MusicGroupingField.location => context.personal.locationPath,
    MusicGroupingField.updatedAt => modified?.isoString,
    MusicGroupingField.updatedMonth => musicGroupMonthLabel(modified),
    MusicGroupingField.rating => personal?.rating,
    MusicGroupingField.owner => personal?.ownerLabel,
    MusicGroupingField.played =>
      musicGroupYesNo((dto.listeningSummary?.totalListenCount ?? 0) > 0),
    MusicGroupingField.playedDate => dto.listeningSummary?.recentEvents
        .map((event) => musicGroupDateParts(event.listenedAt)?.isoString),
    MusicGroupingField.playedMonth => musicGroupMonthLabel(played),
    MusicGroupingField.playedYear => played?.year,
    MusicGroupingField.purchaseDate => purchase?.isoString,
    MusicGroupingField.purchaseMonth => musicGroupMonthLabel(purchase),
    MusicGroupingField.purchaseStore => personal?.purchaseStore,
    MusicGroupingField.purchaseYear => purchase?.year,
    MusicGroupingField.signedBy => musicGroupSplit(personal?.details.signedBy),
    MusicGroupingField.tags => musicGroupSplit(personal?.tags),
    _ => throw ArgumentError.value(field, 'field', 'Not a personal grouping.'),
  };
}
