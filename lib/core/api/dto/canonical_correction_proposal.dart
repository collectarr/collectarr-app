import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// The provider-independent proposal returned by Core after a canonical
/// correction is accepted for review.
final class CanonicalCorrectionProposal {
  const CanonicalCorrectionProposal({
    required this.id,
    required this.kind,
    required this.entityType,
    required this.entityId,
    required this.scope,
    required this.baseRevision,
    required this.baseHash,
    required this.proposedFields,
    required this.status,
  });

  final String id;
  final CatalogMediaKind kind;
  final String entityType;
  final String entityId;
  final String scope;
  final String? baseRevision;
  final String? baseHash;
  final Map<String, dynamic> proposedFields;
  final String status;

  factory CanonicalCorrectionProposal.fromJson(Map<String, dynamic> json) {
    final rawFields = json['proposed_fields'];
    return CanonicalCorrectionProposal(
      id: json['id']?.toString() ?? '',
      kind: catalogMediaKindFromApiValue(json['kind']?.toString()),
      entityType: json['entity_type']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      scope: json['scope']?.toString() ?? '',
      baseRevision: json['base_revision']?.toString(),
      baseHash: json['base_hash']?.toString(),
      proposedFields: rawFields is Map
          ? <String, dynamic>{
              for (final entry in rawFields.entries)
                entry.key.toString(): entry.value,
            }
          : const <String, dynamic>{},
      status: json['status']?.toString() ?? '',
    );
  }
}
