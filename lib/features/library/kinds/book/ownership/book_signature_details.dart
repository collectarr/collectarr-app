import 'package:flutter/foundation.dart';

@immutable
final class BookSignatureDetails {
  const BookSignatureDetails({this.signedBy});

  final String? signedBy;

  Map<String, dynamic> toJson() => {
        if (signedBy != null) 'signed_by': signedBy,
      };

  factory BookSignatureDetails.fromJson(Map<String, dynamic> json) {
    return BookSignatureDetails(signedBy: json['signed_by'] as String?);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookSignatureDetails && signedBy == other.signedBy;

  @override
  int get hashCode => signedBy.hashCode;
}
