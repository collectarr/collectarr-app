import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_signature_details.dart';

const Object _bookDetailsUnset = Object();

@immutable
class BookOwnedDetails implements JsonEncodable {
  const BookOwnedDetails({
    this.signature = const BookSignatureDetails(),
    String? signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
  }) : _signedBy = signedBy;

  final BookSignatureDetails signature;
  final String? _signedBy;
  final bool dustJacketPresent;
  final String? dustJacketCondition;

  String? get signedBy => _signedBy ?? signature.signedBy;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (signedBy != null) 'signed_by': signedBy,
        if (dustJacketPresent) 'dust_jacket_present': true,
        if (dustJacketCondition != null)
          'dust_jacket_condition': dustJacketCondition,
      };

  factory BookOwnedDetails.fromJson(Map<String, dynamic> json) =>
      BookOwnedDetails(
        signature: BookSignatureDetails.fromJson(json),
        dustJacketPresent: json['dust_jacket_present'] as bool? ?? false,
        dustJacketCondition: json['dust_jacket_condition'] as String?,
      );

  BookOwnedDetails copyWith({
    Object? signedBy = _bookDetailsUnset,
    BookSignatureDetails? signature,
    bool? dustJacketPresent,
    String? dustJacketCondition,
  }) {
    return BookOwnedDetails(
      signedBy: identical(signedBy, _bookDetailsUnset)
          ? this.signedBy
          : signedBy as String?,
      signature: signature ?? this.signature,
      dustJacketPresent: dustJacketPresent ?? this.dustJacketPresent,
      dustJacketCondition: dustJacketCondition ?? this.dustJacketCondition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookOwnedDetails &&
          runtimeType == other.runtimeType &&
          signedBy == other.signedBy &&
          dustJacketPresent == other.dustJacketPresent &&
          dustJacketCondition == other.dustJacketCondition;

  @override
  int get hashCode => Object.hash(
        signedBy,
        dustJacketPresent,
        dustJacketCondition,
      );
}
