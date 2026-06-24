import 'package:collectarr_app/core/models/calendar_event.dart';

/// Builds an RFC 5545 (iCalendar) document from collection calendar events so
/// users can subscribe to or import their collection's dates in any calendar
/// app. Events are emitted as all-day `VEVENT`s.
String buildCalendarIcs(
  List<CalendarEvent> events, {
  DateTime? now,
}) {
  final stamp = _formatUtcTimestamp((now ?? DateTime.now()).toUtc());
  final buffer = StringBuffer();
  _writeLine(buffer, 'BEGIN:VCALENDAR');
  _writeLine(buffer, 'VERSION:2.0');
  _writeLine(buffer, 'PRODID:-//Collectarr//Collection Calendar//EN');
  _writeLine(buffer, 'CALSCALE:GREGORIAN');
  _writeLine(buffer, 'METHOD:PUBLISH');
  _writeLine(buffer, 'X-WR-CALNAME:Collectarr');

  for (final event in events) {
    _writeLine(buffer, 'BEGIN:VEVENT');
    _writeLine(buffer, 'UID:${_uidFor(event)}');
    _writeLine(buffer, 'DTSTAMP:$stamp');
    _writeLine(buffer, 'DTSTART;VALUE=DATE:${_formatDate(event.date)}');
    _writeLine(buffer, 'SUMMARY:${_escapeText('${event.label}: ${event.title}')}');
    final description = event.subtitle;
    if (description != null && description.trim().isNotEmpty) {
      _writeLine(buffer, 'DESCRIPTION:${_escapeText(description)}');
    }
    _writeLine(buffer, 'CATEGORIES:${_escapeText(event.label.toUpperCase())}');
    _writeLine(buffer, 'TRANSP:TRANSPARENT');
    _writeLine(buffer, 'END:VEVENT');
  }

  _writeLine(buffer, 'END:VCALENDAR');
  return buffer.toString();
}

/// Writes a content line, folding it at 75 octets per RFC 5545 section 3.1.
void _writeLine(StringBuffer buffer, String line) {
  const maxLength = 75;
  if (line.length <= maxLength) {
    buffer.write('$line\r\n');
    return;
  }
  var index = 0;
  var first = true;
  while (index < line.length) {
    final take = first ? maxLength : maxLength - 1;
    final end = (index + take) > line.length ? line.length : index + take;
    final chunk = line.substring(index, end);
    buffer.write(first ? '$chunk\r\n' : ' $chunk\r\n');
    index = end;
    first = false;
  }
}

String _escapeText(String value) {
  return value
      .replaceAll('\\', '\\\\')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,')
      .replaceAll('\r\n', '\\n')
      .replaceAll('\n', '\\n')
      .replaceAll('\r', '\\n');
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y$m$d';
}

String _formatUtcTimestamp(DateTime utc) {
  String two(int v) => v.toString().padLeft(2, '0');
  final y = utc.year.toString().padLeft(4, '0');
  return '$y${two(utc.month)}${two(utc.day)}T'
      '${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
}

String _uidFor(CalendarEvent event) {
  final id = event.itemId ?? event.ownedItemId ?? 'na';
  final slug = event.title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return '${event.kind.name}-${_formatDate(event.date)}-$id-$slug@collectarr';
}
