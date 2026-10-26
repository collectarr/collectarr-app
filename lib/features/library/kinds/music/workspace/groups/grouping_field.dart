import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

enum MusicGroupingField {
  hasBack,
  hasFront,
  imageType,
  artist,
  discFormat,
  discFormatFamily,
  genre,
  publisher,
  originalReleaseDate,
  originalReleaseMonth,
  originalReleaseYear,
  recordingDate,
  recordingMonth,
  recordingYear,
  releaseDate,
  releaseMonth,
  releaseYear,
  boxSet,
  country,
  extra,
  creditContributor,
  creditRole,
  creditInstrument,
  isLive,
  mediaCondition,
  condition,
  packaging,
  rpm,
  spars,
  sound,
  storageDevice,
  storageSlot,
  recordingLocation,
  vinylColor,
  trackComposition,
  addedAt,
  addedMonth,
  addedYear,
  collectionStatus,
  isSigned,
  lastCleaned,
  lastCleanedMonth,
  lastCleanedYear,
  location,
  updatedAt,
  updatedMonth,
  rating,
  owner,
  played,
  playedDate,
  playedMonth,
  playedYear,
  purchaseDate,
  purchaseMonth,
  purchaseStore,
  purchaseYear,
  signedBy,
  tags,
}

extension MusicGroupingFieldConfiguration on MusicGroupingField {
  LibraryKindFieldMetadata get fieldMetadata => switch (this) {
        MusicGroupingField.hasBack => MusicWorkspaceFieldMetadata.hasBack,
        MusicGroupingField.hasFront => MusicWorkspaceFieldMetadata.hasFront,
        MusicGroupingField.imageType => MusicWorkspaceFieldMetadata.imageType,
        MusicGroupingField.artist => MusicFieldIdentities.artist,
        MusicGroupingField.discFormat => MusicFieldIdentities.discFormat,
        MusicGroupingField.discFormatFamily =>
          MusicWorkspaceFieldMetadata.discFormatFamily,
        MusicGroupingField.genre => MusicFieldIdentities.genre,
        MusicGroupingField.publisher => MusicFieldIdentities.publisher,
        MusicGroupingField.originalReleaseDate =>
          MusicWorkspaceFieldMetadata.originalReleaseDate,
        MusicGroupingField.originalReleaseMonth =>
          MusicWorkspaceFieldMetadata.originalReleaseMonth,
        MusicGroupingField.originalReleaseYear =>
          MusicWorkspaceFieldMetadata.originalReleaseYear,
        MusicGroupingField.recordingDate =>
          MusicWorkspaceFieldMetadata.recordingDate,
        MusicGroupingField.recordingMonth =>
          MusicWorkspaceFieldMetadata.recordingMonth,
        MusicGroupingField.recordingYear =>
          MusicWorkspaceFieldMetadata.recordingYear,
        MusicGroupingField.releaseDate => MusicFieldIdentities.releaseDate,
        MusicGroupingField.releaseMonth =>
          MusicWorkspaceFieldMetadata.releaseMonth,
        MusicGroupingField.releaseYear =>
          MusicWorkspaceFieldMetadata.releaseYear,
        MusicGroupingField.boxSet => MusicFieldIdentities.boxSet,
        MusicGroupingField.country => MusicFieldIdentities.country,
        MusicGroupingField.extra => MusicWorkspaceFieldMetadata.extra,
        MusicGroupingField.creditContributor =>
          MusicWorkspaceFieldMetadata.creditContributor,
        MusicGroupingField.creditRole => MusicWorkspaceFieldMetadata.creditRole,
        MusicGroupingField.creditInstrument =>
          MusicWorkspaceFieldMetadata.creditInstrument,
        MusicGroupingField.isLive => MusicWorkspaceFieldMetadata.isLive,
        MusicGroupingField.mediaCondition =>
          MusicWorkspaceFieldMetadata.mediaCondition,
        MusicGroupingField.condition => MusicWorkspaceFieldMetadata.condition,
        MusicGroupingField.packaging => MusicFieldIdentities.packaging,
        MusicGroupingField.rpm => MusicWorkspaceFieldMetadata.rpm,
        MusicGroupingField.spars => MusicWorkspaceFieldMetadata.spars,
        MusicGroupingField.sound => MusicWorkspaceFieldMetadata.sound,
        MusicGroupingField.storageDevice =>
          MusicWorkspaceFieldMetadata.storageDevice,
        MusicGroupingField.storageSlot =>
          MusicWorkspaceFieldMetadata.storageSlot,
        MusicGroupingField.recordingLocation =>
          MusicWorkspaceFieldMetadata.recordingLocations,
        MusicGroupingField.vinylColor => MusicWorkspaceFieldMetadata.vinylColor,
        MusicGroupingField.trackComposition =>
          MusicWorkspaceFieldMetadata.trackComposition,
        MusicGroupingField.addedAt => MusicWorkspaceFieldMetadata.addedAt,
        MusicGroupingField.addedMonth => MusicWorkspaceFieldMetadata.addedMonth,
        MusicGroupingField.addedYear => MusicWorkspaceFieldMetadata.addedYear,
        MusicGroupingField.collectionStatus =>
          MusicWorkspaceFieldMetadata.collectionStatus,
        MusicGroupingField.isSigned => MusicWorkspaceFieldMetadata.isSigned,
        MusicGroupingField.lastCleaned =>
          MusicWorkspaceFieldMetadata.lastCleaned,
        MusicGroupingField.lastCleanedMonth =>
          MusicWorkspaceFieldMetadata.lastCleanedMonth,
        MusicGroupingField.lastCleanedYear =>
          MusicWorkspaceFieldMetadata.lastCleanedYear,
        MusicGroupingField.location => MusicWorkspaceFieldMetadata.location,
        MusicGroupingField.updatedAt => MusicWorkspaceFieldMetadata.updatedAt,
        MusicGroupingField.updatedMonth =>
          MusicWorkspaceFieldMetadata.updatedMonth,
        MusicGroupingField.rating => MusicWorkspaceFieldMetadata.rating,
        MusicGroupingField.owner => MusicWorkspaceFieldMetadata.owner,
        MusicGroupingField.played => MusicWorkspaceFieldMetadata.played,
        MusicGroupingField.playedDate => MusicWorkspaceFieldMetadata.playedDate,
        MusicGroupingField.playedMonth =>
          MusicWorkspaceFieldMetadata.playedMonth,
        MusicGroupingField.playedYear => MusicWorkspaceFieldMetadata.playedYear,
        MusicGroupingField.purchaseDate =>
          MusicWorkspaceFieldMetadata.purchaseDate,
        MusicGroupingField.purchaseMonth =>
          MusicWorkspaceFieldMetadata.purchaseMonth,
        MusicGroupingField.purchaseStore =>
          MusicWorkspaceFieldMetadata.purchaseStore,
        MusicGroupingField.purchaseYear =>
          MusicWorkspaceFieldMetadata.purchaseYear,
        MusicGroupingField.signedBy => MusicWorkspaceFieldMetadata.signedBy,
        MusicGroupingField.tags => MusicWorkspaceFieldMetadata.tags,
      };

