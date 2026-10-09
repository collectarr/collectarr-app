import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';

/// Immutable query and presentation values derived once from one Music item.
///
/// Workspace group, filter, and sort callbacks should read these snapshots
/// instead of walking the album's discs and credits for every comparison.
final class MusicWorkspaceFacts {
  factory MusicWorkspaceFacts.fromAlbum(MusicAlbum album) {
    final discs = album.discs;
    final albumCredits = album.credits;
    final discCredits = [
      for (final disc in discs) ...disc.credits,
    ];
    final allCredits = [...albumCredits, ...discCredits];
    final trackCompositions = <String>{
      for (final disc in discs)
        for (final track in disc.tracks)
          if (track.composition?.trim() case final composition?)
            if (composition.isNotEmpty) composition,
    };
    final dates = <PartialDate>{
      for (final disc in discs)
        if (disc.recordingDate case final date?) date,
    };
    final byRole = <String, Set<String>>{};
    for (final credit in allCredits) {
      final role = credit.role.trim().toLowerCase();
      final name = credit.name.trim();
      if (role.isEmpty || name.isEmpty) continue;
      byRole.putIfAbsent(role, () => <String>{}).add(name);
    }
    final immutableByRole = Map<String, Set<String>>.unmodifiable({
      for (final entry in byRole.entries)
        entry.key: Set<String>.unmodifiable(entry.value),
    });
    final albumContributors = _stringSet([
      ...album.artistCredits.map((credit) => credit.creditedName),
      ...albumCredits.map((credit) => credit.name),
    ]);
    final discContributors = _stringSet(
      discCredits.map((credit) => credit.name),
    );
    final allContributors = Set<String>.unmodifiable({
      ...albumContributors,
      ...discContributors,
    });
    final artist = _primaryArtist(album);

    return MusicWorkspaceFacts._(
      formatSummary: album.formatSummary,
      primaryArtist: artist,
      discCount: discs.length,
      trackCount: discs.fold<int>(
        0,
        (count, disc) => count + disc.effectiveTrackCount,
      ),
      discFormats: _stringSet(discs.map((disc) => disc.format)),
      discFormatFamilies: Set<MusicDiscFormatFamily>.unmodifiable({
        for (final disc in discs)
          if (disc.formatFamily case final family?) family,
      }),
      discRecordingDates: Set<PartialDate>.unmodifiable(dates),
      discRecordingYears: Set<int>.unmodifiable({
        for (final date in dates)
          if (date.year case final year?) year,
      }),
      discRecordingMonths: Set<int>.unmodifiable({
        for (final date in dates)
          if (date.month case final month?) month,
      }),
      earliestDiscRecordingDate: _reduceDate(dates, latest: false),
      latestDiscRecordingDate: _reduceDate(dates, latest: true),
      discSparsCodes: _stringSet(discs.map((disc) => disc.sparsCode)),
      discSoundTypes: _stringSet(discs.expand((disc) => disc.soundTypes)),
      discColors: _stringSet(discs.map((disc) => disc.color)),
      discRpms: _stringSet(discs.map((disc) => disc.rpm)),
      recordingLocations: _stringSet(
        discs.expand((disc) => disc.recordingLocations),
      ),
      hasLiveDisc: discs.any((disc) => disc.isLive == true),
      hasStudioDisc: discs.any((disc) => disc.isLive == false),
      albumContributors: albumContributors,
      discContributors: discContributors,
      allContributors: allContributors,
      creditRoles: _stringSet(allCredits.map((credit) => credit.role)),
      creditInstruments: _stringSet(
        allCredits.expand((credit) => credit.instruments),
      ),
      trackCompositions: Set<String>.unmodifiable(trackCompositions),
      contributorsByRole: immutableByRole,
    );
  }

