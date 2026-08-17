import 'package:flutter/foundation.dart';

@immutable
class ProviderProvenance {
  const ProviderProvenance({
    required this.fetchedAt,
    this.sourceUrl,
    this.rawPayloadHash,
    this.providerVersion,
  });

  final String fetchedAt;
  final String? sourceUrl;
  final String? rawPayloadHash;
  final String? providerVersion;

  factory ProviderProvenance.fromJson(Map<String, dynamic> json) {
    return ProviderProvenance(
      fetchedAt: json['fetched_at']?.toString() ?? '',
      sourceUrl: json['source_url']?.toString(),
      rawPayloadHash: json['raw_payload_hash']?.toString(),
      providerVersion: json['provider_version']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fetched_at': fetchedAt,
      'source_url': sourceUrl,
      'raw_payload_hash': rawPayloadHash,
      'provider_version': providerVersion,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderProvenance &&
          runtimeType == other.runtimeType &&
          fetchedAt == other.fetchedAt &&
          sourceUrl == other.sourceUrl &&
          rawPayloadHash == other.rawPayloadHash &&
          providerVersion == other.providerVersion;

  @override
  int get hashCode => Object.hash(
        fetchedAt,
        sourceUrl,
        rawPayloadHash,
        providerVersion,
      );
}
