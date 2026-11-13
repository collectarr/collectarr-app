import 'package:collectarr_app/features/library/ui/primitives/managed_vocabulary_field.dart';
import 'package:flutter/material.dart';

import '../vocabulary/book_vocabularies.dart';

/// My Images help text and defaults shared by Add and Edit Books.
const bookImagesHelperText =
    'Add your own images (max. 5), set a description and an image type (Signature, Booklet, etc.)';
const bookDefaultImageType = 'Other';

/// The Image Type of a personal image: a Books pick list, as in the
/// reference.
Widget buildBookImageTypeField(
  BuildContext context, {
  required String value,
  required ValueChanged<String> onChanged,
}) =>
    LibraryManagedVocabularyField(
      label: 'Image Type',
      listName: BookVocabularyIds.imageType.value,
      mediaKind: 'book',
      value: value,
      builtIns: BookVocabularies.imageType.builtIns,
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
