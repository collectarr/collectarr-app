import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

class Loan {
  const Loan({
    required this.id,
    required this.ownedItemId,
    this.catalogRef,
    required this.borrowerName,
    required this.lentDate,
    this.dueDate,
    this.returnedDate,
    this.notes,
  });

  final String id;
  final String ownedItemId;
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

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: _requiredString(json, 'id'),
      ownedItemId: _requiredString(json, 'owned_item_id'),
      catalogRef: json['catalog_ref'] is Map<String, dynamic>
          ? CatalogEntityRef.fromJson(json['catalog_ref'] as Map<String, dynamic>)
          : null,
      borrowerName: _requiredString(json, 'borrower_name'),
      lentDate: _requiredDate(json, 'lent_date'),
      dueDate: _optionalDate(json, 'due_date'),
      returnedDate: _optionalDate(json, 'returned_date'),
      notes: json['notes'] as String?,
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw StateError('Loan.$key is required and must be a non-empty string');
  }

  static DateTime _requiredDate(Map<String, dynamic> json, String key) {
    final parsed = _optionalDate(json, key);
    if (parsed != null) {
      return parsed;
    }
    throw StateError('Loan.$key is required and must be an ISO-8601 date');
  }

  static DateTime? _optionalDate(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Map<String, dynamic> toJson() {
    return {
      'owned_item_id': ownedItemId,
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
    String? borrowerName,
    DateTime? dueDate,
    DateTime? returnedDate,
    String? notes,
  }) {
    return Loan(
      id: id,
      ownedItemId: ownedItemId,
      catalogRef: catalogRef ?? this.catalogRef,
      borrowerName: borrowerName ?? this.borrowerName,
      lentDate: lentDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      notes: notes ?? this.notes,
    );
  }
}
