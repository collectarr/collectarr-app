import 'package:flutter/foundation.dart';

@immutable
class SignatureDetails {
  const SignatureDetails({
    this.signedBy,
  });

  final String? signedBy;

  Map<String, dynamic> toJson() => {
        if (signedBy != null) 'signed_by': signedBy,
      };

  factory SignatureDetails.fromJson(Map<String, dynamic> json) {
    return SignatureDetails(
      signedBy: json['signed_by'] as String?,
    );
  }

  SignatureDetails copyWith({
    String? signedBy,
  }) {
    return SignatureDetails(
      signedBy: signedBy ?? this.signedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignatureDetails &&
          runtimeType == other.runtimeType &&
          signedBy == other.signedBy;

  @override
  int get hashCode => signedBy.hashCode;
}
