import 'package:flutter/foundation.dart';

@immutable
class ProviderAttribution {
  const ProviderAttribution({
    required this.required,
    this.text,
    this.url,
    this.licenseName,
  });

  final bool required;
  final String? text;
  final String? url;
  final String? licenseName;

  factory ProviderAttribution.fromJson(Map<String, dynamic> json) {
    return ProviderAttribution(
      required: json['required'] == true,
      text: json['text']?.toString(),
      url: json['url']?.toString(),
      licenseName: json['license_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'required': required,
      'text': text,
      'url': url,
      'license_name': licenseName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderAttribution &&
          runtimeType == other.runtimeType &&
          required == other.required &&
          text == other.text &&
          url == other.url &&
          licenseName == other.licenseName;

  @override
  int get hashCode => Object.hash(
        required,
        text,
        url,
        licenseName,
      );
}
