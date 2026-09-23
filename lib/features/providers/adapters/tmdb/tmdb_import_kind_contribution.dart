import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_import_service.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';

/// Kind-owned semantic contribution for the TMDb account/file import.
///
/// TMDb owns the HTTP protocol, native import row and enrichment payload. A
/// media kind owns the decision about what that payload means in its domain
/// and how a local transport candidate is produced for the generic import
/// host. The candidate is the explicit catalog transport boundary; it is not
/// a canonical cross-kind catalog aggregate.
abstract interface class TmdbImportKindContribution {
  CatalogMediaKind get kind;

  bool accepts(TmdbImportEntry entry);

  CatalogSearchCandidate localSyntheticCatalogItem(TmdbImportEntry entry);

  CatalogSearchCandidate localSyntheticSeasonCatalogItem(
    TmdbImportEntry seriesEntry,
    TmdbImportEntry seasonEntry,
  );

  CatalogSearchCandidate mergeMatchedCatalogItem(
    CatalogSearchCandidate item,
    TmdbImportEntry entry,
  );

  bool hasMeaningfulChanges(
    CatalogSearchCandidate current,
    CatalogSearchCandidate next,
  );

  ProviderPersonalEntry personalEntryFor(TmdbImportEntry entry);

  AdminProviderPreview providerPreviewFromEnvelope(
    ProviderRawEnvelope envelope,
  );
}

final _tmdbImportContributions =
    <CatalogMediaKind, TmdbImportKindContribution>{};

void registerTmdbImportKindContribution(
  TmdbImportKindContribution contribution,
) {
  final previous = _tmdbImportContributions[contribution.kind];
  if (previous != null && !identical(previous, contribution)) {
    throw StateError(
      'Duplicate TMDb import contribution for '
      '${contribution.kind.apiValue}.',
    );
  }
  _tmdbImportContributions[contribution.kind] = contribution;
}

TmdbImportKindContribution contributionForTmdbImportKind(
  CatalogMediaKind kind,
) {
  final contribution = _tmdbImportContributions[kind];
  if (contribution == null) {
    throw StateError(
      'No TMDb import contribution is registered for ${kind.apiValue}.',
    );
  }
  return contribution;
}

TmdbImportKindContribution contributionForTmdbImportEntry(
  TmdbImportEntry entry,
) {
  for (final contribution in _tmdbImportContributions.values) {
    if (contribution.accepts(entry)) {
      return contribution;
    }
  }
  throw StateError(
    'No TMDb import contribution accepts ${entry.providerItemId}.',
  );
}

ProviderPersonalEntry providerPersonalEntryForTmdbImport(
  TmdbImportEntry entry,
) =>
    contributionForTmdbImportEntry(entry).personalEntryFor(entry);
