import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

class GameLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const GameLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final gameEntry = entry as GameWorkspaceEntry;
    final referenceRelease = _resolvePrimaryGameRelease(gameEntry.gameReleases);
    final referencePlatforms =
        _gameReferencePlatforms(gameEntry, referenceRelease);
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryInspectorFactData('Kind', singularLabel),
          LibraryInspectorFactData('ID', entry.id),
          LibraryInspectorFactData('Title', entry.title),
        ],
        if (entry.variant != null)
          LibraryInspectorFactData(
            releaseFields.variantLabel,
            entry.variant!,
            onTap: tapFor(entry.variant),
          ),
        if (entry.barcode != null)
          LibraryInspectorFactData(releaseFields.barcodeLabel, entry.barcode!),
        if (entry.ageRating != null)
          LibraryInspectorFactData('Age Rating', entry.ageRating!),
      ],
      contextFacts: [
        if (referencePlatforms.isNotEmpty)
          LibraryInspectorFactData(
            referencePlatforms.length == 1 ? 'Platform' : 'Platforms',
            referencePlatforms.join(', '),
          ),
        if (entry.publisher != null)
          LibraryInspectorFactData(
            mediaFields.publisherLabel,
            entry.publisher!,
            onTap: tapFor(entry.publisher),
          ),
        LibraryInspectorFactData(
          'Released',
          genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          ),
        ),
        if (entry.country != null)
          LibraryInspectorFactData('Country', entry.country!),
        if (entry.language != null)
          LibraryInspectorFactData('Language', entry.language!),
        if (entry.audienceRating != null)
          LibraryInspectorFactData('Audience Rating', entry.audienceRating!),
        LibraryInspectorFactData(
            'Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
        LibraryInspectorFactData(
          'Metadata',
          entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
      ],
      creators: entry.creators ?? const <Map<String, dynamic>>[],
      characters: entry.characters ?? const <String>[],
      storyArcs: entry.storyArcs ?? const <String>[],
      genres: entry.genres ?? const <String>[],
    );
  }
}

GameRelease? _resolvePrimaryGameRelease(List<GameRelease> releases) {
  for (final release in releases) {
    if (release.isPrimary) {
      return release;
    }
  }
  return releases.isEmpty ? null : releases.first;
}

List<String> _gameReferencePlatforms(
  GameWorkspaceEntry entry,
  GameRelease? referenceRelease,
) {
  final values = <String>[];
  for (final platform in entry.game?.platforms ?? const <String>[]) {
    final normalized = platform.trim();
    if (normalized.isNotEmpty && !values.contains(normalized)) {
      values.add(normalized);
    }
  }
  final releasePlatform = referenceRelease?.platform?.trim();
  if (releasePlatform != null &&
      releasePlatform.isNotEmpty &&
      !values.contains(releasePlatform)) {
    values.add(releasePlatform);
  }
  return values;
}
