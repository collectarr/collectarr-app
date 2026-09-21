import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/registry/provider_typed_correction_values.dart';
import 'package:collectarr_app/features/providers/transport/provider_patch.dart';

final class MovieProviderCorrectionPatch
    implements CommonProviderCorrectionPatch {
  const MovieProviderCorrectionPatch({
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

  factory MovieProviderCorrectionPatch.fromCandidates({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    final before = requireProviderKindMetadata<MovieCatalogMetadata>(preview);
    final after = requireProviderKindMetadata<MovieCatalogMetadata>(edited);
    return MovieProviderCorrectionPatch(
      title: providerStringPatch(preview.title, edited.title),
      synopsis: providerStringPatch(preview.synopsis, edited.synopsis),
      coverImageUrl:
          providerStringPatch(preview.coverImageUrl, edited.coverImageUrl),
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
      releaseDate: providerDatePatch(before.releaseDate, after.releaseDate),
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
