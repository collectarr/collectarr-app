import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';

const kTransferableMediaFieldKeys = <String>[];

const kTransferableReleaseFieldKeys = <String>[
  'features',
  'boxSetName',
  'packaging',
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
    this.kindFields = const <TransferableField>[],
  });

  final List<String> transferableFieldKeys;
  final List<TransferableField> kindFields;

  List<TransferableField> allFields() {
    final map = <String, TransferableField>{
      for (final field in TransferableField.universalBuiltIn) field.key: field,
      for (final field in kindFields) field.key: field,
    };
    return [
      for (final key in transferableFieldKeys)
        if (map[key] case final field?) field,
    ];
  }

  List<String> fieldKeysForScope(LibraryEditScope scope) {
    return switch (scope) {
      LibraryEditScope.media => kTransferableMediaFieldKeys,
      LibraryEditScope.release => [
          for (final f in allFields())
            if (f.scope == LibraryEditScope.release ||
                kTransferableReleaseFieldKeys.contains(f.key))
              f.key,
        ],
      LibraryEditScope.all => transferableFieldKeys,
    };
  }

  List<TransferableField> fieldsWithCustomFields(
    List<CustomFieldDefinition> definitions,
    LibraryEditScope scope,
  ) {
    return TransferableField.withCustomFields(
      definitions,
      availableFields: allFields(),
      fieldKeys: fieldKeysForScope(scope),
    );
  }
}
