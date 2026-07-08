import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:uuid/uuid.dart';

class LibraryAddWorkflowService {
  const LibraryAddWorkflowService();

  LibraryMetadataItem metadataItemFromPreview(AdminProviderPreview preview) {
    final series = preview.series;
    final publishing = preview.publishing;
    final music = preview.music;
    final video = preview.video;
    final game = preview.game;
    return LibraryMetadataItem(
      id: buildPreviewCatalogItemId(
        kind: preview.kind,
        provider: preview.provider,
        providerItemId: preview.providerItemId,
      ),
      kind: preview.kind,
      title: preview.title,
      itemNumber: preview.itemNumber,
      synopsis: preview.synopsis,
      coverImageUrl: preview.coverImageUrl,
      thumbnailImageUrl: preview.coverImageUrl,
      editionTitle: preview.editionTitle,
      physicalFormat: preview.physicalFormat,
      physicalFormatLabel: preview.physicalFormatLabel,
      publisher: preview.publisher,
      releaseDate: preview.releaseDate,
      releaseYear: preview.releaseDate?.year ?? preview.series?.volumeStartYear,
      barcode: preview.barcode,
      variant: preview.variantName,
      series: series,
      publishing: publishing,
      music: music,
      video: video,
      game: game,
      country: preview.country,
      language: preview.language,
      ageRating: preview.ageRating,
      audienceRating: preview.audienceRating,
      creators: [
        for (final creator in preview.creators)
          {
            'name': creator.name,
            if (creator.role != null) 'role': creator.role,
            if (creator.imageUrl != null) 'image_url': creator.imageUrl,
          },
      ],
      characters: preview.characters,
      storyArcs: preview.storyArcs,
      genres: preview.genres,
    );
  }

  String buildPreviewCatalogItemId({
    required String kind,
    required String provider,
    required String providerItemId,
  }) {
    final previewKey = '$kind:$provider:$providerItemId';
    return 'preview-$kind-${const Uuid().v5(Namespace.url.value, previewKey)}';
  }

  Future<void> addItems({
    required CatalogCacheRepository catalog,
    required CollectionMutations mutations,
    required Iterable<LibraryMetadataItem> items,
    required LibraryAddTarget target,
    LibraryAddReferenceType referenceType = LibraryAddReferenceType.media,
    LibraryAddDefaults defaults = const LibraryAddDefaults(),
    Map<String, LibraryAddOwnedDetails> ownedDetailsByItemId = const {},
    Map<String, LibraryAddEditionSelection> editionSelectionsByItemId = const {},
    Map<String, String> bundleReleaseIdsByItemId = const {},
  }) {
    return addLibraryItemsToTarget(
      catalog: catalog,
      mutations: mutations,
      items: items,
      target: target,
      referenceType: referenceType,
      defaults: defaults,
      ownedDetailsByItemId: ownedDetailsByItemId,
      editionSelectionsByItemId: editionSelectionsByItemId,
      bundleReleaseIdsByItemId: bundleReleaseIdsByItemId,
    );
  }
}
