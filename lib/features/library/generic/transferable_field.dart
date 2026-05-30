import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:flutter/material.dart';

/// Describes the data type of a transferable field.
enum TransferableFieldType {
  text,
  integer,
  date,
  boolean,
}

/// A field on [OwnedItem] that can participate in the Transfer Field Data flow.
class TransferableField {
  const TransferableField._({
    required this.key,
    required this.label,
    required this.icon,
    required this.type,
    this.customFieldId,
  });

  /// Internal key matching the [OwnedItem] property name.
  final String key;
  final String label;
  final IconData icon;
  final TransferableFieldType type;

  /// Non-null when this represents a user-defined custom field.
  final String? customFieldId;

  bool get isCustomField => customFieldId != null;

  /// Read the string representation of this field from an [OwnedItem].
  String? readFrom(OwnedItem item) {
    switch (key) {
      case 'condition':
        return item.condition;
      case 'grade':
        return item.grade;
      case 'personalNotes':
        return item.personalNotes;
      case 'locationId':
        return item.locationId;
      case 'tags':
        return item.tags;
      case 'currency':
        return item.currency;
      case 'rawOrSlabbed':
        return item.rawOrSlabbed;
      case 'gradingCompany':
        return item.gradingCompany;
      case 'graderNotes':
        return item.graderNotes;
      case 'signedBy':
        return item.signedBy;
      case 'keyReason':
        return item.keyReason;
      case 'readStatus':
        return item.readStatus;
      case 'soldTo':
        return item.soldTo;
      case 'features':
        return item.features;
      case 'purchaseStore':
        return item.purchaseStore;
      case 'boxSetName':
        return item.boxSetName;
      case 'pricePaidCents':
        return item.pricePaidCents?.toString();
      case 'coverPriceCents':
        return item.coverPriceCents?.toString();
      case 'sellPriceCents':
        return item.sellPriceCents?.toString();
      case 'quantity':
        return item.quantity.toString();
      case 'indexNumber':
        return item.indexNumber?.toString();
      case 'rating':
        return item.rating?.toString();
      case 'purchaseDate':
        return item.purchaseDate?.toIso8601String();
      case 'startedAt':
        return item.startedAt?.toIso8601String();
      case 'finishedAt':
        return item.finishedAt?.toIso8601String();
      case 'soldAt':
        return item.soldAt?.toIso8601String();
      case 'keyComic':
        return item.keyComic ? 'true' : null;
      default:
        return null;
    }
  }

  /// Apply [value] (or null to clear) onto [item], returning the updated copy.
  OwnedItem writeTo(OwnedItem item, String? value) {
    switch (key) {
      case 'condition':
        return item.copyWith(condition: value);
      case 'grade':
        return item.copyWith(grade: value);
      case 'personalNotes':
        return item.copyWith(personalNotes: value);
      case 'locationId':
        return item.copyWith(locationId: value);
      case 'tags':
        return item.copyWith(tags: value);
      case 'currency':
        return item.copyWith(currency: value);
      case 'rawOrSlabbed':
        return item.copyWith(rawOrSlabbed: value);
      case 'gradingCompany':
        return item.copyWith(gradingCompany: value);
      case 'graderNotes':
        return item.copyWith(graderNotes: value);
      case 'signedBy':
        return item.copyWith(signedBy: value);
      case 'keyReason':
        return item.copyWith(keyReason: value);
      case 'readStatus':
        return item.copyWith(readStatus: value);
      case 'soldTo':
        return item.copyWith(soldTo: value);
      case 'features':
        return item.copyWith(features: value);
      case 'purchaseStore':
        return item.copyWith(purchaseStore: value);
      case 'boxSetName':
        return item.copyWith(boxSetName: value);
      case 'pricePaidCents':
        return item.copyWith(
            pricePaidCents: value != null ? int.tryParse(value) : null);
      case 'coverPriceCents':
        return item.copyWith(
            coverPriceCents: value != null ? int.tryParse(value) : null);
      case 'sellPriceCents':
        return item.copyWith(
            sellPriceCents: value != null ? int.tryParse(value) : null);
      case 'quantity':
        return item.copyWith(
            quantity: value != null ? int.tryParse(value) ?? 1 : 1);
      case 'indexNumber':
        return item.copyWith(
            indexNumber: value != null ? int.tryParse(value) : null);
      case 'rating':
        return item.copyWith(
            rating: value != null ? int.tryParse(value) : null);
      case 'purchaseDate':
        return item.copyWith(
            purchaseDate: value != null ? DateTime.tryParse(value) : null);
      case 'startedAt':
        return item.copyWith(
            startedAt: value != null ? DateTime.tryParse(value) : null);
      case 'finishedAt':
        return item.copyWith(
            finishedAt: value != null ? DateTime.tryParse(value) : null);
      case 'soldAt':
        return item.copyWith(
            soldAt: value != null ? DateTime.tryParse(value) : null);
      case 'keyComic':
        return item.copyWith(keyComic: value == 'true');
      default:
        return item;
    }
  }

