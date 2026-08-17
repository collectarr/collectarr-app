import 'package:flutter/foundation.dart';

@immutable
class ComicVineCredentials {
  const ComicVineCredentials({
    required this.apiKey,
  });

  final String apiKey;

  bool get isValid => apiKey.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {'api_key': apiKey};

  factory ComicVineCredentials.fromJson(Map<String, dynamic> json) =>
      ComicVineCredentials(
        apiKey: json['api_key']?.toString() ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicVineCredentials &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey;

  @override
  int get hashCode => apiKey.hashCode;
}
