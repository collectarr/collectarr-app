import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/signature_details.dart';

const Object _bookDetailsUnset = Object();

@immutable
class BookOwnedDetails extends OwnedItemDetails {
  const BookOwnedDetails({
    this.signature = const SignatureDetails(),
    String? signedBy,
  }) : _signedBy = signedBy;

  final SignatureDetails signature;
  final String? _signedBy;

  String? get signedBy => _signedBy ?? signature.signedBy;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (signedBy != null) 'signed_by': signedBy,
      };

  factory BookOwnedDetails.fromJson(Map<String, dynamic> json) =>
      BookOwnedDetails(
        signature: SignatureDetails.fromJson(json),
      );

  BookOwnedDetails copyWith({
    Object? signedBy = _bookDetailsUnset,
    SignatureDetails? signature,
  }) {
    return BookOwnedDetails(
      signedBy: identical(signedBy, _bookDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      signature: signature ?? this.signature,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookOwnedDetails &&
          runtimeType == other.runtimeType &&
          signedBy == other.signedBy;

  @override
  int get hashCode => signedBy.hashCode;
}