  /// Built-in transferable fields on [OwnedItem].
  static const List<TransferableField> builtIn = [
    // --- Text ---
    TransferableField._(
      key: 'condition',
      label: 'Condition',
      icon: Icons.inventory_2_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'grade',
      label: 'Grade',
      icon: Icons.workspace_premium_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'personalNotes',
      label: 'Personal notes',
      icon: Icons.sticky_note_2_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'locationId',
      label: 'Location',
      icon: Icons.shelves,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'tags',
      label: 'Tags',
      icon: Icons.sell_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'currency',
      label: 'Currency',
      icon: Icons.attach_money,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'rawOrSlabbed',
      label: 'Raw / Slabbed',
      icon: Icons.layers_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'gradingCompany',
      label: 'Grading company',
      icon: Icons.verified_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'graderNotes',
      label: 'Grader notes',
      icon: Icons.note_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'signedBy',
      label: 'Signed by',
      icon: Icons.draw_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'keyReason',
      label: 'Key reason',
      icon: Icons.vpn_key_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'readStatus',
      label: 'Read status',
      icon: Icons.auto_stories_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'soldTo',
      label: 'Sold to',
      icon: Icons.person_outline,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'features',
      label: 'Features',
      icon: Icons.featured_play_list_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'purchaseStore',
      label: 'Purchase store',
      icon: Icons.storefront_outlined,
      type: TransferableFieldType.text,
    ),
    TransferableField._(
      key: 'boxSetName',
      label: 'Box set name',
      icon: Icons.inventory_outlined,
      type: TransferableFieldType.text,
    ),
    // --- Integers ---
    TransferableField._(
      key: 'pricePaidCents',
      label: 'Price paid',
      icon: Icons.payments_outlined,
      type: TransferableFieldType.integer,
    ),
    TransferableField._(
      key: 'coverPriceCents',
      label: 'Cover price',
      icon: Icons.price_check,
      type: TransferableFieldType.integer,
    ),
    TransferableField._(
      key: 'sellPriceCents',
      label: 'Sell price',
      icon: Icons.point_of_sale,
      type: TransferableFieldType.integer,
    ),
    TransferableField._(
      key: 'quantity',
      label: 'Quantity',
      icon: Icons.numbers,
      type: TransferableFieldType.integer,
    ),
    TransferableField._(
      key: 'indexNumber',
      label: 'Index number',
      icon: Icons.tag,
      type: TransferableFieldType.integer,
    ),
    TransferableField._(
      key: 'rating',
      label: 'Rating',
      icon: Icons.star_outline,
      type: TransferableFieldType.integer,
    ),
    // --- Dates ---
    TransferableField._(
      key: 'purchaseDate',
      label: 'Purchase date',
      icon: Icons.calendar_today,
      type: TransferableFieldType.date,
    ),
    TransferableField._(
      key: 'startedAt',
      label: 'Started at',
      icon: Icons.play_arrow_outlined,
      type: TransferableFieldType.date,
    ),
    TransferableField._(
      key: 'finishedAt',
      label: 'Finished at',
      icon: Icons.check_circle_outline,
      type: TransferableFieldType.date,
    ),
    TransferableField._(
      key: 'soldAt',
      label: 'Sold at',
      icon: Icons.receipt_long_outlined,
      type: TransferableFieldType.date,
    ),
    // --- Boolean ---
    TransferableField._(
      key: 'keyComic',
      label: 'Key issue',
      icon: Icons.vpn_key,
      type: TransferableFieldType.boolean,
    ),
  ];

  /// Build a complete field list including user-defined custom fields.
  static List<TransferableField> withCustomFields(
    List<CustomFieldDefinition> definitions,
  ) {
    return [
      ...builtIn,
      for (final def in definitions)
        TransferableField._(
          key: 'cf_${def.id}',
          label: def.name,
          icon: Icons.text_fields,
          type: TransferableFieldType.text,
          customFieldId: def.id,
        ),
    ];
  }
}

/// How transferred data should be applied.
enum TransferMode {
  move('Move', 'Transfers the value and clears the source field'),
  copy('Copy', 'Copies the value without clearing the source');

  const TransferMode(this.label, this.description);
  final String label;
  final String description;
}

/// What to do when the target field already has data.
enum TransferConflict {
  skip('Skip', 'Leave existing target values unchanged'),
  overwrite('Overwrite', 'Replace existing target values'),
  append('Append', 'Append source value after existing text (text fields only)');

  const TransferConflict(this.label, this.description);
  final String label;
  final String description;
}
