import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/shared/library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';

class GameLibraryMediaPresentationBuilder
  extends SharedLibraryMediaPresentationBuilder {
  const GameLibraryMediaPresentationBuilder();

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final metadata = entry.metadata;
    final referenceRelease = resolveLibraryEntryReferenceRelease(entry);
    final referenceVariant = referenceRelease.variant;
    final referencePlatforms = libraryReferencePlatforms(entry);
    return LibraryMetadataPresentation(
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
        if (metadata.ageRating != null)
          LibraryInspectorFactData('Age Rating', metadata.ageRating!),
      ],
      contextFacts: [
        if (referenceVariant?.variantType case final variantType?
            when variantType.trim().isNotEmpty)
          LibraryInspectorFactData('Variant Type', variantType.trim()),
        if (referenceVariant?.sku case final sku? when sku.trim().isNotEmpty)
          LibraryInspectorFactData('SKU', sku.trim()),
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
        if (metadata.country != null)
          LibraryInspectorFactData('Country', metadata.country!),
        if (metadata.language != null)
          LibraryInspectorFactData('Language', metadata.language!),
        if (metadata.audienceRating != null)
          LibraryInspectorFactData('Audience Rating', metadata.audienceRating!),
        LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
        LibraryInspectorFactData(
          'Metadata',
          entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
      ],
      creators: metadata.creators ?? const <Map<String, dynamic>>[],
      characters: metadata.characters ?? const <String>[],
      storyArcs: metadata.storyArcs ?? const <String>[],
      genres: metadata.genres ?? const <String>[],
    );
  }
}