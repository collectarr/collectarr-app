import 'package:flutter/foundation.dart';

import 'provider_identity.dart';

@immutable
final class ProviderImageCandidate {
  const ProviderImageCandidate({
    required this.url,
    required this.source,
    this.role,
  });

  final Uri url;
  final ProviderEntityIdentity source;
  final String? role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderImageCandidate &&
          url == other.url &&
          source == other.source &&
          role == other.role;

  @override
  int get hashCode => Object.hash(url, source, role);
}
