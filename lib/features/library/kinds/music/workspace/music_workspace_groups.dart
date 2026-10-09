import 'package:collectarr_app/features/pick_lists/models/universal_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:flutter/material.dart';

/// CLZ Music folder choices, in the order captured in full_editor.mhtml.
enum MusicGroupingField {
  hasBack('music.has_back', 'Has Back', 'Images', localOnly: false),
  hasFront('music.has_front', 'Has Front', 'Images', localOnly: false),
  imageType('music.image_type', 'Image Type', 'Images', localOnly: true),
  artist(
      MusicFieldIdentities.artistId, MusicFieldIdentities.artistLabel, 'Main',
      localOnly: false),
  discFormat(MusicFieldIdentities.discFormatId,
      MusicFieldIdentities.discFormatLabel, 'Main',
      localOnly: false),
  genre(MusicFieldIdentities.genreId, MusicFieldIdentities.genreLabel, 'Main',
      localOnly: false),
  publisher(MusicFieldIdentities.publisherId,
      MusicFieldIdentities.publisherLabel, 'Main',
      localOnly: false),
  originalReleaseDate(
      'music.original_release_date', 'Original Release Date', 'Main',
      localOnly: false),
  originalReleaseMonth(
      'music.original_release_month', 'Original Release Month', 'Main',
      localOnly: false),
  originalReleaseYear(
      'music.original_release_year', 'Original Release Year', 'Main',
      localOnly: false),
  recordingDate('music.recording_date', 'Recording Date', 'Main',
      localOnly: false),
  recordingMonth('music.recording_month', 'Recording Month', 'Main',
      localOnly: false),
  recordingYear('music.recording_year', 'Recording Year', 'Main',
      localOnly: false),
  releaseDate(MusicFieldIdentities.releaseDateId,
      MusicFieldIdentities.releaseDateLabel, 'Main',
      localOnly: false),
  releaseMonth('music.release_month', 'Release Month', 'Main',
      localOnly: false),
  releaseYear('music.release_year', 'Release Year', 'Main', localOnly: false),
  boxSet(MusicFieldIdentities.boxSetId, MusicFieldIdentities.boxSetLabel,
      'Details',
      localOnly: false),
  country(MusicFieldIdentities.countryId, MusicFieldIdentities.countryLabel,
      'Details',
      localOnly: false),
  extra('music.extra', 'Extra', 'Details', localOnly: false),
  instrument('music.instrument', 'Instrument', 'Details', localOnly: false),
  isLive('music.is_live', 'Is Live', 'Details', localOnly: false),
  mediaCondition('music.media_condition', 'Media Condition', 'Details',
      localOnly: true),
  condition('music.condition', 'Package/Sleeve Condition', 'Details',
      localOnly: true),
  packaging(MusicFieldIdentities.packagingId,
      MusicFieldIdentities.packagingLabel, 'Details',
      localOnly: false),
  rpm('music.rpm', 'RPM', 'Details', localOnly: false),
  spars('music.spars', 'SPARS', 'Details', localOnly: false),
  sound('music.sound', 'Sound', 'Details', localOnly: false),
  storageDevice('music.storage_device', 'Storage Device', 'Details',
      localOnly: true),
  storageSlot('music.storage_slot', 'Storage Slot', 'Details', localOnly: true),
  studio('music.studio', 'Studio', 'Details', localOnly: false),
  vinylColor('music.vinyl_color', 'Vinyl Color', 'Details', localOnly: false),
  chorus('music.chorus', 'Chorus', 'Classical', localOnly: false),
  composer('music.composer', 'Composer', 'Classical', localOnly: false),
  composition('music.composition', 'Composition', 'Classical',
      localOnly: false),
  conductor('music.conductor', 'Conductor', 'Classical', localOnly: false),
  orchestra('music.orchestra', 'Orchestra', 'Classical', localOnly: false),
  engineer('music.engineer', 'Engineer', 'People', localOnly: false),
  musician('music.musician', 'Musician', 'People', localOnly: false),
  producer('music.producer', 'Producer', 'People', localOnly: false),
  songwriter('music.songwriter', 'Songwriter', 'People', localOnly: false),
  addedAt('music.added_at', 'Added Date', 'Personal', localOnly: true),
  addedMonth('music.added_month', 'Added Month', 'Personal', localOnly: true),
  addedYear('music.added_year', 'Added Year', 'Personal', localOnly: true),
  collectionStatus('music.collection_status', 'Collection Status', 'Personal',
      localOnly: true),
  isSigned('music.is_signed', 'Is Signed', 'Personal', localOnly: true),
  lastCleaned('music.last_cleaned', 'Last Cleaned Date', 'Personal',
      localOnly: true),
  lastCleanedMonth('music.last_cleaned_month', 'Last Cleaned Month', 'Personal',
      localOnly: true),
  lastCleanedYear('music.last_cleaned_year', 'Last Cleaned Year', 'Personal',
      localOnly: true),
  location('music.location', 'Location', 'Personal', localOnly: true),
  updatedAt('music.updated_at', 'Modified Date', 'Personal', localOnly: true),
  updatedMonth('music.updated_month', 'Modified Month', 'Personal',
      localOnly: true),
  rating('music.rating', 'My Rating', 'Personal', localOnly: true),
  owner('music.owner', 'Owner', 'Personal', localOnly: true),
  played('music.played', 'Played', 'Personal', localOnly: true),
  playedDate('music.played_date', 'Played Date', 'Personal', localOnly: true),
  playedMonth('music.played_month', 'Played Month', 'Personal',
      localOnly: true),
  playedYear('music.played_year', 'Played Year', 'Personal', localOnly: true),
  purchaseDate('music.purchase_date', 'Purchase Date', 'Personal',
      localOnly: true),
  purchaseMonth('music.purchase_month', 'Purchase Month', 'Personal',
      localOnly: true),
  purchaseStore('music.purchase_store', 'Purchase Store', 'Personal',
      localOnly: true),
  purchaseYear('music.purchase_year', 'Purchase Year', 'Personal',
      localOnly: true),
  signedBy('music.signed_by', 'Signed by', 'Personal', localOnly: true),
  tags('music.tags', 'Tags', 'Personal', localOnly: true),
  ;

