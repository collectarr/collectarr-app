import 'package:flutter/foundation.dart';

/// Schema-v1 provider transport payload.
///
/// This is intentionally a serialization value, not a normalized catalog
/// model. Provider adapters may retain provider-specific keys here, but kind
/// integrations must decode it immediately into their concrete domain.
@immutable
final class ProviderMetadataPayload {
  const ProviderMetadataPayload(this.values);

  factory ProviderMetadataPayload.fromJson(Object? raw) {
    if (raw is! Map) {
      return const ProviderMetadataPayload(<String, dynamic>{});
    }
    return ProviderMetadataPayload({
      for (final entry in raw.entries)
        if (entry.key != null) entry.key.toString(): entry.value,
    });
  }

  final Map<String, dynamic> values;

  Object? operator [](String key) => values[key];

  bool containsKey(String key) => values.containsKey(key);

  bool get isEmpty => values.isEmpty;

  bool get isNotEmpty => values.isNotEmpty;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderMetadataPayload && mapEquals(values, other.values);

  @override
  int get hashCode => Object.hashAll(values.entries);
}
