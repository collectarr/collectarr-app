import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/registry/provider_typed_correction_values.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

final class TvProviderCorrectionPatch implements ProviderCorrectionPatch {
  const TvProviderCorrectionPatch({
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

  factory TvProviderCorrectionPatch.fromCandidates({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    final before = requireProviderKindMetadata<TvSeriesMetadata>(preview);
    final after = requireProviderKindMetadata<TvSeriesMetadata>(edited);
    return TvProviderCorrectionPatch(
      title: providerStringPatch(preview.primaryLabel, edited.primaryLabel),
      synopsis: providerStringPatch(
          preview.tvCatalogFields.synopsis, edited.tvCatalogFields.synopsis),
      coverImageUrl: providerStringPatch(preview.tvCatalogFields.coverImageUrl,
          edited.tvCatalogFields.coverImageUrl),
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
      editionTitle: const ProviderPatch.unchanged(),
      itemNumber: providerStringPatch(before.itemNumber, after.itemNumber),
      variant: providerStringPatch(before.variant, after.variant),
      releaseDate: providerDatePatch(before.firstAirDate, after.firstAirDate),
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

Map<String, Object?> encodeTvProviderCorrectionsForWire(
  ProviderCorrectionPatch patch,
) {
  if (patch is EmptyProviderCorrectionPatch) {
    return const <String, Object?>{};
  }
  if (patch is! TvProviderCorrectionPatch) {
    throw StateError('TV correction encoder received ${patch.runtimeType}.');
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
