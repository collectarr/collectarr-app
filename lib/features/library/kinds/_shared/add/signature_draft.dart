import 'package:flutter/foundation.dart';

@immutable
final class SignatureDraft {
  const SignatureDraft({this.signedBy});

  final String? signedBy;
}
