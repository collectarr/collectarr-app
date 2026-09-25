import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'boardgame_provider_correction_patch.dart';

class BoardGameLibraryKindProviderMapper {
  const BoardGameLibraryKindProviderMapper();

  ProviderCorrectionPatch buildCorrections({
    required CatalogSearchCandidate preview,
    required CatalogSearchCandidate edited,
  }) {
    return BoardGameProviderCorrectionPatch.fromCandidates(
      preview: preview,
      edited: edited,
    );
  }
}
