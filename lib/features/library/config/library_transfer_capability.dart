import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';

const kTransferableMediaFieldKeys = <String>[];

const kTransferableReleaseFieldKeys = <String>[
  'features',
  'boxSetName',
  'coverPriceCents',
];

const kTransferablePersonalFieldKeys = <String>[
  'condition',
  'grade',
  'personalNotes',
  'locationId',
  'tags',
  'currency',
  'readStatus',
  'soldTo',
  'purchaseStore',
  'pricePaidCents',
  'sellPriceCents',
  'quantity',
  'indexNumber',
  'rating',
  'purchaseDate',
  'startedAt',
  'finishedAt',
  'soldAt',
];

const kDefaultTransferableFieldKeys = <String>[
  ...kTransferableReleaseFieldKeys,
  ...kTransferablePersonalFieldKeys,
];

/// Encapsulates transferable field logic when moving copies between editions or media items.
class LibraryTransferCapability {
  const LibraryTransferCapability({
    this.transferableFieldKeys = kDefaultTransferableFieldKeys,
  });

  final List<String> transferableFieldKeys;

  List<String> fieldKeysForScope(LibraryEditScope scope) {
    return switch (scope) {
      LibraryEditScope.media => kTransferableMediaFieldKeys,
      LibraryEditScope.release => kTransferableReleaseFieldKeys,
      LibraryEditScope.all => transferableFieldKeys,
    };
  }

  List<TransferableField> fieldsWithCustomFields(
    List<CustomFieldDefinition> definitions,
    LibraryEditScope scope,
  ) {
    return TransferableField.withCustomFields(
      definitions,
      fieldKeys: fieldKeysForScope(scope),
    );
  }
}
