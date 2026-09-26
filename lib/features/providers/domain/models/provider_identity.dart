import 'package:flutter/foundation.dart';

@immutable
final class ProviderEntityIdentity {
  const ProviderEntityIdentity({
    required this.provider,
    required this.externalId,
  });

  final String provider;
  final String externalId;

  bool get isValid =>
      provider.trim().isNotEmpty && externalId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderEntityIdentity &&
          provider == other.provider &&
          externalId == other.externalId;

  @override
  int get hashCode => Object.hash(provider, externalId);
}
