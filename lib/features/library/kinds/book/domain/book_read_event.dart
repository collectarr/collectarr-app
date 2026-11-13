import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

/// One row of a book's Read History: who read it, when and how far.
@immutable
final class BookReadEvent implements JsonEncodable {
  const BookReadEvent({
    this.status = '',
    this.startDate,
    this.endDate,
    this.reader,
    this.pagesRead,
  });

  /// Reading Status choices of a read event, as storage value and label.
  static const statuses = [
    ('', 'No Status'),
    ('Reading', 'Reading'),
    ('Read', 'Finished'),
    ('Dropped', 'Dropped'),
  ];

  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reader;
  final int? pagesRead;

  bool get isFinished => status == 'Read';

  bool get isEmpty =>
      status.isEmpty &&
      startDate == null &&
      endDate == null &&
      (reader ?? '').isEmpty &&
      pagesRead == null;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        if (startDate != null) 'start_date': _day(startDate!),
        if (endDate != null) 'end_date': _day(endDate!),
        if ((reader ?? '').isNotEmpty) 'reader': reader,
        if (pagesRead != null) 'pages_read': pagesRead,
      };

  factory BookReadEvent.fromJson(Map<String, dynamic> json) => BookReadEvent(
        status: json['status'] as String? ?? '',
        startDate: DateTime.tryParse(json['start_date'] as String? ?? ''),
        endDate: DateTime.tryParse(json['end_date'] as String? ?? ''),
        reader: json['reader'] as String?,
        pagesRead: (json['pages_read'] as num?)?.toInt(),
      );

  static List<BookReadEvent> listFromJson(Object? value) => [
        for (final item in value as List? ?? const [])
          BookReadEvent.fromJson(Map<String, dynamic>.from(item as Map)),
      ];

  BookReadEvent copyWith({
    String? status,
    Object? startDate = _unset,
    Object? endDate = _unset,
    Object? reader = _unset,
    Object? pagesRead = _unset,
  }) =>
      BookReadEvent(
        status: status ?? this.status,
        startDate: identical(startDate, _unset)
            ? this.startDate
            : startDate as DateTime?,
        endDate:
            identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
        reader: identical(reader, _unset) ? this.reader : reader as String?,
        pagesRead:
            identical(pagesRead, _unset) ? this.pagesRead : pagesRead as int?,
      );

  @override
  bool operator ==(Object other) =>
      other is BookReadEvent &&
      status == other.status &&
      startDate == other.startDate &&
      endDate == other.endDate &&
      reader == other.reader &&
      pagesRead == other.pagesRead;

  @override
  int get hashCode =>
      Object.hash(status, startDate, endDate, reader, pagesRead);
}

const Object _unset = Object();

String _day(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
