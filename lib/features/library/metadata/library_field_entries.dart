import 'package:flutter/foundation.dart';

enum LibraryFieldEntryPolicy {
  canonicalMetadata,
  personalLibrary,
  syncablePersonal,
}

@immutable
class PersonalLibraryFieldSpec {
  const PersonalLibraryFieldSpec({
    required this.key,
    required this.label,
    required this.group,
    this.syncable = false,
  });

  final String key;
  final String label;
  final String group;
  final bool syncable;
}
