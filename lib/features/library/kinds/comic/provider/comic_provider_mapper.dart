import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'comic_provider_correction_patch.dart';

class ComicLibraryKindProviderMapper {
  const ComicLibraryKindProviderMapper();

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return ComicProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