  const MusicGroupingField(this.id, this.label, this.category,
      {required this.localOnly});
  final String id;
  final String label;
  final String category;
  final bool localOnly;

  LibraryKindFieldMetadata? get fieldMetadata => switch (this) {
        artist => MusicFieldIdentities.artist,
        discFormat => MusicFieldIdentities.discFormat,
        genre => MusicFieldIdentities.genre,
        publisher => MusicFieldIdentities.publisher,
        releaseDate => MusicFieldIdentities.releaseDate,
        boxSet => MusicFieldIdentities.boxSet,
        country => MusicFieldIdentities.country,
        packaging => MusicFieldIdentities.packaging,
        storageDevice => MusicWorkspaceFieldMetadata.storageDevice,
        storageSlot => MusicWorkspaceFieldMetadata.storageSlot,
        _ => null,
      };

  VocabularyId<String>? get bucketVocabulary => switch (this) {
        artist => MusicVocabularyIds.artist,
        boxSet => MusicVocabularyIds.boxSet,
        extra => MusicVocabularyIds.extra,
        spars => MusicVocabularyIds.spars,
        imageType => MusicVocabularyIds.imageType,
        owner => UniversalVocabularyIds.owners,
        location => const VocabularyId<String>('locations'),
        tags => UniversalVocabularyIds.tags,
        purchaseStore => UniversalVocabularyIds.purchaseStore,
        discFormat => MusicVocabularyIds.format,
        genre => MusicVocabularyIds.genre,
        publisher => MusicVocabularyIds.recordLabel,
        country => MusicVocabularyIds.country,
        instrument => MusicVocabularyIds.instrument,
        mediaCondition => MusicVocabularyIds.mediaCondition,
        condition => MusicVocabularyIds.condition,
        packaging => MusicVocabularyIds.packaging,
        sound => MusicVocabularyIds.soundType,
        storageDevice => MusicVocabularyIds.storageDevice,
        studio => MusicVocabularyIds.recordingLocation,
        vinylColor => MusicVocabularyIds.vinylColor,
        signedBy => MusicVocabularyIds.signedBy,
        chorus ||
        composer ||
        composition ||
        conductor ||
        orchestra ||
        engineer ||
        musician ||
        producer ||
        songwriter =>
          MusicVocabularyIds.contributorName,
        _ => null,
      };
}

