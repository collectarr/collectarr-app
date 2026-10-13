import 'package:flutter/foundation.dart';

@immutable
class ComicSignatureDetails {
  const ComicSignatureDetails({
    this.signedBy,
  });

  final String? signedBy;

  Map<String, dynamic> toJson() => {
        if (signedBy != null) 'signed_by': signedBy,
      };

  factory ComicSignatureDetails.fromJson(Map<String, dynamic> json) {
    return ComicSignatureDetails(
      signedBy: json['signed_by'] as String?,
    );
  }

  ComicSignatureDetails copyWith({
    String? signedBy,
  }) {
    return ComicSignatureDetails(
      signedBy: signedBy ?? this.signedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComicSignatureDetails &&
          runtimeType == other.runtimeType &&
          signedBy == other.signedBy;

  @override
  int get hashCode => signedBy.hashCode;
}
