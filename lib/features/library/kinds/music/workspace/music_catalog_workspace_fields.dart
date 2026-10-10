import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicCatalogWorkspaceFields {
  static Iterable<String> artistValues(MusicWorkspaceProjection dto) =>
      dto.facts.artistNames;

  static String? publisherValue(MusicWorkspaceProjection dto) =>
      dto.music.publisher;

  static Iterable<String> genreValues(MusicWorkspaceProjection dto) =>
      dto.music.genres;

  static Iterable<String> discFormatValues(MusicWorkspaceProjection dto) =>
      dto.facts.discFormats;

  static String? countryValue(MusicWorkspaceProjection dto) =>
      dto.music.countryCode;

  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    metadata: MusicFieldIdentities.title,
    getValue: (dto) => dto.common.title,
  );

  static final artist = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.artist,
    metadata: MusicFieldIdentities.artist,
    getValue: (context) => artistValues(context.dto),
  );

  static final artistSummary = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artistSummary,
    metadata: MusicFieldIdentities.artistSummary,
    getValue: (dto) => dto.music.artist ?? dto.facts.primaryArtist,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    metadata: MusicFieldIdentities.publisher,
    getValue: publisherValue,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.barcode,
    metadata: MusicFieldIdentities.barcode,
    getValue: (dto) => dto.music.barcode,
  );

  static final catalogNumber = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.catalogNumber,
    metadata: MusicFieldIdentities.catalogNumber,
    getValue: (dto) => dto.music.catalogNumber,
  );

  static final genre = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.genre,
    metadata: MusicFieldIdentities.genre,
    getValue: (context) => genreValues(context.dto),
  );

  static final formatSummary = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.formatSummary,
    metadata: MusicFieldIdentities.formatSummary,
    getValue: (dto) => dto.facts.formatSummary,
  );

  static final discFormat = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.discFormat,
    metadata: MusicFieldIdentities.discFormat,
    getValue: (context) => discFormatValues(context.dto),
  );

  static final discFormatFamily = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.discFormatFamily,
    metadata: MusicWorkspaceFieldMetadata.discFormatFamily,
    getValue: (context) =>
        context.dto.facts.discFormatFamilies.map((family) => family.value),
  );

  static final recordingDate = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<PartialDate>>(
    id: MusicFieldIds.recordingDate,
    metadata: MusicWorkspaceFieldMetadata.recordingDate,
    getValue: (context) => context.dto.facts.discRecordingDates,
  );

  static final recordingMonth = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<int>>(
    id: MusicFieldIds.recordingMonth,
    metadata: MusicWorkspaceFieldMetadata.recordingMonth,
    getValue: (context) => context.dto.facts.discRecordingMonths,
  );

  static final recordingYear = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<int>>(
    id: MusicFieldIds.recordingYear,
    metadata: MusicWorkspaceFieldMetadata.recordingYear,
    getValue: (context) => context.dto.facts.discRecordingYears,
  );

  static final earliestDiscRecordingDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, PartialDate?>(
    id: MusicFieldIds.earliestDiscRecordingDate,
    metadata: MusicWorkspaceFieldMetadata.earliestDiscRecordingDate,
    getValue: (context) => context.dto.facts.earliestDiscRecordingDate,
  );

  static final latestDiscRecordingDate =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, PartialDate?>(
    id: MusicFieldIds.latestDiscRecordingDate,
    metadata: MusicWorkspaceFieldMetadata.latestDiscRecordingDate,
    getValue: (context) => context.dto.facts.latestDiscRecordingDate,
  );

  static final liveStudio = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<bool>>(
    id: MusicFieldIds.liveStudio,
    metadata: MusicWorkspaceFieldMetadata.isLive,
    getValue: (context) => {
      if (context.dto.facts.hasLiveDisc) true,
      if (context.dto.facts.hasStudioDisc) false,
    },
  );

  static final recordingLocation = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.recordingLocation,
    metadata: MusicWorkspaceFieldMetadata.recordingLocations,
    getValue: (context) => context.dto.facts.recordingLocations,
  );

  static final discSpars = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.discSpars,
    metadata: MusicWorkspaceFieldMetadata.spars,
    getValue: (context) => context.dto.facts.discSparsCodes,
  );

  static final discSound = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.discSound,
    metadata: MusicWorkspaceFieldMetadata.sound,
    getValue: (context) => context.dto.facts.discSoundTypes,
  );

  static final discColor = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.discColor,
    metadata: MusicWorkspaceFieldMetadata.vinylColor,
    getValue: (context) => context.dto.facts.discColors,
  );

  static final discRpm = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.discRpm,
    metadata: MusicWorkspaceFieldMetadata.rpm,
    getValue: (context) => context.dto.facts.discRpms,
  );

  static final creditContributor = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.creditContributor,
    metadata: MusicWorkspaceFieldMetadata.creditContributor,
    getValue: (context) => context.dto.facts.allContributors,
  );

  static final creditRole = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.creditRole,
    metadata: MusicWorkspaceFieldMetadata.creditRole,
    getValue: (context) => context.dto.facts.creditRoles,
  );

  static final creditInstrument = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.creditInstrument,
    metadata: MusicWorkspaceFieldMetadata.creditInstrument,
    getValue: (context) => context.dto.facts.creditInstruments,
  );

  static final trackComposition = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.trackComposition,
    metadata: MusicWorkspaceFieldMetadata.trackComposition,
    getValue: (context) => context.dto.facts.trackCompositions,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    metadata: MusicFieldIdentities.releaseDate,
    getValue: (dto) => dto.music.releaseDate,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    metadata: MusicWorkspaceFieldMetadata.trackCount,
    getValue: (dto) => dto.facts.trackCount,
  );

  static final discCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.discCount,
    metadata: MusicWorkspaceFieldMetadata.discCount,
    getValue: (dto) => dto.facts.discCount,
  );

  static final length = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.length,
    metadata: MusicWorkspaceFieldMetadata.length,
    getValue: (dto) {
      final totalDurationMs = dto.music.tracks.fold<int>(
        0,
        (total, track) => total + (track.durationMs ?? 0),
      );
      final totalSeconds = totalDurationMs == 0 ? null : (totalDurationMs / 1000).round();
      if (totalSeconds == null || totalSeconds <= 0) return null;
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;
      if (hours > 0) {
        return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    },
  );

  static final country = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.country,
    metadata: MusicFieldIdentities.country,
    getValue: countryValue,
  );

  static final packaging = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.packaging,
    metadata: MusicFieldIdentities.packaging,
    getValue: (dto) => dto.music.packaging,
  );

  static final boxSet = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.boxSet,
    metadata: MusicFieldIdentities.boxSet,
    getValue: (dto) => dto.music.boxSet,
  );

  static final all =
      <LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, Object?>>[
    title,
    artist,
    artistSummary,
    publisher,
    barcode,
    catalogNumber,
    genre,
    formatSummary,
    discFormat,
    discFormatFamily,
    recordingDate,
    recordingMonth,
    recordingYear,
    earliestDiscRecordingDate,
    latestDiscRecordingDate,
    liveStudio,
    recordingLocation,
    discSpars,
    discSound,
    discColor,
    discRpm,
    creditContributor,
    creditRole,
    creditInstrument,
    trackComposition,
    releaseDate,
    discCount,
    trackCount,
    length,
    country,
    packaging,
    boxSet,
  ];
}