  String get id => fieldMetadata.id;

  String get label => fieldMetadata.label;

  String get category => switch (this) {
        MusicGroupingField.hasBack ||
        MusicGroupingField.hasFront ||
        MusicGroupingField.imageType =>
          'Images',
        MusicGroupingField.creditContributor ||
        MusicGroupingField.creditRole ||
        MusicGroupingField.creditInstrument =>
          'Credits',
        MusicGroupingField.boxSet ||
        MusicGroupingField.country ||
        MusicGroupingField.extra ||
        MusicGroupingField.isLive ||
        MusicGroupingField.packaging ||
        MusicGroupingField.rpm ||
        MusicGroupingField.spars ||
        MusicGroupingField.sound ||
        MusicGroupingField.recordingLocation ||
        MusicGroupingField.vinylColor ||
        MusicGroupingField.trackComposition ||
        MusicGroupingField.mediaCondition ||
        MusicGroupingField.condition ||
        MusicGroupingField.storageDevice ||
        MusicGroupingField.storageSlot =>
          'Details',
        MusicGroupingField.addedAt ||
        MusicGroupingField.addedMonth ||
        MusicGroupingField.addedYear ||
        MusicGroupingField.collectionStatus ||
        MusicGroupingField.isSigned ||
        MusicGroupingField.lastCleaned ||
        MusicGroupingField.lastCleanedMonth ||
        MusicGroupingField.lastCleanedYear ||
        MusicGroupingField.location ||
        MusicGroupingField.updatedAt ||
        MusicGroupingField.updatedMonth ||
        MusicGroupingField.rating ||
        MusicGroupingField.owner ||
        MusicGroupingField.played ||
        MusicGroupingField.playedDate ||
        MusicGroupingField.playedMonth ||
        MusicGroupingField.playedYear ||
        MusicGroupingField.purchaseDate ||
        MusicGroupingField.purchaseMonth ||
        MusicGroupingField.purchaseStore ||
        MusicGroupingField.purchaseYear ||
        MusicGroupingField.signedBy ||
        MusicGroupingField.tags =>
          'Personal',
        _ => 'Main',
      };

  bool get localOnly => switch (this) {
        MusicGroupingField.imageType ||
        MusicGroupingField.mediaCondition ||
        MusicGroupingField.condition ||
        MusicGroupingField.storageDevice ||
        MusicGroupingField.storageSlot ||
        MusicGroupingField.addedAt ||
        MusicGroupingField.addedMonth ||
        MusicGroupingField.addedYear ||
        MusicGroupingField.collectionStatus ||
        MusicGroupingField.isSigned ||
        MusicGroupingField.lastCleaned ||
        MusicGroupingField.lastCleanedMonth ||
        MusicGroupingField.lastCleanedYear ||
        MusicGroupingField.location ||
        MusicGroupingField.updatedAt ||
        MusicGroupingField.updatedMonth ||
        MusicGroupingField.rating ||
        MusicGroupingField.owner ||
        MusicGroupingField.played ||
        MusicGroupingField.playedDate ||
        MusicGroupingField.playedMonth ||
        MusicGroupingField.playedYear ||
        MusicGroupingField.purchaseDate ||
        MusicGroupingField.purchaseMonth ||
        MusicGroupingField.purchaseStore ||
        MusicGroupingField.purchaseYear ||
        MusicGroupingField.signedBy ||
        MusicGroupingField.tags =>
          true,
        _ => false,
      };

  VocabularyId<String>? get bucketVocabulary => fieldMetadata.vocabulary;
}
