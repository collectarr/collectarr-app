import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_parent_hint.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_search_hit.dart';

/// Structural implementation shared by kind-owned provider candidates.
///
/// This base deliberately contains only identity and presentation fields that
/// the generic Add host can consume. Kind semantics belong to the concrete
/// candidate that extends it.
abstract base class ProviderSearchCandidateBase
    implements ProviderSearchCandidate {
  const ProviderSearchCandidateBase({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    this.summary,
    this.imageUrl,
    this.candidateType,
    this.parent,
    this.previewOnly = false,
    this.entityScope = LibraryEntityScope.release,
    this.identity,
  });

  @override
  final String provider;
  @override
  final String providerItemId;
  @override
  final String title;
  @override
  final CatalogMediaKind kind;
  @override
  final String? summary;
  @override
  final String? imageUrl;
  @override
  final String? candidateType;
  @override
  final ProviderSearchParentHint? parent;
  @override
  final bool previewOnly;
  @override
  final LibraryEntityScope entityScope;
  @override
  final ProviderEntityIdentity? identity;

  @override
  String get localCatalogId {
    final safeProvider = _safeIdPart(provider);
    final safeKind = _safeIdPart(kind.apiValue);
    return 'provider:$safeProvider:$safeKind:${Uri.encodeComponent(providerItemId)}';
  }

  @override
  bool get isStub =>
      providerItemId.startsWith('stub-') ||
      title.toLowerCase().contains(' stub)');
}

/// Minimal candidate used when a provider exposes only structural search hits.
/// It intentionally carries no cross-kind semantic fields.
final class ProviderSearchHitCandidate extends ProviderSearchCandidateBase {
  ProviderSearchHitCandidate.fromHit(
    ProviderSearchHit hit, {
    String? provider,
  }) : super(
          provider: provider ?? hit.providerId.value,
          providerItemId: hit.remoteId,
          title: hit.title,
          kind: hit.kind,
          summary: hit.subtitle,
          imageUrl: hit.imageUrl,
          parent: hit.parent,
          identity: ProviderEntityIdentity(
            provider: provider ?? hit.providerId.value,
            externalId: hit.remoteId,
            scope: LibraryEntityScope.release,
          ),
        );
}

/// Structural contract consumed by the mixed Add/presentation host.
///
/// Kind semantics do not belong here. A concrete kind candidate may implement
/// Kind implementations may add their own semantic fields, but those fields
/// are never part of this shared contract.
abstract interface class ProviderSearchCandidate {
  String get provider;
  String get providerItemId;
  String get title;
  CatalogMediaKind get kind;
  String? get summary;
  String? get imageUrl;
  String? get candidateType;
  ProviderSearchParentHint? get parent;
  bool get previewOnly;
  LibraryEntityScope get entityScope;
  ProviderEntityIdentity? get identity;
  String get localCatalogId;
  bool get isStub;
}

String _safeIdPart(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]+'), '-');
}
