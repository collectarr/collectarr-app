import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';

class Loan {
  const Loan({
    required this.id,
    required this.ownedRef,
    this.catalogRef,
    required this.borrowerName,
    required this.lentDate,
    this.dueDate,
    this.returnedDate,
    this.notes,
  });

  final String id;

  /// Structural reference to the lent copy. Loan code never interprets the
  /// referenced kind's domain details.
  final OwnedItemRef ownedRef;
  final CatalogEntityRef? catalogRef;
  final String borrowerName;
  final DateTime lentDate;
  final DateTime? dueDate;
  final DateTime? returnedDate;
  final String? notes;

  bool get isActive => returnedDate == null;

  bool isOverdueAt(DateTime now) {
    return isActive && dueDate != null && now.isAfter(dueDate!);
  }

  factory Loan.fromJson(Map<String, Object?> json) {
    final catalogRef = json['catalog_ref'] is Map
        ? CatalogEntityRef.fromJson(
            Map<String, Object?>.from(json['catalog_ref'] as Map),
          )
        : null;
    final ownedPayload = json['owned_ref'];
    if (ownedPayload is! Map) {
      throw const FormatException('Loan.owned_ref is required');
    }
    final ownedRef = OwnedItemRef.fromJson(
      Map<String, Object?>.from(ownedPayload),
    );
    return Loan(
      id: _requiredString(json, 'id'),
      ownedRef: ownedRef,
      catalogRef: catalogRef,
      borrowerName: _requiredString(json, 'borrower_name'),
      lentDate: _requiredDate(json, 'lent_date'),
      dueDate: _optionalDate(json, 'due_date'),
      returnedDate: _optionalDate(json, 'returned_date'),
      notes: json['notes'] as String?,
    );
  }

  static String _requiredString(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw StateError('Loan.$key is required and must be a non-empty string');
  }

  static DateTime _requiredDate(Map<String, Object?> json, String key) {
    final parsed = _optionalDate(json, key);
    if (parsed != null) {
      return parsed;
    }
    throw StateError('Loan.$key is required and must be an ISO-8601 date');
  }

  static DateTime? _optionalDate(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Map<String, Object?> toJson() {
    return {
      'owned_ref': ownedRef.toJson(),
      if (catalogRef != null) 'catalog_ref': catalogRef!.toJson(),
      'borrower_name': borrowerName,
      'lent_date':
          '${lentDate.year}-${lentDate.month.toString().padLeft(2, '0')}-${lentDate.day.toString().padLeft(2, '0')}',
      if (dueDate != null)
        'due_date':
            '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}',
      if (notes != null) 'notes': notes,
    };
  }

  Loan copyWith({
    CatalogEntityRef? catalogRef,
    OwnedItemRef? ownedRef,
    String? borrowerName,
    DateTime? dueDate,
    DateTime? returnedDate,
    String? notes,
  }) {
    return Loan(
      id: id,
      ownedRef: ownedRef ?? this.ownedRef,
      catalogRef: catalogRef ?? this.catalogRef,
      borrowerName: borrowerName ?? this.borrowerName,
      lentDate: lentDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      notes: notes ?? this.notes,
    );
  }
}
