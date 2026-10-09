import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/models/universal_vocabularies.dart';
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
  LibraryKindFieldMetadata? get fieldMetadata => switch (this) {
        MusicGroupingField.artist => MusicFieldIdentities.artist,
        MusicGroupingField.discFormat => MusicFieldIdentities.discFormat,
        MusicGroupingField.discFormatFamily =>
          MusicWorkspaceFieldMetadata.discFormatFamily,
        MusicGroupingField.genre => MusicFieldIdentities.genre,
        MusicGroupingField.publisher => MusicFieldIdentities.publisher,
        MusicGroupingField.originalReleaseYear =>
          MusicWorkspaceFieldMetadata.originalReleaseYear,
        MusicGroupingField.recordingDate =>
          MusicWorkspaceFieldMetadata.recordingDate,
        MusicGroupingField.recordingMonth =>
          MusicWorkspaceFieldMetadata.recordingMonth,
        MusicGroupingField.recordingYear =>
          MusicWorkspaceFieldMetadata.recordingYear,
        MusicGroupingField.releaseDate => MusicFieldIdentities.releaseDate,
        MusicGroupingField.releaseYear =>
          MusicWorkspaceFieldMetadata.releaseYear,
        MusicGroupingField.boxSet => MusicFieldIdentities.boxSet,
        MusicGroupingField.country => MusicFieldIdentities.country,
        MusicGroupingField.creditContributor =>
          MusicWorkspaceFieldMetadata.creditContributor,
        MusicGroupingField.creditRole => MusicWorkspaceFieldMetadata.creditRole,
        MusicGroupingField.creditInstrument =>
          MusicWorkspaceFieldMetadata.creditInstrument,
        MusicGroupingField.isLive => MusicWorkspaceFieldMetadata.isLive,
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
        MusicGroupingField.lastCleaned =>
          MusicWorkspaceFieldMetadata.lastCleaned,
        MusicGroupingField.location => MusicWorkspaceFieldMetadata.location,
        MusicGroupingField.rating => MusicWorkspaceFieldMetadata.rating,
        MusicGroupingField.purchaseDate =>
          MusicWorkspaceFieldMetadata.purchaseDate,
        MusicGroupingField.signedBy => MusicWorkspaceFieldMetadata.signedBy,
        MusicGroupingField.updatedAt => MusicWorkspaceFieldMetadata.updatedAt,
        _ => null,
      };

  String get id =>
      fieldMetadata?.id ??
      switch (this) {
        MusicGroupingField.hasBack => 'music.has_back',
        MusicGroupingField.hasFront => 'music.has_front',
        MusicGroupingField.imageType => 'music.image_type',
        MusicGroupingField.originalReleaseDate => 'music.original_release_date',
        MusicGroupingField.originalReleaseMonth =>
          'music.original_release_month',
        MusicGroupingField.releaseMonth => 'music.release_month',
        MusicGroupingField.extra => 'music.extra',
        MusicGroupingField.mediaCondition => 'music.media_condition',
        MusicGroupingField.addedMonth => 'music.added_month',
        MusicGroupingField.addedYear => 'music.added_year',
        MusicGroupingField.collectionStatus => 'music.collection_status',
        MusicGroupingField.isSigned => 'music.is_signed',
        MusicGroupingField.lastCleanedMonth => 'music.last_cleaned_month',
        MusicGroupingField.lastCleanedYear => 'music.last_cleaned_year',
        MusicGroupingField.updatedMonth => 'music.updated_month',
        MusicGroupingField.owner => 'music.owner',
        MusicGroupingField.played => 'music.played',
        MusicGroupingField.playedDate => 'music.played_date',
        MusicGroupingField.playedMonth => 'music.played_month',
        MusicGroupingField.playedYear => 'music.played_year',
        MusicGroupingField.purchaseMonth => 'music.purchase_month',
        MusicGroupingField.purchaseStore => 'music.purchase_store',
        MusicGroupingField.purchaseYear => 'music.purchase_year',
        MusicGroupingField.tags => 'music.tags',
        _ => throw StateError('Grouping field $this needs metadata or an ID.'),
      };

  String get label =>
      fieldMetadata?.label ??
      switch (this) {
        MusicGroupingField.hasBack => 'Has Back',
        MusicGroupingField.hasFront => 'Has Front',
        MusicGroupingField.imageType => 'Image Type',
        MusicGroupingField.originalReleaseDate => 'Original Release Date',
        MusicGroupingField.originalReleaseMonth => 'Original Release Month',
        MusicGroupingField.releaseMonth => 'Release Month',
        MusicGroupingField.extra => 'Extra',
        MusicGroupingField.mediaCondition => 'Media Condition',
        MusicGroupingField.addedMonth => 'Added Month',
        MusicGroupingField.addedYear => 'Added Year',
        MusicGroupingField.collectionStatus => 'Collection Status',
        MusicGroupingField.isSigned => 'Is Signed',
        MusicGroupingField.lastCleanedMonth => 'Last Cleaned Month',
        MusicGroupingField.lastCleanedYear => 'Last Cleaned Year',
        MusicGroupingField.updatedMonth => 'Modified Month',
        MusicGroupingField.owner => 'Owner',
        MusicGroupingField.played => 'Played',
        MusicGroupingField.playedDate => 'Played Date',
        MusicGroupingField.playedMonth => 'Played Month',
        MusicGroupingField.playedYear => 'Played Year',
        MusicGroupingField.purchaseMonth => 'Purchase Month',
        MusicGroupingField.purchaseStore => 'Purchase Store',
        MusicGroupingField.purchaseYear => 'Purchase Year',
        MusicGroupingField.tags => 'Tags',
        _ =>
          throw StateError('Grouping field $this needs metadata or a label.'),
      };

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

  VocabularyId<String>? get bucketVocabulary => switch (this) {
        MusicGroupingField.artist => MusicVocabularyIds.artist,
        MusicGroupingField.boxSet => MusicVocabularyIds.boxSet,
        MusicGroupingField.extra => MusicVocabularyIds.extra,
        MusicGroupingField.spars => MusicVocabularyIds.spars,
        MusicGroupingField.imageType => MusicVocabularyIds.imageType,
        MusicGroupingField.owner => UniversalVocabularyIds.owners,
        MusicGroupingField.location => const VocabularyId<String>('locations'),
        MusicGroupingField.tags => UniversalVocabularyIds.tags,
        MusicGroupingField.purchaseStore =>
          UniversalVocabularyIds.purchaseStore,
        MusicGroupingField.discFormat => MusicVocabularyIds.format,
        MusicGroupingField.creditContributor =>
          MusicVocabularyIds.contributorName,
        MusicGroupingField.creditRole => MusicVocabularyIds.creditRole,
        MusicGroupingField.creditInstrument => MusicVocabularyIds.instrument,
        MusicGroupingField.genre => MusicVocabularyIds.genre,
        MusicGroupingField.publisher => MusicVocabularyIds.recordLabel,
        MusicGroupingField.country => MusicVocabularyIds.country,
        MusicGroupingField.mediaCondition => MusicVocabularyIds.mediaCondition,
        MusicGroupingField.condition => MusicVocabularyIds.condition,
        MusicGroupingField.packaging => MusicVocabularyIds.packaging,
        MusicGroupingField.sound => MusicVocabularyIds.soundType,
        MusicGroupingField.storageDevice => MusicVocabularyIds.storageDevice,
        MusicGroupingField.recordingLocation =>
          MusicVocabularyIds.recordingLocation,
        MusicGroupingField.vinylColor => MusicVocabularyIds.vinylColor,
        MusicGroupingField.signedBy => MusicVocabularyIds.signedBy,
        _ => null,
      };
}
