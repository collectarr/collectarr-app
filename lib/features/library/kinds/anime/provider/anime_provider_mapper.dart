import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'anime_provider_correction_patch.dart';

class AnimeLibraryKindProviderMapper {
  const AnimeLibraryKindProviderMapper();

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return AnimeProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
