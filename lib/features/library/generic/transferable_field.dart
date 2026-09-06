import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
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
  const TransferableField({
    required this.key,
    required this.label,
    required this.icon,
    required this.type,
    this.scope = LibraryEditScope.all,
    required this.read,
    required this.write,
    this.customFieldId,
  });

  /// Internal key matching the property name or custom field ID.
  final String key;
  final String label;
  final IconData icon;
  final TransferableFieldType type;
  final LibraryEditScope scope;

  /// Non-null when this represents a user-defined custom field.
  final String? customFieldId;

  final String? Function(OwnedItem item) read;
  final OwnedItem Function(OwnedItem item, String? value) write;

  bool get isCustomField => customFieldId != null;

  bool matchesScope(LibraryEditScope requestedScope) {
    if (requestedScope == LibraryEditScope.all ||
        scope == LibraryEditScope.all) {
      return true;
    }
    return scope == requestedScope;
  }

  /// Read the string representation of this field from an [OwnedItem].
  String? readFrom(OwnedItem item) => read(item);

  /// Apply [value] (or null to clear) onto [item], returning the updated copy.
  OwnedItem writeTo(OwnedItem item, String? value) => write(item, value);

  factory TransferableField.customField(CustomFieldDefinition def) {
    return TransferableField(
      key: 'cf_${def.id}',
      label: def.name,
      icon: Icons.text_fields,
      type: TransferableFieldType.text,
      scope: LibraryEditScope.all,
      customFieldId: def.id,
      read: (item) => null,
      write: (item, value) => item,
    );
  }

  // ---------------------------------------------------------------------------
  // Readers and Writers for universal OwnedItem properties
  // ---------------------------------------------------------------------------

  static String? _readCondition(OwnedItem item) => item.condition;
  static OwnedItem _writeCondition(OwnedItem item, String? v) =>
      item.copyWith(condition: v);

  static String? _readGrade(OwnedItem item) => item.grade;
  static OwnedItem _writeGrade(OwnedItem item, String? v) =>
      item.copyWith(grade: v);

  static String? _readPersonalNotes(OwnedItem item) => item.personalNotes;
  static OwnedItem _writePersonalNotes(OwnedItem item, String? v) =>
      item.copyWith(personalNotes: v);

  static String? _readLocationId(OwnedItem item) => item.locationId;
  static OwnedItem _writeLocationId(OwnedItem item, String? v) =>
      item.copyWith(locationId: v);

  static String? _readTags(OwnedItem item) => item.tags;
  static OwnedItem _writeTags(OwnedItem item, String? v) =>
      item.copyWith(tags: v);

  static String? _readCurrency(OwnedItem item) => item.currency;
  static OwnedItem _writeCurrency(OwnedItem item, String? v) =>
      item.copyWith(currency: v);

  static String? _readSoldTo(OwnedItem item) => item.soldTo;
  static OwnedItem _writeSoldTo(OwnedItem item, String? v) =>
      item.copyWith(soldTo: v);

  static String? _readPurchaseStore(OwnedItem item) => item.purchaseStore;
  static OwnedItem _writePurchaseStore(OwnedItem item, String? v) =>
      item.copyWith(purchaseStore: v);

  static String? _readPricePaidCents(OwnedItem item) =>
      item.pricePaidCents?.toString();
  static OwnedItem _writePricePaidCents(OwnedItem item, String? v) =>
      item.copyWith(pricePaidCents: v != null ? int.tryParse(v) : null);

  static String? _readSellPriceCents(OwnedItem item) =>
      item.sellPriceCents?.toString();
  static OwnedItem _writeSellPriceCents(OwnedItem item, String? v) =>
      item.copyWith(sellPriceCents: v != null ? int.tryParse(v) : null);

  static String? _readQuantity(OwnedItem item) => item.quantity.toString();
  static OwnedItem _writeQuantity(OwnedItem item, String? v) =>
      item.copyWith(quantity: v != null ? int.tryParse(v) ?? 1 : 1);

  static String? _readIndexNumber(OwnedItem item) =>
      item.indexNumber?.toString();
  static OwnedItem _writeIndexNumber(OwnedItem item, String? v) =>
      item.copyWith(indexNumber: v != null ? int.tryParse(v) : null);

  static String? _readPurchaseDate(OwnedItem item) =>
      item.purchaseDate?.toIso8601String();
  static OwnedItem _writePurchaseDate(OwnedItem item, String? v) =>
      item.copyWith(purchaseDate: v != null ? DateTime.tryParse(v) : null);

  static String? _readSoldAt(OwnedItem item) => item.soldAt?.toIso8601String();
  static OwnedItem _writeSoldAt(OwnedItem item, String? v) =>
      item.copyWith(soldAt: v != null ? DateTime.tryParse(v) : null);

  /// Universal built-in transferable fields on [OwnedItem].
  static const List<TransferableField> universalBuiltIn = [
    // --- Text ---
    TransferableField(
      key: 'condition',
      label: 'Condition',
      icon: Icons.inventory_2_outlined,
      type: TransferableFieldType.text,
      read: _readCondition,
      write: _writeCondition,
    ),
    TransferableField(
      key: 'grade',
      label: 'Grade',
      icon: Icons.workspace_premium_outlined,
      type: TransferableFieldType.text,
      read: _readGrade,
      write: _writeGrade,
    ),
    TransferableField(
      key: 'personalNotes',
      label: 'Personal notes',
      icon: Icons.sticky_note_2_outlined,
      type: TransferableFieldType.text,
      read: _readPersonalNotes,
      write: _writePersonalNotes,
    ),
    TransferableField(
      key: 'locationId',
      label: 'Location',
      icon: Icons.shelves,
      type: TransferableFieldType.text,
      read: _readLocationId,
      write: _writeLocationId,
    ),
    TransferableField(
      key: 'tags',
      label: 'Tags',
      icon: Icons.sell_outlined,
      type: TransferableFieldType.text,
      read: _readTags,
      write: _writeTags,
    ),
    TransferableField(
      key: 'currency',
      label: 'Currency',
      icon: Icons.attach_money,
      type: TransferableFieldType.text,
      read: _readCurrency,
      write: _writeCurrency,
    ),
    TransferableField(
      key: 'soldTo',
      label: 'Sold to',
      icon: Icons.person_outline,
      type: TransferableFieldType.text,
      read: _readSoldTo,
      write: _writeSoldTo,
    ),
    TransferableField(
      key: 'purchaseStore',
      label: 'Purchase store',
      icon: Icons.storefront_outlined,
      type: TransferableFieldType.text,
      read: _readPurchaseStore,
      write: _writePurchaseStore,
    ),
    // --- Integers ---
    TransferableField(
      key: 'pricePaidCents',
      label: 'Price paid',
      icon: Icons.payments_outlined,
      type: TransferableFieldType.integer,
      read: _readPricePaidCents,
      write: _writePricePaidCents,
    ),
    TransferableField(
      key: 'sellPriceCents',
      label: 'Sell price',
      icon: Icons.point_of_sale,
      type: TransferableFieldType.integer,
      read: _readSellPriceCents,
      write: _writeSellPriceCents,
    ),
    TransferableField(
      key: 'quantity',
      label: 'Quantity',
      icon: Icons.numbers,
      type: TransferableFieldType.integer,
      read: _readQuantity,
      write: _writeQuantity,
    ),
    TransferableField(
      key: 'indexNumber',
      label: 'Index number',
      icon: Icons.tag,
      type: TransferableFieldType.integer,
      read: _readIndexNumber,
      write: _writeIndexNumber,
    ),
    // --- Dates ---
    TransferableField(
      key: 'purchaseDate',
      label: 'Purchase date',
      icon: Icons.calendar_today,
      type: TransferableFieldType.date,
      read: _readPurchaseDate,
      write: _writePurchaseDate,
    ),
    TransferableField(
      key: 'soldAt',
      label: 'Sold at',
      icon: Icons.receipt_long_outlined,
      type: TransferableFieldType.date,
      read: _readSoldAt,
      write: _writeSoldAt,
    ),
  ];

  /// Build a complete field list including user-defined custom fields.
  static List<TransferableField> withCustomFields(
    List<CustomFieldDefinition> definitions, {
    Iterable<String>? fieldKeys,
    List<TransferableField>? availableFields,
  }) {
    final pool = availableFields ?? universalBuiltIn;
    final map = {for (final field in pool) field.key: field};
    final resolved = fieldKeys == null
        ? pool
        : [
            for (final key in fieldKeys)
              if (map[key] case final field?) field,
          ];
    return [
      ...resolved,
      for (final def in definitions) TransferableField.customField(def),
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
  append(
      'Append', 'Append source value after existing text (text fields only)');

  const TransferConflict(this.label, this.description);
  final String label;
  final String description;
}
