import 'package:flutter/foundation.dart';

@immutable
final class ComicKeyDraft {
  const ComicKeyDraft({
    this.keyComic = false,
    this.keyReason,
    this.keyCategory,
    this.keySeverity,
  });

  final bool keyComic;
  final String? keyReason;
  final String? keyCategory;
  final String? keySeverity;
}
