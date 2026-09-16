import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_parent_hint.dart';

/// Structural contract consumed by the mixed Add/presentation host.
///
/// Kind semantics do not belong here. A concrete kind candidate may implement
/// this surface directly; the legacy [ProviderCandidate] is only one
/// implementation for providers that have not crossed the typed boundary yet.
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
