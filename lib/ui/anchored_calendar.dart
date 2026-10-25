import 'package:collectarr_app/ui/app_dialog.dart';
import 'dart:math' as math;

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A field-anchored calendar in the reference style: a 221 x 280 month on
/// #444 with «/» paging, blue Su-Sa weekdays, grey neighbouring-month days
/// and a Today button. The title steps up to months and years. Choosing a
/// day commits; a click outside closes without a change.
Future<DateTime?> showAppAnchoredCalendar({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  final box = context.findRenderObject() as RenderBox?;
  final anchor =
      box == null ? Rect.zero : box.localToGlobal(Offset.zero) & box.size;
  return showAppDialog<DateTime>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    // The reference calendar appears and disappears at once.
    transitionDuration: Duration.zero,
    transitionBuilder: (context, animation, secondary, child) => child,
    builder: (popupContext) => LayoutBuilder(builder: (context, constraints) {
      final safe = MediaQuery.paddingOf(context);
      const width = AppReferenceCalendar.width;
      const height = AppReferenceCalendar.height;
      final left = anchor.left.clamp(
          safe.left + 8,
          math.max(
              safe.left + 8, constraints.maxWidth - safe.right - width - 8));
      final below = anchor.bottom + 2;
      final top = (below + height <= constraints.maxHeight - safe.bottom - 8
              ? below
              : anchor.top - height - 2)
          .clamp(
              safe.top + 8,
              math.max(safe.top + 8,
                  constraints.maxHeight - safe.bottom - height - 8));
      return Stack(children: [
        Positioned(
          left: left.toDouble(),
          top: top.toDouble(),
          width: width,
          height: height,
          child: AppReferenceCalendar(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onSelected: (date) => Navigator.of(popupContext).pop(date),
          ),
        )
      ]);
    }),
  );
}

enum _CalendarView { days, months, years }

/// The reference month picker used by [showAppAnchoredCalendar].
class AppReferenceCalendar extends StatefulWidget {
  const AppReferenceCalendar({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onSelected,
  });

  static const width = 221.0;
  static const height = 280.0;
  static const _cell = 30.0;

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelected;

  @override
  State<AppReferenceCalendar> createState() => _AppReferenceCalendarState();
}

class _AppReferenceCalendarState extends State<AppReferenceCalendar> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', //
    'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  late DateTime _selected;
  late DateTime _shown;
  var _view = _CalendarView.days;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate.isBefore(widget.firstDate)
        ? widget.firstDate
        : widget.initialDate.isAfter(widget.lastDate)
            ? widget.lastDate
            : widget.initialDate;
    _selected = DateUtils.dateOnly(initial);
    _shown = DateTime(initial.year, initial.month);
  }

  bool _inRange(DateTime day) =>
      !day.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
      !day.isAfter(DateUtils.dateOnly(widget.lastDate));

  void _page(int step) => setState(() => _shown = switch (_view) {
        _CalendarView.days => DateTime(_shown.year, _shown.month + step),
        _CalendarView.months => DateTime(_shown.year + step, _shown.month),
        _CalendarView.years => DateTime(_shown.year + step * 10, _shown.month),
      });

  String get _title => switch (_view) {
        _CalendarView.days => '${_months[_shown.month - 1]} ${_shown.year}',
        _CalendarView.months => '${_shown.year}',
        _CalendarView.years =>
          '${_shown.year ~/ 10 * 10}-${_shown.year ~/ 10 * 10 + 9}',
      };

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final dark = palette.isDark;
    return Material(
      color: dark ? const Color(0xFF444444) : palette.panelRaised,
      elevation: 6,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
              color: dark ? const Color(0xFF666666) : palette.divider)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(children: [
          SizedBox(
            height: AppReferenceCalendar._cell,
            child: Row(children: [
              _cellButton(context, '«', bold: true, onTap: () => _page(-1)),
              Expanded(
                  child: _cellButton(context, _title,
                      bold: true,
                      expand: true,
                      onTap: _view == _CalendarView.years
                          ? null
                          : () => setState(() => _view =
                              _view == _CalendarView.days
                                  ? _CalendarView.months
                                  : _CalendarView.years))),
              _cellButton(context, '»', bold: true, onTap: () => _page(1)),
            ]),
          ),
          Expanded(
              child: switch (_view) {
            _CalendarView.days => _days(context),
            _CalendarView.months => _grid(context, [
                for (var month = 1; month <= 12; month++)
                  (
                    _months[month - 1].substring(0, 3),
                    month == _selected.month && _shown.year == _selected.year,
                    () => setState(() {
                          _shown = DateTime(_shown.year, month);
                          _view = _CalendarView.days;
                        }),
                  ),
              ]),
            _CalendarView.years => _grid(context, [
                for (var year = _shown.year ~/ 10 * 10 - 1;
                    year <= _shown.year ~/ 10 * 10 + 10;
                    year++)
                  (
                    '$year',
                    year == _selected.year,
                    () => setState(() {
                          _shown = DateTime(year, _shown.month);
                          _view = _CalendarView.months;
                        }),
                  ),
              ]),
          }),
          SizedBox(
            width: double.infinity,
            height: AppReferenceCalendar._cell,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF737373),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: _inRange(DateUtils.dateOnly(DateTime.now()))
                  ? () => widget.onSelected(DateUtils.dateOnly(DateTime.now()))
                  : null,
              child: const Text('Today'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _days(BuildContext context) {
    final palette = appPalette(context);
    final first = DateTime(_shown.year, _shown.month);
    final start = first.subtract(Duration(days: first.weekday % 7));
    return Column(children: [
      Row(children: [
        for (final weekday in _weekdays)
          Expanded(
              child: SizedBox(
                  height: AppReferenceCalendar._cell,
                  child: Center(
                      child: Text(weekday,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: palette.utilityAction))))),
      ]),
      for (var week = 0; week < 6; week++)
        Row(children: [
          for (var weekday = 0; weekday < 7; weekday++)
            Expanded(child: () {
              final day = DateTime(
                  start.year, start.month, start.day + week * 7 + weekday);
              return _cellButton(context, '${day.day}',
                  selected: DateUtils.isSameDay(day, _selected),
                  muted: day.month != _shown.month,
                  onTap: _inRange(day) ? () => widget.onSelected(day) : null);
            }()),
        ]),
    ]);
  }

  Widget _grid(BuildContext context, List<(String, bool, VoidCallback)> cells) {
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 53 / 54,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final (label, selected, onTap) in cells)
          _cellButton(context, label, selected: selected, onTap: onTap),
      ],
    );
  }

  Widget _cellButton(
    BuildContext context,
    String label, {
    bool bold = false,
    bool selected = false,
    bool muted = false,
    bool expand = false,
    VoidCallback? onTap,
  }) {
    final palette = appPalette(context);
    final color = selected
        ? Colors.white
        : muted || onTap == null && !expand
            ? const Color(0xFF999999)
            : palette.textPrimary;
    return SizedBox(
      width: expand ? null : AppReferenceCalendar._cell,
      height: AppReferenceCalendar._cell,
      child: Material(
        color: selected ? palette.utilityAction : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                    color: color)),
          ),
        ),
      ),
    );
  }
}
