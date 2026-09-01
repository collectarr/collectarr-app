import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

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
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final variant = adapter?.variant;
    final barcode = adapter?.barcode;
    final publisher = adapter?.publisher;
    final releaseDate = adapter?.releaseDate;

    final kindMetadata = item.source.catalogItem?.kindMetadata;
    final metadata = kindMetadata is GameCatalogMetadata ? kindMetadata : null;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (variant != null)
          LibraryDetailField(
              label: releaseFields.variantLabel,
              value: variant,
              onTap: tapFor(variant)),
        if (barcode != null)
          LibraryDetailField(label: releaseFields.barcodeLabel, value: barcode),
        if (metadata?.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: metadata!.ageRating!),
      ],
      contextFacts: [
        if (publisher != null)
          LibraryDetailField(
              label: mediaFields.publisherLabel,
              value: publisher,
              onTap: tapFor(publisher)),
        if (releaseDate != null)
          LibraryDetailField(
            label: 'Released',
            value: formatPresentationNullableDate(releaseDate) ??
                releaseDate.year.toString(),
          ),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: metadata?.creators ?? const <Map<String, dynamic>>[],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: metadata?.genres ?? const <String>[],
        ),
      },
    );
  }
}
