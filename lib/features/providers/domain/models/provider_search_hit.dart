import 'package:flutter/foundation.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_parent_hint.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';

@immutable
class ProviderSearchHit {
  const ProviderSearchHit({
    required this.providerId,
    required this.kind,
    required this.remoteId,
    required this.title,
    required this.entityScope,
    required this.searchRole,
    this.subtitle,
    this.imageUrl,
    this.parent,
  });

  final ProviderId providerId;
  final CatalogMediaKind kind;
  final String remoteId;
  final String title;
  final LibraryEntityScope entityScope;
  final ProviderSearchRole searchRole;
  final String? subtitle;
  final String? imageUrl;
  final ProviderSearchParentHint? parent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderSearchHit &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          kind == other.kind &&
          remoteId == other.remoteId &&
          title == other.title &&
          entityScope == other.entityScope &&
          searchRole == other.searchRole &&
          subtitle == other.subtitle &&
          imageUrl == other.imageUrl &&
          parent == other.parent;

  @override
  int get hashCode => Object.hash(
        providerId,
        kind,
        remoteId,
        title,
        entityScope,
        searchRole,
        subtitle,
        imageUrl,
        parent,
      );
}
