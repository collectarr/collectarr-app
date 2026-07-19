import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';

/// Builds the [LibraryCardPresentation] for a music workspace entry.
///
/// [musicVertical] selects between the album-grid layout (true) and the
/// horizontal tracklist-style layout (false).
LibraryCardPresentation buildMusicCardPresentation(
  LibraryWorkspaceEntry entry, {
  required bool musicVertical,
}) {
  return LibraryCardPresentation(
    cardVariant: musicVertical
        ? LibraryCardVariant.musicVertical
        : LibraryCardVariant.musicHorizontal,
    compactBadges: const [],
  );
}

// ---------------------------------------------------------------------------
// Shared helpers used by the generic card for the music layouts.
// Kept here so the generic card does not need to know about music domain.
// ---------------------------------------------------------------------------

/// Returns the primary artist name for a music entry.
String? musicCardArtist(LibraryWorkspaceEntry entry) {
  final creators = entry.creators ?? const <Map<String, dynamic>>[];
  String? fallbackName;
  for (final creator in creators) {
    final rawName =
        (creator['name'] ?? creator['display_name'] ?? '').toString().trim();
    if (rawName.isEmpty) continue;
    fallbackName ??= rawName;
    final role =
        (creator['role'] ?? creator['type'] ?? '').toString().toLowerCase();
    if (role.contains('artist') ||
        role.contains('performer') ||
        role.contains('musician') ||
        role.contains('band')) {
      return rawName;
    }
  }
  final publisher = entry.publisher?.trim();
  if (publisher != null && publisher.isNotEmpty) {
    return publisher;
  }
  return fallbackName;
}

/// Returns a formatted duration string for the album.
String? musicCardDuration(LibraryWorkspaceEntry entry) {
  final runtimeFact = _metadataFactValue(
    _metadataPresentationForEntry(entry),
    'Runtime',
  );
  if (runtimeFact != null && runtimeFact.isNotEmpty) {
    return runtimeFact;
  }
  final totalSeconds = entry.music?.tracks.fold<int>(
    0,
    (sum, track) => sum + (track.durationSeconds ?? 0),
  );
  if (totalSeconds == null || totalSeconds <= 0) {
    return null;
  }
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Returns the track count for the album.
int? musicCardTrackCount(LibraryWorkspaceEntry entry) {
  return entry.music?.trackCount ??
      int.tryParse(
        _metadataFactValue(
              _metadataPresentationForEntry(entry),
              'Tracks',
            ) ??
            '',
      );
}

LibraryMetadataPresentation? _metadataPresentationForEntry(
  LibraryWorkspaceEntry entry,
) {
  final type = collectarrLibraryTypes.byKind(entry.mediaType);
  if (type == null) return null;
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
}

String? _metadataFactValue(
  LibraryMetadataPresentation? presentation,
  String label,
) {
  if (presentation == null) return null;
  for (final fact in presentation.allFacts) {
    if (fact.label == label) {
      final value = fact.value.trim();
      if (value.isNotEmpty && value != '-') {
        return value;
      }
    }
  }
  return null;
}
