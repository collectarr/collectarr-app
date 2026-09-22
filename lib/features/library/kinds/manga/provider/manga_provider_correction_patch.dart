import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/registry/provider_typed_correction_values.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

final class MangaProviderCorrectionPatch implements ProviderCorrectionPatch {
  const MangaProviderCorrectionPatch({
    required this.title,
    required this.synopsis,
    required this.coverImageUrl,
    required this.publisher,
    required this.barcode,
    required this.physicalFormat,
    required this.physicalFormatLabel,
    required this.editionTitle,
    required this.itemNumber,
    required this.variant,
    required this.releaseDate,
  });

  factory MangaProviderCorrectionPatch.fromCandidates({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    final before = requireProviderKindMetadata<MangaMetadata>(preview);
    final after = requireProviderKindMetadata<MangaMetadata>(edited);
    return MangaProviderCorrectionPatch(
      title: providerStringPatch(preview.title, edited.title),
      synopsis: providerStringPatch(
          preview.editMetadata.synopsis, edited.editMetadata.synopsis),
      coverImageUrl: providerStringPatch(preview.editMetadata.coverImageUrl,
          edited.editMetadata.coverImageUrl),
      publisher: providerStringPatch(before.publisher, after.publisher),
      barcode: providerStringPatch(before.barcode, after.barcode),
      physicalFormat: providerStringPatch(
        before.physicalFormat,
        after.physicalFormat,
      ),
      physicalFormatLabel: providerStringPatch(
        before.physicalFormatLabel,
        after.physicalFormatLabel,
      ),
      editionTitle: providerStringPatch(
        before.editionTitle,
        after.editionTitle,
      ),
      itemNumber: providerStringPatch(before.itemNumber, after.itemNumber),
      variant: providerStringPatch(before.variant, after.variant),
      releaseDate: providerDatePatch(
        before.localizedReleaseDate ?? before.originalPublicationDate,
        after.localizedReleaseDate ?? after.originalPublicationDate,
      ),
    );
  }

  final ProviderPatch<String> title;
  final ProviderPatch<String> synopsis;
  final ProviderPatch<String> coverImageUrl;
  final ProviderPatch<String> publisher;
  final ProviderPatch<String> barcode;
  final ProviderPatch<String> physicalFormat;
  final ProviderPatch<String> physicalFormatLabel;
  final ProviderPatch<String> editionTitle;
  final ProviderPatch<String> itemNumber;
  final ProviderPatch<String> variant;
  final ProviderPatch<DateTime> releaseDate;

  @override
  bool get isEmpty => [
        title,
        synopsis,
        coverImageUrl,
        publisher,
        barcode,
        physicalFormat,
        physicalFormatLabel,
        editionTitle,
        itemNumber,
        variant,
        releaseDate,
      ].every(providerPatchIsUnchanged);
}

Map<String, Object?> encodeMangaProviderCorrectionsForWire(
  ProviderCorrectionPatch patch,
) {
  if (patch is EmptyProviderCorrectionPatch) {
    return const <String, Object?>{};
  }
  if (patch is! MangaProviderCorrectionPatch) {
    throw StateError('Manga correction encoder received ${patch.runtimeType}.');
  }
  return encodeChangedProviderPatchFields([
    providerPatchWireField('title', patch.title),
    providerPatchWireField('synopsis', patch.synopsis),
    providerPatchWireField('cover_image_url', patch.coverImageUrl),
    providerPatchWireField('publisher', patch.publisher),
    providerPatchWireField('barcode', patch.barcode),
    providerPatchWireField('physical_format', patch.physicalFormat),
    providerPatchWireField('physical_format_label', patch.physicalFormatLabel),
    providerPatchWireField('edition_title', patch.editionTitle),
    providerPatchWireField('item_number', patch.itemNumber),
    providerPatchWireField('variant', patch.variant),
    providerPatchWireField(
      'release_date',
      patch.releaseDate,
      encode: (value) => value.toUtc().toIso8601String(),
    ),
  ]);
}
