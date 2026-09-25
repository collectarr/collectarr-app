import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'manga_provider_correction_patch.dart';

class MangaLibraryKindProviderMapper {
  const MangaLibraryKindProviderMapper();

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return MangaProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