List<LibraryGroupDefinition<MusicKind, MusicWorkspaceProjection, Object?>>
    musicWorkspaceGroupDefinitions({required bool includePersonal}) => [
          for (final field in MusicGroupingField.values)
            if (includePersonal || !field.localOnly)
              if (field.fieldMetadata?.groupable ?? true)
                LibraryGroupDefinition(
                    id: LibraryGroupId<MusicKind, Object?>(field.id,
                        semantic: field == MusicGroupingField.location
                            ? LibraryGroupSemantic.location
                            : LibraryGroupSemantic.value),
                    label: field.label,
                    bucketVocabulary: field.bucketVocabulary,
                    sidebarTitle: field.label,
                    category: field.category,
                    icon: switch (field.category) {
                      'Images' => Icons.image_outlined,
                      'Classical' => Icons.music_note_outlined,
                      'People' => Icons.people_outline,
                      'Personal' => Icons.person_outline,
                      'Details' => Icons.info_outline,
                      _ => Icons.folder_outlined,
                    },
                    getValue: (context) => _groupValue(field, context)),
        ];

Object? _groupValue(MusicGroupingField field,
    LibraryProjectionContext<MusicWorkspaceProjection> context) {
  final dto = context.dto;
  final album = dto.music;
  final facts = dto.facts;
  final entry = MusicLibraryEntryProjection.fromDispatch(
      context.item.libraryEntryDispatch);
  final MusicPersonalData? personal = entry?.personal;
  final imageTypes = <String>{
    if (_has(dto.imageUrl) ||
        _has(album.coverImageUrl) ||
        _has(album.localCoverImagePath))
      'front_cover',
    if (_has(album.backCoverImageUrl) || _has(album.localBackImagePath))
      'back_cover',
    for (final image in context.personal.images)
      MusicAlbumImage.imageTypeFromStorageValue(image.imageType),
  };
  Iterable<String> names(String role) => facts.contributorsForRole(role);
  final purchase =
      personal?.purchaseDateParts ?? _parts(personal?.purchaseDate);
  final cleaned = personal?.details.lastCleanedDateParts ??
      _parts(personal?.details.lastCleanedDate);
  final added = _parts(entry?.createdAt ?? context.addedAt);
  final modified = _parts(entry?.updatedAt ?? context.updatedAt);
  final played = _parts(dto.listeningSummary?.lastListened);
  return switch (field) {
    MusicGroupingField.hasBack => _yesNo(imageTypes.contains('back_cover')),
    MusicGroupingField.hasFront => _yesNo(imageTypes.contains('front_cover')),
    MusicGroupingField.imageType => imageTypes,
    MusicGroupingField.artist => album.artistCredits.isNotEmpty
        ? album.artistCredits.map((credit) => credit.creditedName)
        : facts.artistNames,
    MusicGroupingField.discFormat => facts.discFormats,
    MusicGroupingField.genre => album.genres,
    MusicGroupingField.publisher => album.publisher,
    MusicGroupingField.originalReleaseDate =>
      album.originalReleaseDateParts?.isoString,
    MusicGroupingField.originalReleaseMonth =>
      _month(album.originalReleaseDateParts),
    MusicGroupingField.originalReleaseYear =>
      album.originalReleaseDateParts?.year,
    MusicGroupingField.recordingDate => facts.discRecordingDates
        .map((date) => date.isoString)
        .whereType<String>(),
    MusicGroupingField.recordingMonth => facts.discRecordingMonths
        .map((month) => _month(PartialDate(month: month)))
        .whereType<String>(),
    MusicGroupingField.recordingYear =>
      facts.discRecordingYears.map((year) => year.toString()),
    MusicGroupingField.releaseDate => album.releaseDateParts?.isoString,
    MusicGroupingField.releaseMonth => _month(album.releaseDateParts),
    MusicGroupingField.releaseYear => album.releaseDateParts?.year,
    MusicGroupingField.boxSet => album.boxSet,
    MusicGroupingField.country => album.countryCode,
    MusicGroupingField.extra => album.extra,
    MusicGroupingField.instrument => facts.creditInstruments,
    MusicGroupingField.isLive => <String>{
        if (facts.hasLiveDisc) 'Yes',
        if (facts.hasStudioDisc) 'No',
      },
    MusicGroupingField.mediaCondition => personal?.mediaCondition,
    MusicGroupingField.condition => personal?.condition,
    MusicGroupingField.packaging => album.packaging,
    MusicGroupingField.rpm => facts.discRpms,
    MusicGroupingField.spars => facts.discSparsCodes,
    MusicGroupingField.sound => facts.discSoundTypes,
    MusicGroupingField.storageDevice => personal?.details.media
        .map((medium) => medium.storageDevice)
        .whereType<String>(),
    MusicGroupingField.storageSlot => personal?.details.media
        .map((medium) => medium.storageSlot)
        .whereType<String>(),
    MusicGroupingField.studio => facts.recordingLocations,
    MusicGroupingField.vinylColor => facts.discColors,
    MusicGroupingField.chorus => names('chorus'),
    MusicGroupingField.composer => names('composer'),
    MusicGroupingField.composition => facts.trackCompositions,
    MusicGroupingField.conductor => names('conductor'),
    MusicGroupingField.orchestra => names('orchestra'),
    MusicGroupingField.engineer => names('engineer'),
    MusicGroupingField.musician => names('musician'),
    MusicGroupingField.producer => names('producer'),
    MusicGroupingField.songwriter => names('songwriter'),
    MusicGroupingField.addedAt => added?.isoString,
    MusicGroupingField.addedMonth => _month(added),
    MusicGroupingField.addedYear => added?.year,
    MusicGroupingField.collectionStatus => personal == null
        ? null
        : libraryCollectionStatusFromValue(personal.collectionStatus).label,
    MusicGroupingField.isSigned => _yesNo(_has(personal?.details.signedBy)),
    MusicGroupingField.lastCleaned => cleaned?.isoString,
    MusicGroupingField.lastCleanedMonth => _month(cleaned),
    MusicGroupingField.lastCleanedYear => cleaned?.year,
    MusicGroupingField.location => context.personal.locationPath,
    MusicGroupingField.updatedAt => modified?.isoString,
    MusicGroupingField.updatedMonth => _month(modified),
    MusicGroupingField.rating => personal?.rating,
    MusicGroupingField.owner => personal?.ownerLabel,
    MusicGroupingField.played =>
      _yesNo((dto.listeningSummary?.totalListenCount ?? 0) > 0),
    MusicGroupingField.playedDate => dto.listeningSummary?.recentEvents
        .map((event) => _parts(event.listenedAt)?.isoString),
    MusicGroupingField.playedMonth => _month(played),
    MusicGroupingField.playedYear => played?.year,
    MusicGroupingField.purchaseDate => purchase?.isoString,
    MusicGroupingField.purchaseMonth => _month(purchase),
    MusicGroupingField.purchaseStore => personal?.purchaseStore,
    MusicGroupingField.purchaseYear => purchase?.year,
    MusicGroupingField.signedBy => _split(personal?.details.signedBy),
    MusicGroupingField.tags => _split(personal?.tags),
  };
}

PartialDate? _parts(DateTime? value) =>
    value == null ? null : PartialDate.fromDateTime(value);
bool _has(String? value) => value?.trim().isNotEmpty == true;
String _yesNo(bool value) => value ? 'Yes' : 'No';
Iterable<String> _split(String? value) => value?.split(',') ?? const [];
String? _month(PartialDate? value) {
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
    'December'
  ];
  return '${month.toString().padLeft(2, '0')} - ${names[month - 1]}';
}
