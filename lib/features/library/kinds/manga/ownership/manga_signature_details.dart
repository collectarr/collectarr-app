import 'package:flutter/foundation.dart';

@immutable
final class MangaSignatureDetails {
  const MangaSignatureDetails({this.signedBy});

  final String? signedBy;

  Map<String, dynamic> toJson() => {
        if (signedBy != null) 'signed_by': signedBy,
      };

  factory MangaSignatureDetails.fromJson(Map<String, dynamic> json) {
    return MangaSignatureDetails(signedBy: json['signed_by'] as String?);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MangaSignatureDetails && signedBy == other.signedBy;

  @override
  int get hashCode => signedBy.hashCode;
}
