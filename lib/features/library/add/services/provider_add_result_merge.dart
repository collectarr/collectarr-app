import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/features/providers/library_provider_registry.dart';

CatalogSearchCandidate mergeProviderAddResult({
  required CatalogSearchCandidate ingested,
  required CatalogSearchCandidate edited,
}) {
  if (ingested.summary.kind != edited.summary.kind) {
    throw ArgumentError('Cannot merge catalog candidates with different kinds.');
  }
  return libraryPresentationForKind(edited.summary.kind).builder.mergeProviderAddResult(
        ingested: ingested,
        edited: edited,
      );
}

Future<void> submitProviderIngestCorrections({
  required ApiClient api,
  required String kind,
  required String itemId,
  required ProviderCorrectionPatch corrections,
}) {
  final mediaKind = catalogMediaKindFromValue(kind);
  return api.adminUpdateCatalogItemFields(
    kind: kind,
    id: itemId,
    fields: providerCorrectionWireEncoderForKind(mediaKind)(corrections),
  );
}
