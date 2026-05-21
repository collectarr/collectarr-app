class Loan {
  const Loan({
    required this.id,
    required this.ownedItemId,
    required this.borrowerName,
    required this.lentDate,
    this.dueDate,
    this.returnedDate,
    this.notes,
  });

  final String id;
  final String ownedItemId;
  final String borrowerName;
  final DateTime lentDate;
  final DateTime? dueDate;
  final DateTime? returnedDate;
  final String? notes;

  bool get isActive => returnedDate == null;
  bool get isOverdue =>
      isActive && dueDate != null && DateTime.now().isAfter(dueDate!);

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      ownedItemId: json['owned_item_id'] as String,
      borrowerName: json['borrower_name'] as String,
      lentDate: DateTime.parse(json['lent_date'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      returnedDate: json['returned_date'] != null
          ? DateTime.parse(json['returned_date'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owned_item_id': ownedItemId,
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
    String? borrowerName,
    DateTime? dueDate,
    DateTime? returnedDate,
    String? notes,
  }) {
    return Loan(
      id: id,
      ownedItemId: ownedItemId,
      borrowerName: borrowerName ?? this.borrowerName,
      lentDate: lentDate,
      dueDate: dueDate ?? this.dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      notes: notes ?? this.notes,
    );
  }
}
