import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/features/calendar/calendar_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _kDayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const _kMonthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
String _fmtMonthYear(DateTime dt) => '${_kMonthNames[dt.month - 1]} ${dt.year}';
String _fmtFullDate(DateTime dt) =>
    '${_kDayNames[dt.weekday - 1]}, ${_kMonthAbbr[dt.month - 1]} ${dt.day}, ${dt.year}';
String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
      );
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = LibraryAccentScope.accentOf(context);
    final animationDuration = LibraryAccentScope.animationDurationOf(context);
    final eventsAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: libraryAccentChromeFallbackColor(accent),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: LibraryAccentChrome(
          accent: accent,
          animationDuration: animationDuration,
        ),
        actions: [
          IconButton(
            tooltip: 'Today',
            onPressed: _goToToday,
            icon: const Icon(Icons.today),
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          // Group events by date (year-month-day) in local time.
          final eventsByDay = <DateTime, List<CalendarEvent>>{};
          for (final event in events) {
            final localDate = event.date.toLocal();
            final key = DateTime(
              localDate.year,
              localDate.month,
              localDate.day,
            );
            (eventsByDay[key] ??= []).add(event);
          }

          final selectedDayEvents = _selectedDay != null
              ? (eventsByDay[_selectedDay!] ?? const [])
              : const <CalendarEvent>[];

          return Column(
            children: [
              _CalendarHeader(
                month: _focusedMonth,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              _CalendarGrid(
                month: _focusedMonth,
                eventsByDay: eventsByDay,
                selectedDay: _selectedDay,
                accent: accent,
                onDaySelected: (day) {
                  setState(() => _selectedDay = day);
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: _DayEventsList(
                  day: _selectedDay,
                  events: selectedDayEvents,
                  accent: accent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Expanded(
            child: Text(
              _fmtMonthYear(month),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.eventsByDay,
    required this.selectedDay,
    required this.accent,
    required this.onDaySelected,
  });

  final DateTime month;
  final Map<DateTime, List<CalendarEvent>> eventsByDay;
  final DateTime? selectedDay;
  final Color accent;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun
    final daysInMonth = lastDayOfMonth.day;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    // Build 6-row grid starting from Monday.
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Day-of-week header
          Row(
            children: [
              for (final label in dayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kAppTextMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Calendar day cells
          for (var week = 0; week < 6; week++)
            _buildWeekRow(
              week,
              startWeekday,
              daysInMonth,
              todayKey,
            ),
        ],
      ),
    );
  }

  Widget _buildWeekRow(
    int week,
    int startWeekday,
    int daysInMonth,
    DateTime todayKey,
  ) {
    return Row(
      children: [
        for (var dow = 1; dow <= 7; dow++) ...[
          Expanded(
            child: _buildDayCell(week, dow, startWeekday, daysInMonth, todayKey),
          ),
        ],
      ],
    );
  }

  Widget _buildDayCell(
    int week,
    int dow,
    int startWeekday,
    int daysInMonth,
    DateTime todayKey,
  ) {
    final dayNumber = week * 7 + dow - startWeekday + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(height: 36);
    }

    final dayKey = DateTime(month.year, month.month, dayNumber);
    final hasEvents = eventsByDay.containsKey(dayKey);
    final isSelected = selectedDay == dayKey;
    final isToday = dayKey == todayKey;

    return GestureDetector(
      onTap: () => onDaySelected(dayKey),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.25)
              : isToday
                  ? accent.withValues(alpha: 0.08)
                  : null,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: accent.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isSelected || isToday ? accent : null,
              ),
            ),
            if (hasEvents)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayEventsList extends StatelessWidget {
  const _DayEventsList({
    required this.day,
    required this.events,
    required this.accent,
  });

  final DateTime? day;
  final List<CalendarEvent> events;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const Center(
        child: Text(
          'Select a day to see events',
          style: TextStyle(color: kAppTextMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            _fmtFullDate(day!),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No events on this day.',
              style: TextStyle(color: kAppTextMuted, fontSize: 13),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: events.length,
              itemBuilder: (context, i) {
                final event = events[i];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: event.color(accent).withValues(alpha: 0.18),
                    child: Icon(event.icon, size: 16, color: event.color(accent)),
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    [
                      event.label,
                      _fmtTime(event.date.toLocal()),
                      if (event.subtitle != null) event.subtitle!,
                    ].join(' \u00b7 '),
                    style: const TextStyle(
                      color: kAppTextMuted,
                      fontSize: 11,
                    ),
                  ),
                  dense: true,
                );
              },
            ),
          ),
      ],
    );
  }
}
