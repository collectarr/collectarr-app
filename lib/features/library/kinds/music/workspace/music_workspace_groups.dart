import 'package:collectarr_app/features/pick_lists/models/universal_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
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
  artist('music.artist', 'Artist', 'Main', localOnly: false),
  format('music.format', 'Format', 'Main', localOnly: false),
  genre('music.genre', 'Genre', 'Main', localOnly: false),
  publisher('music.publisher', 'Label', 'Main', localOnly: false),
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
  releaseDate('music.release_date', 'Release Date', 'Main', localOnly: false),
  releaseMonth('music.release_month', 'Release Month', 'Main',
      localOnly: false),
  releaseYear('music.release_year', 'Release Year', 'Main', localOnly: false),
  boxSet('music.box_set', 'Box Set', 'Details', localOnly: false),
  country('music.country', 'Country', 'Details', localOnly: false),
  extra('music.extra', 'Extra', 'Details', localOnly: false),
  instrument('music.instrument', 'Instrument', 'Details', localOnly: false),
  isLive('music.is_live', 'Is Live', 'Details', localOnly: false),
  mediaCondition('music.media_condition', 'Media Condition', 'Details',
      localOnly: true),
  condition('music.condition', 'Package/Sleeve Condition', 'Details',
      localOnly: true),
  packaging('music.packaging', 'Packaging', 'Details', localOnly: false),
  rpm('music.rpm', 'RPM', 'Details', localOnly: false),
  spars('music.spars', 'SPARS', 'Details', localOnly: false),
  sound('music.sound', 'Sound', 'Details', localOnly: false),
  storage('music.storage', 'Storage Device', 'Details', localOnly: true),
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
        format => MusicVocabularyIds.format,
        genre => MusicVocabularyIds.genre,
        publisher => MusicVocabularyIds.recordLabel,
        country => MusicVocabularyIds.country,
        instrument => MusicVocabularyIds.instrument,
        mediaCondition => MusicVocabularyIds.mediaCondition,
        condition => MusicVocabularyIds.condition,
        packaging => MusicVocabularyIds.packaging,
        sound => MusicVocabularyIds.soundType,
        storage => MusicVocabularyIds.storageDevice,
        studio => MusicVocabularyIds.studio,
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
          MusicVocabularyIds.creditNames(name),
        _ => null,
      };
}

List<LibraryGroupDefinition<MusicKind, MusicWorkspaceProjection, Object?>>
    musicWorkspaceGroupDefinitions({required bool includePersonal}) => [
          for (final field in MusicGroupingField.values)
            if (includePersonal || !field.localOnly)
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
      image.imageType.startsWith('personal:')
          ? image.imageType.substring(9)
          : image.imageType,
  };
  Iterable<String?> names(String role) => album.contributions
      .where((credit) => credit.role.toLowerCase() == role)
      .map((credit) => credit.displayName);
  final purchase =
      personal?.purchaseDateParts ?? _parts(personal?.purchaseDate);
  final cleaned = personal?.details.lastCleanedDateParts ??
      _parts(personal?.details.lastCleanedDate);
  final added = _parts(entry?.createdAt ?? context.addedAt);
  final modified = _parts(entry?.updatedAt ?? context.updatedAt);
  final played = _parts(dto.lastListened);
  return switch (field) {
    MusicGroupingField.hasBack => _yesNo(imageTypes.contains('back_cover')),
    MusicGroupingField.hasFront => _yesNo(imageTypes.contains('front_cover')),
    MusicGroupingField.imageType => imageTypes,
    MusicGroupingField.artist => album.artistCredits.isNotEmpty
        ? album.artistCredits.map((credit) => credit.creditedName)
        : dto.artist,
    MusicGroupingField.format => album.formatSummary,
    MusicGroupingField.genre => album.genres,
    MusicGroupingField.publisher => album.publisher,
    MusicGroupingField.originalReleaseDate =>
      album.originalReleaseDateParts?.isoString,
    MusicGroupingField.originalReleaseMonth =>
      _month(album.originalReleaseDateParts),
    MusicGroupingField.originalReleaseYear =>
      album.originalReleaseDateParts?.year,
    MusicGroupingField.recordingDate => album.recordingDateParts?.isoString,
    MusicGroupingField.recordingMonth => _month(album.recordingDateParts),
    MusicGroupingField.recordingYear => album.recordingDateParts?.year,
    MusicGroupingField.releaseDate => album.releaseDateParts?.isoString,
    MusicGroupingField.releaseMonth => _month(album.releaseDateParts),
    MusicGroupingField.releaseYear => album.releaseDateParts?.year,
    MusicGroupingField.boxSet => album.boxSet,
    MusicGroupingField.country => album.countryCode,
    MusicGroupingField.extra => album.extra?.split('||'),
    MusicGroupingField.instrument =>
      album.contributions.expand((credit) => _split(credit.instrument)),
    MusicGroupingField.isLive => _yesNo(album.isLive == true),
    MusicGroupingField.mediaCondition => personal?.mediaCondition,
    MusicGroupingField.condition => personal?.condition,
    MusicGroupingField.packaging => album.packaging,
    MusicGroupingField.rpm =>
      album.discs.map((disc) => disc.rpm).whereType<String>(),
    MusicGroupingField.spars => album.sparsCode,
    MusicGroupingField.sound =>
      album.discs.expand((disc) => disc.soundTypes),
    MusicGroupingField.storage =>
      personal?.details.media.map((disc) => disc.storageDevice),
    MusicGroupingField.studio => album.studios,
    MusicGroupingField.vinylColor =>
      album.discs.map((disc) => disc.color).whereType<String>(),
    MusicGroupingField.chorus => names('chorus'),
    MusicGroupingField.composer => names('composer'),
    MusicGroupingField.composition => names('composition'),
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
    MusicGroupingField.played => _yesNo((dto.listenCount ?? 0) > 0),
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
