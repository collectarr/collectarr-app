import 'package:collectarr_app/features/library/config/presentation/library_alphabet_field.dart';
import 'package:flutter/foundation.dart';

class LibraryAlphabetOptions {
  const LibraryAlphabetOptions(
      {required this.fields, required this.selected, required this.onChanged});
  final List<LibraryAlphabetField> fields;
  final LibraryAlphabetField selected;
  final ValueChanged<String> onChanged;
}
