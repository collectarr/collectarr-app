import 'package:flutter/foundation.dart';

@immutable
class TmdbCredentials {
  const TmdbCredentials({
    this.readAccessToken,
    this.apiKey,
  });

  /// TMDb v4 Read Access Token (recommended / preferred bearer token).
  final String? readAccessToken;

  /// TMDb v3 API Key (legacy fallback).
  final String? apiKey;

  bool get isValid =>
      (readAccessToken != null && readAccessToken!.trim().isNotEmpty) ||
      (apiKey != null && apiKey!.trim().isNotEmpty);

  Map<String, dynamic> toJson() => {
        'read_access_token': readAccessToken,
        'api_key': apiKey,
      };

  factory TmdbCredentials.fromJson(Map<String, dynamic> json) =>
      TmdbCredentials(
        readAccessToken: json['read_access_token']?.toString(),
        apiKey: json['api_key']?.toString(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TmdbCredentials &&
          runtimeType == other.runtimeType &&
          readAccessToken == other.readAccessToken &&
          apiKey == other.apiKey;

  @override
  int get hashCode => Object.hash(readAccessToken, apiKey);
}