  const MusicWorkspaceFacts._({
    required this.formatSummary,
    required this.primaryArtist,
    required this.discCount,
    required this.trackCount,
    required this.discFormats,
    required this.discFormatFamilies,
    required this.discRecordingDates,
    required this.discRecordingYears,
    required this.discRecordingMonths,
    required this.earliestDiscRecordingDate,
    required this.latestDiscRecordingDate,
    required this.discSparsCodes,
    required this.discSoundTypes,
    required this.discColors,
    required this.discRpms,
    required this.recordingLocations,
    required this.hasLiveDisc,
    required this.hasStudioDisc,
    required this.albumContributors,
    required this.discContributors,
    required this.allContributors,
    required this.creditRoles,
    required this.creditInstruments,
    required this.trackCompositions,
    required this.contributorsByRole,
  });

  final String? formatSummary;
  final String? primaryArtist;
  final int discCount;
  final int trackCount;
  final Set<String> discFormats;
  final Set<MusicDiscFormatFamily> discFormatFamilies;
  final Set<PartialDate> discRecordingDates;
  final Set<int> discRecordingYears;
  final Set<int> discRecordingMonths;
  final PartialDate? earliestDiscRecordingDate;
  final PartialDate? latestDiscRecordingDate;
  final Set<String> discSparsCodes;
  final Set<String> discSoundTypes;
  final Set<String> discColors;
  final Set<String> discRpms;
  final Set<String> recordingLocations;
  final bool hasLiveDisc;
  final bool hasStudioDisc;
  final Set<String> albumContributors;
  final Set<String> discContributors;
  final Set<String> allContributors;
  final Set<String> creditRoles;
  final Set<String> creditInstruments;
  final Set<String> trackCompositions;
  final Map<String, Set<String>> contributorsByRole;

  Set<String> contributorsForRole(String role) =>
      contributorsByRole[role.trim().toLowerCase()] ?? const <String>{};
}

String? _primaryArtist(MusicAlbum album) {
  final explicit = _nonEmpty(album.artist);
  if (explicit != null) return explicit;
  for (final credit in album.credits) {
    final role = credit.role.toLowerCase();
    if (_isArtistRole(role)) {
      final name = _nonEmpty(credit.name);
      if (name != null) return name;
    }
  }
  return album.artistCredits.isEmpty
      ? null
      : _nonEmpty(album.artistCredits.first.creditedName);
}

bool _isArtistRole(String role) =>
    role.contains('artist') ||
    role.contains('performer') ||
    role.contains('musician') ||
    role.contains('band');

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

Set<String> _stringSet(Iterable<String?> values) => Set<String>.unmodifiable({
      for (final value in values)
        if (_nonEmpty(value) case final normalized?) normalized,
    });

PartialDate? _reduceDate(
  Iterable<PartialDate> values, {
  required bool latest,
}) {
  PartialDate? selected;
  for (final value in values) {
    if (value.year == null) continue;
    final current = selected;
    if (current == null) {
      selected = value;
      continue;
    }
    final comparison = latest
        ? _compareDateBounds(value, current, latest: true)
        : _compareDateBounds(value, current, latest: false);
    if (latest ? comparison > 0 : comparison < 0) selected = value;
  }
  return selected;
}

int _compareDateBounds(
  PartialDate left,
  PartialDate right, {
  required bool latest,
}) {
  final a = _dateBound(left, latest: latest);
  final b = _dateBound(right, latest: latest);
  final year = a.$1.compareTo(b.$1);
  if (year != 0) return year;
  final month = a.$2.compareTo(b.$2);
  if (month != 0) return month;
  return a.$3.compareTo(b.$3);
}

(int, int, int) _dateBound(PartialDate value, {required bool latest}) {
  final year = value.year!;
  final month = value.month ?? (latest ? 12 : 1);
  final day = value.day ?? (latest ? _daysInMonth(year, month) : 1);
  return (year, month, day);
}

int _daysInMonth(int year, int month) => switch (month) {
      2 => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) ? 29 : 28,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };
