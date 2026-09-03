import 'package:flutter/foundation.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

@immutable
class ProviderSearchHit {
  const ProviderSearchHit({
    required this.providerId,
    required this.kind,
    required this.remoteId,
    required this.title,
    this.subtitle,
    this.imageUrl,
  });

  final ProviderId providerId;
  final CatalogMediaKind kind;
  final String remoteId;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderSearchHit &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          kind == other.kind &&
          remoteId == other.remoteId &&
          title == other.title &&
          subtitle == other.subtitle &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(
        providerId,
        kind,
        remoteId,
        title,
        subtitle,
        imageUrl,
      );
}
