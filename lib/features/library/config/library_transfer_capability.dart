import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';

const kTransferableEntryDetailFieldKeys = <String>[
  'features',
  'boxSetName',
  'packaging',
];

const kTransferablePersonalFieldKeys = <String>[
  'condition',
  'personalNotes',
  'locationId',
  'tags',
  'currency',
  'soldTo',
  'purchaseStore',
  'pricePaidCents',
  'sellPriceCents',
  'indexNumber',
  'purchaseDate',
  'soldAt',
];

const kDefaultTransferableFieldKeys = <String>[
  ...kTransferableEntryDetailFieldKeys,
  ...kTransferablePersonalFieldKeys,
];

/// Encapsulates transferable field logic between independent local entries.
class LibraryTransferCapability {
  const LibraryTransferCapability({
    this.transferableFieldKeys = kDefaultTransferableFieldKeys,
    this.kindFields = const <TransferableField>[],
  });

  final List<String> transferableFieldKeys;
  final List<TransferableField> kindFields;

  List<TransferableField> allFields() {
    final map = <String, TransferableField>{
      for (final field in kindFields) field.key: field,
    };
    return [
      for (final key in transferableFieldKeys)
        if (map[key] case final field?) field,
    ];
  }

  List<TransferableField> fieldsWithCustomFields(
    List<CustomFieldDefinition> definitions,
  ) {
    return TransferableField.withCustomFields(
      definitions,
      availableFields: allFields(),
      fieldKeys: transferableFieldKeys,
    );
  }
}
