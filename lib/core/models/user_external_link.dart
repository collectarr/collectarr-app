import 'package:collectarr_app/core/models/library_entry_projection.dart';

final class UserExternalLink {
  UserExternalLink({
    required this.id,
    required this.libraryEntryRef,
    required this.label,
    required this.url,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final LibraryEntryRef libraryEntryRef;
  final String label;
  final String url;
  final String kind;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTrailer => kind == 'trailer';

  UserExternalLink copyWith({
    String? id,
    LibraryEntryRef? libraryEntryRef,
    String? label,
    String? url,
    String? kind,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserExternalLink(
      id: id ?? this.id,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      label: label ?? this.label,
      url: url ?? this.url,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'library_entry_ref': libraryEntryRef.toJson(),
        'label': label,
        'url': url,
        'kind': kind,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  factory UserExternalLink.fromJson(Map<String, Object?> json) {
    final rawRef = json['library_entry_ref'];
    if (rawRef is! Map) {
      throw const FormatException(
          'User external link requires library_entry_ref.');
    }
    return UserExternalLink(
      id: json['id'] as String,
      libraryEntryRef: LibraryEntryRef.fromJson(
        Map<String, Object?>.from(rawRef),
      ),
      label: json['label'] as String,
      url: json['url'] as String,
      kind: json['kind'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
