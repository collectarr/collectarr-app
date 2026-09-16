import 'package:flutter/foundation.dart';

import 'library_entity_scope.dart';

@immutable
final class ProviderEntityIdentity {
  const ProviderEntityIdentity({
    required this.provider,
    required this.externalId,
    required this.scope,
  });

  final String provider;
  final String externalId;
  final LibraryEntityScope scope;

  bool get isValid =>
      provider.trim().isNotEmpty && externalId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderEntityIdentity &&
          provider == other.provider &&
          externalId == other.externalId &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(provider, externalId, scope);
}
