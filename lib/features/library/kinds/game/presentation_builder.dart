import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';

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
    final catalogItem = item.source.catalogItem;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (dto.variant != null)
          LibraryDetailField(label: releaseFields.variantLabel, value: dto.variant!, onTap: tapFor(dto.variant)),
        if (dto.barcode != null)
          LibraryDetailField(label: releaseFields.barcodeLabel, value: dto.barcode!),
        if (catalogItem?.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: catalogItem!.ageRating!),
      ],
      contextFacts: [
        if (dto.publisher != null)
          LibraryDetailField(label: mediaFields.publisherLabel, value: dto.publisher!, onTap: tapFor(dto.publisher)),
        if (dto.releaseDate != null)
          LibraryDetailField(
            label: 'Released',
            value: formatPresentationNullableDate(dto.releaseDate) ??
                dto.releaseDate!.year.toString(),
          ),
      ],
      creators: catalogItem?.creators ?? const <Map<String, dynamic>>[],
      characters: catalogItem?.characters ?? const <String>[],
      storyArcs: catalogItem?.storyArcs ?? const <String>[],
      genres: catalogItem?.genres ?? const <String>[],
    );
  }
}
