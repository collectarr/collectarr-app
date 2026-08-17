import 'package:flutter/foundation.dart';

@immutable
class BggCredentials {
  const BggCredentials({
    this.apiToken,
  });

  /// Optional BGG API token.
  final String? apiToken;

  bool get isValid => apiToken != null && apiToken!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {'api_token': apiToken};

  factory BggCredentials.fromJson(Map<String, dynamic> json) => BggCredentials(
        apiToken: json['api_token']?.toString(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BggCredentials &&
          runtimeType == other.runtimeType &&
          apiToken == other.apiToken;

  @override
  int get hashCode => apiToken.hashCode;
}
