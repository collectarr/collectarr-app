import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/game/game_domain.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
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
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: entry.id),
          LibraryDetailField(label: 'Title', value: entry.title),
        ],
        if (entry.variant != null)
          LibraryDetailField(label: releaseFields.variantLabel, value: entry.variant!, onTap: tapFor(entry.variant)),
        if (entry.barcode != null)
          LibraryDetailField(label: releaseFields.barcodeLabel, value: entry.barcode!),
        if (entry.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: entry.ageRating!),
      ],
      contextFacts: [
        if (referencePlatforms.isNotEmpty)
          LibraryDetailField(label: referencePlatforms.length == 1 ? 'Platform' : 'Platforms', value: referencePlatforms.join(', ')),
        if (entry.publisher != null)
          LibraryDetailField(label: mediaFields.publisherLabel, value: entry.publisher!, onTap: tapFor(entry.publisher)),
        LibraryDetailField(label: 'Released', value: genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          )),
        if (entry.country != null)
          LibraryDetailField(label: 'Country', value: entry.country!),
        if (entry.language != null)
          LibraryDetailField(label: 'Language', value: entry.language!),
        if (entry.audienceRating != null)
          LibraryDetailField(label: 'Audience Rating', value: entry.audienceRating!),
        LibraryDetailField(label: 'Cover', value: entry.hasMissingCover ? 'Missing' : 'Ready'),
        LibraryDetailField(label: 'Metadata', value: entry.hasMissingMetadata ? 'Missing' : 'Ready'),
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

