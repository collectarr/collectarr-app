import 'package:flutter/foundation.dart';

/// Structural relation exposed by a provider search result.
///
/// Providers may return a concrete result below another provider entity. The
/// owning kind decides what that parent means; the shared provider transport
/// only preserves its stable identity and display title.
@immutable
class ProviderSearchParentHint {
  const ProviderSearchParentHint({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ProviderSearchParentHint.fromJson(Map<String, dynamic> json) {
    return ProviderSearchParentHint(
      id: json['id']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  bool get isValid => id.isNotEmpty && title.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderSearchParentHint &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => Object.hash(id, title);
}
