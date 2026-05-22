import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/library_display.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

class GameLibraryMediaPresentationBuilder
    extends DefaultLibraryMediaPresentationBuilder {
  const GameLibraryMediaPresentationBuilder();

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryMediaFieldLabels labels,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    return LibraryMetadataPresentation(
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryInspectorFactData('Kind', singularLabel),
          LibraryInspectorFactData('ID', entry.id),
          LibraryInspectorFactData('Title', entry.title),
        ],
        if (entry.variant != null)
          LibraryInspectorFactData(
            labels.variant,
            entry.variant!,
            onTap: tapFor(entry.variant),
          ),
        if (entry.barcode != null)
          LibraryInspectorFactData(labels.barcode, entry.barcode!),
        if (entry.ageRating != null)
          LibraryInspectorFactData('Age Rating', entry.ageRating!),
      ],
      contextFacts: [
        if (entry.platforms != null && entry.platforms!.isNotEmpty)
          LibraryInspectorFactData('Platforms', entry.platforms!.join(', ')),
        if (entry.publisher != null)
          LibraryInspectorFactData(
            labels.publisher,
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
        LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
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