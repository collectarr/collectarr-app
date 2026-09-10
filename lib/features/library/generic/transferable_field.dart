import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:flutter/material.dart';

/// Describes the data type of a transferable field.
enum TransferableFieldType {
  text,
  integer,
  date,
  boolean,
}

/// A structural field descriptor used by the transfer UI.
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

  final String? Function(Object item) read;
  final Object Function(Object item, String? value) write;

  /// Builds a kind-owned field. The generic host keeps the value opaque.
  static TransferableField typed<T>({
    required String key,
    required String label,
    required IconData icon,
    required TransferableFieldType type,
    required T Function(Object value) decode,
    required String? Function(T value) read,
    required T Function(T value, String? nextValue) write,
    LibraryEditScope scope = LibraryEditScope.all,
    String? customFieldId,
  }) {
    return TransferableField(
      key: key,
      label: label,
      icon: icon,
      type: type,
      scope: scope,
      customFieldId: customFieldId,
      read: (item) => read(decode(item)),
      write: (item, value) => write(decode(item), value) as Object,
    );
  }

  /// Creates the structural copy fields that every kind may expose. The
  /// accessors are supplied by the owning kind; this class never knows a
  /// concrete Owned model or decodes a cross-kind aggregate.
  static List<TransferableField> universalForTyped<T>({
    required T Function(Object value) decode,
    required String? Function(T value) readCondition,
    required T Function(T value, String? nextValue) writeCondition,
    required String? Function(T value) readPersonalNotes,
    required T Function(T value, String? nextValue) writePersonalNotes,
    required String? Function(T value) readLocationId,
    required T Function(T value, String? nextValue) writeLocationId,
    required String? Function(T value) readTags,
    required T Function(T value, String? nextValue) writeTags,
    required String? Function(T value) readCurrency,
    required T Function(T value, String? nextValue) writeCurrency,
    required String? Function(T value) readSoldTo,
    required T Function(T value, String? nextValue) writeSoldTo,
    required String? Function(T value) readPurchaseStore,
    required T Function(T value, String? nextValue) writePurchaseStore,
    required String? Function(T value) readPricePaidCents,
    required T Function(T value, String? nextValue) writePricePaidCents,
    required String? Function(T value) readSellPriceCents,
    required T Function(T value, String? nextValue) writeSellPriceCents,
    required String? Function(T value) readQuantity,
    required T Function(T value, String? nextValue) writeQuantity,
    required String? Function(T value) readIndexNumber,
    required T Function(T value, String? nextValue) writeIndexNumber,
    required String? Function(T value) readPurchaseDate,
    required T Function(T value, String? nextValue) writePurchaseDate,
    required String? Function(T value) readSoldAt,
    required T Function(T value, String? nextValue) writeSoldAt,
  }) {
    TransferableField field({
      required String key,
      required String label,
      required IconData icon,
      required TransferableFieldType type,
      required String? Function(T value) read,
      required T Function(T value, String? nextValue) write,
    }) {
      return typed<T>(
        key: key,
        label: label,
        icon: icon,
        type: type,
        decode: decode,
        read: read,
        write: write,
      );
    }

    return [
      field(
        key: 'condition',
        label: 'Condition',
        icon: Icons.inventory_2_outlined,
        type: TransferableFieldType.text,
        read: readCondition,
        write: writeCondition,
      ),
      field(
        key: 'personalNotes',
        label: 'Personal notes',
        icon: Icons.sticky_note_2_outlined,
        type: TransferableFieldType.text,
        read: readPersonalNotes,
        write: writePersonalNotes,
      ),
      field(
        key: 'locationId',
        label: 'Location',
        icon: Icons.shelves,
        type: TransferableFieldType.text,
        read: readLocationId,
        write: writeLocationId,
      ),
      field(
        key: 'tags',
        label: 'Tags',
        icon: Icons.sell_outlined,
        type: TransferableFieldType.text,
        read: readTags,
        write: writeTags,
      ),
      field(
        key: 'currency',
        label: 'Currency',
        icon: Icons.attach_money,
        type: TransferableFieldType.text,
        read: readCurrency,
        write: writeCurrency,
      ),
      field(
        key: 'soldTo',
        label: 'Sold to',
        icon: Icons.person_outline,
        type: TransferableFieldType.text,
        read: readSoldTo,
        write: writeSoldTo,
      ),
      field(
        key: 'purchaseStore',
        label: 'Purchase store',
        icon: Icons.storefront_outlined,
        type: TransferableFieldType.text,
        read: readPurchaseStore,
        write: writePurchaseStore,
      ),
      field(
        key: 'pricePaidCents',
        label: 'Price paid',
        icon: Icons.payments_outlined,
        type: TransferableFieldType.integer,
        read: readPricePaidCents,
        write: writePricePaidCents,
      ),
      field(
        key: 'sellPriceCents',
        label: 'Sell price',
        icon: Icons.point_of_sale,
        type: TransferableFieldType.integer,
        read: readSellPriceCents,
        write: writeSellPriceCents,
      ),
      field(
        key: 'quantity',
        label: 'Quantity',
        icon: Icons.numbers,
        type: TransferableFieldType.integer,
        read: readQuantity,
        write: writeQuantity,
      ),
      field(
        key: 'indexNumber',
        label: 'Index number',
        icon: Icons.tag,
        type: TransferableFieldType.integer,
        read: readIndexNumber,
        write: writeIndexNumber,
      ),
      field(
        key: 'purchaseDate',
        label: 'Purchase date',
        icon: Icons.calendar_today,
        type: TransferableFieldType.date,
        read: readPurchaseDate,
        write: writePurchaseDate,
      ),
      field(
        key: 'soldAt',
        label: 'Sold at',
        icon: Icons.receipt_long_outlined,
        type: TransferableFieldType.date,
        read: readSoldAt,
        write: writeSoldAt,
      ),
    ];
  }

  bool get isCustomField => customFieldId != null;

  bool matchesScope(LibraryEditScope requestedScope) {
    if (requestedScope == LibraryEditScope.all ||
        scope == LibraryEditScope.all) {
      return true;
    }
    return scope == requestedScope;
  }

  /// Read the string representation of this field from an opaque kind value.
  String? readFrom(Object item) => read(item);

  /// Apply [value] (or null to clear) onto [item], returning the updated value.
  Object writeTo(Object item, String? value) => write(item, value);

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

  /// Build a complete field list including user-defined custom fields.
  static List<TransferableField> withCustomFields(
    List<CustomFieldDefinition> definitions, {
    Iterable<String>? fieldKeys,
    List<TransferableField>? availableFields,
  }) {
    final pool = availableFields ?? const <TransferableField>[];
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

/// Opaque typed item carried by the transfer host after kind dispatch.
final class TransferableOwnedItem {
  const TransferableOwnedItem({
    required this.ref,
    required this.catalogRef,
    required this.value,
  });

  final OwnedItemRef ref;
  final CatalogEntityRef catalogRef;
  final Object value;
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
