import 'package:flutter/foundation.dart';

@immutable
class HardcoverCredentials {
  const HardcoverCredentials({
    required this.apiKey,
  });

  final String apiKey;

  bool get isValid => apiKey.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {'api_key': apiKey};

  factory HardcoverCredentials.fromJson(Map<String, dynamic> json) =>
      HardcoverCredentials(
        apiKey: json['api_key']?.toString() ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HardcoverCredentials &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey;

  @override
  int get hashCode => apiKey.hashCode;
}
