import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';

class Loan {
  const Loan({
    required this.id,
    required this.collectionItemRef,
    required this.borrowerName,
    required this.lentDate,
    this.dueDate,
    this.returnedDate,
    this.notes,
  });

  final String id;

  /// Structural reference to the lent copy. Loan code never interprets the
  /// referenced kind's domain details.
  final CollectionItemRef collectionItemRef;
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
    final ownedPayload = json['collection_item_ref'];
    if (ownedPayload is! Map) {
      throw const FormatException('Loan.collection_item_ref is required');
    }
    final collectionItemRef = CollectionItemRef.fromJson(
      Map<String, Object?>.from(ownedPayload),
    );
    requireKnownCollectionItemRef(collectionItemRef, 'loan.collectionItemRef');
    return Loan(
      id: _requiredString(json, 'id'),
      collectionItemRef: collectionItemRef,
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
      'collection_item_ref': collectionItemRef.toJson(),
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
    CollectionItemRef? collectionItemRef,
    String? borrowerName,
    DateTime? dueDate,
    DateTime? returnedDate,
    String? notes,
  }) {
    return Loan(
      id: id,
      collectionItemRef: collectionItemRef ?? this.collectionItemRef,
      borrowerName: borrowerName ?? this.borrowerName,
      lentDate: lentDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      notes: notes ?? this.notes,
    );
  }
}
