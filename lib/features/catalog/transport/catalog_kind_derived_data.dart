import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';

/// Structural result of a kind-owned catalog decode.
///
/// The owning codec interprets its DTO and projects only the values required
/// by generic vocabulary/serial infrastructure. The generic catalog host does
/// not receive the decoded kind model or an erased semantic batch.
final class CatalogKindDerivedData {
  const CatalogKindDerivedData({
    required this.pickListValues,
    required this.serialCandidates,
  });

  final Iterable<PickListCatalogValues> pickListValues;
  final Iterable<SerialAuthorityCandidate> serialCandidates;
}

CatalogKindDerivedData? catalogDerivedDataFor({
  required CatalogMediaKind kind,
  required Object? metadata,
  required Iterable<PickListDefinitionContributor> pickListContributors,
  required Iterable<SerialAuthorityContributor> serialAuthorityContributors,
}) {
  if (metadata == null) return null;

  final pickListValues = <PickListCatalogValues>[];
  for (final contributor in pickListContributors) {
    if (contributor.kind == kind) {
      pickListValues.addAll(contributor.catalogValues([metadata]));
    }
  }

  final serialCandidates = <SerialAuthorityCandidate>[];
  for (final contributor in serialAuthorityContributors) {
    if (contributor.kind == kind) {
      serialCandidates.addAll(contributor.candidates([metadata]));
    }
  }

  return CatalogKindDerivedData(
    pickListValues: pickListValues,
    serialCandidates: serialCandidates,
  );
}
