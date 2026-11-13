import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/edit/draft/models.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/features/library/ui/primitives/fixed_select_field.dart';
import 'package:collectarr_app/ui/app_dropdown_menu.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import 'package:collectarr_app/features/library/ui/primitives/integer_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/managed_vocabulary_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/remove_icon_button.dart';
import 'package:collectarr_app/ui/anchored_calendar.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/book_read_event.dart';
import '../tracking/book_tracking_profile.dart';
import '../vocabulary/book_vocabularies.dart';

/// One editable Read History row; the key keeps its inputs while other rows
/// are added or removed.
final class BookReadEventRow {
  BookReadEventRow(this.event);
  final Key key = UniqueKey();
  BookReadEvent event;
}

/// Read History and My Rating of one book while it is added or edited.
///
/// The read events are kept with the entry; the reading status, dates and
/// progress of the last event are also the entry's tracking state.
final class BookReadingDraft {
  BookReadingDraft(
    this.original, {
    List<BookReadEvent> events = const [],
    this.pageCount,
  })  : rating =
            TextEditingController(text: original?.rating?.toString() ?? ''),
        rows = [
          for (final event in _withTrackedStatus(events, original))
            BookReadEventRow(event),
        ] {
    _initial = events;
  }

  final TrackingSummary? original;
  final TextEditingController rating;
  final List<BookReadEventRow> rows;
  int? pageCount;
  late final List<BookReadEvent> _initial;

  /// A status set outside this table, such as Mark as read, shows as a row.
  static List<BookReadEvent> _withTrackedStatus(
      List<BookReadEvent> events, TrackingSummary? tracking) {
    final status =
        bookTrackingProfile.normalizeStorageValue(tracking?.statusStorageValue);
    final known = BookReadEvent.statuses.any((item) => item.$1 == status);
    if (tracking == null ||
        !known ||
        status == null ||
        status.isEmpty ||
        (events.isNotEmpty && events.last.status == status)) {
      return events;
    }
    return [
      ...events,
      BookReadEvent(
        status: status,
        startDate: tracking.startedAt,
        endDate: tracking.completedAt,
        pagesRead: tracking.progress.current,
      ),
    ];
  }

  List<BookReadEvent> get events => [
        for (final row in rows)
          if (!row.event.isEmpty) row.event,
      ];

  List<Map<String, dynamic>> get eventsJson =>
      [for (final event in events) event.toJson()];

  bool get eventsChanged => !listEquals(events, _initial);

  bool get hasChanges =>
      eventsChanged || rating.text != (original?.rating?.toString() ?? '');

  String? get status => events.lastOrNull?.status;

  LibraryTrackingEditSelection get selection {
    final last = events.lastOrNull;
    return LibraryTrackingEditSelection(
      rating: int.tryParse(rating.text),
      readStatus: last?.status,
      notes: original?.notes,
      startedAt: last?.startDate,
      finishedAt: last?.endDate,
      progressCurrent: last?.pagesRead,
      progressTotal: pageCount ?? original?.progress.total,
      timesCompleted: events.where((event) => event.isFinished).length,
    );
  }

  void dispose() => rating.dispose();
}

/// The reference's Read History table: one row per read event with its
/// Reading Status, Start and End Date, Reader and Pages Read.
final class BookReadHistoryTab extends StatefulWidget {
  const BookReadHistoryTab({super.key, required this.draft, this.onChanged});
  final BookReadingDraft draft;
  final VoidCallback? onChanged;
  @override
  State<BookReadHistoryTab> createState() => _BookReadHistoryTabState();
}

final class _BookReadHistoryTabState extends State<BookReadHistoryTab> {
  static const _statusWidth = 125.0;
  static const _dateWidth = 185.0;
  static const _pagesWidth = 95.0;
  static const _removeWidth = 37.0;

  void _change(VoidCallback change) {
    setState(change);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final draft = widget.draft;
    Widget cell(double? width, Widget child) {
      final padded = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5), child: child);
      return width == null
          ? Expanded(child: padded)
          : SizedBox(width: width, child: padded);
    }

    Widget heading(double? width, String label) => cell(
        width,
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: palette.textPrimary,
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400)));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final width =
                constraints.maxWidth < 860 ? 860.0 : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(children: [
                  Container(
                    height: 35,
                    color: palette.isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF5F5F5),
                    child: Row(children: [
                      heading(_statusWidth, 'Reading Status'),
                      heading(_dateWidth, 'Start Date'),
                      heading(_dateWidth, 'End Date'),
                      heading(null, 'Reader'),
                      heading(_pagesWidth, 'Pages Read'),
                      const SizedBox(width: _removeWidth),
                    ]),
                  ),
                  for (final (index, row) in draft.rows.indexed)
                    Padding(
                      key: row.key,
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(children: [
                        cell(_statusWidth, _status(row)),
                        cell(
                            _dateWidth,
                            _ReadEventDate(
                                label: 'Start Date',
                                date: row.event.startDate,
                                onChanged: (value) => _change(() => row.event =
                                    row.event.copyWith(startDate: value)))),
                        cell(
                            _dateWidth,
                            _ReadEventDate(
                                label: 'End Date',
                                date: row.event.endDate,
                                onChanged: (value) => _change(() => row.event =
                                    row.event.copyWith(endDate: value)))),
                        cell(
                            null,
                            LibraryManagedVocabularyField(
                                label: 'Reader',
                                showFieldLabel: false,
                                listName: BookVocabularyIds.reader.value,
                                mediaKind: 'book',
                                value: row.event.reader,
                                onChanged: (value) => _change(() => row.event =
                                    row.event.copyWith(reader: value)))),
                        cell(_pagesWidth, _pages(row, palette)),
                        SizedBox(
                          width: _removeWidth,
                          child: LibraryRemoveIconButton(
                            tooltip: 'Remove read event',
                            onPressed: () =>
                                _change(() => draft.rows.removeAt(index)),
                          ),
                        ),
                      ]),
                    ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _change(() =>
                  draft.rows.add(BookReadEventRow(const BookReadEvent()))),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Read Event'),
              style: dialogActionButtonStyle(context, width: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(BookReadEventRow row) {
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
    return LibraryMenuSelectField<String>(
      label: 'Reading Status',
      tooltip: 'Choose reading status',
      display: Text(
          BookReadEvent.statuses
                  .where((item) => item.$1 == row.event.status)
                  .firstOrNull
                  ?.$2 ??
              row.event.status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style),
      itemBuilder: (context) {
        final menu = AppDropdownMenuStyle.of(context);
        return [
          for (final (value, label) in BookReadEvent.statuses)
            menu.shaded(PopupMenuItem(
                value: value,
                height: 32,
                padding: EdgeInsets.zero,
                child: Container(
                    height: 32,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    color: value == row.event.status ? menu.shade : null,
                    child: Text(label, style: style)))),
        ];
      },
      onSelected: (value) =>
          _change(() => row.event = row.event.copyWith(status: value)),
    );
  }

  Widget _pages(BookReadEventRow row, AppThemePalette palette) {
    final total = widget.draft.pageCount;
    return Stack(alignment: Alignment.centerRight, children: [
      LibraryIntegerField(
        initialValue: row.event.pagesRead?.toString() ?? '',
        onChanged: (value) => _change(() =>
            row.event = row.event.copyWith(pagesRead: int.tryParse(value))),
      ),
      if (total != null)
        Padding(
          padding: const EdgeInsets.only(right: 7),
          child: IgnorePointer(
            child: Text('/ $total',
                style: TextStyle(color: palette.textMuted, fontSize: 12)),
          ),
        ),
    ]);
  }
}

/// The YYYY, MM and DD boxes of a read event with the calendar beside them.
final class _ReadEventDate extends StatelessWidget {
  const _ReadEventDate(
      {required this.label, required this.date, required this.onChanged});

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: LibraryPartialDateInput(
            value: date == null ? null : PartialDate.fromDateTime(date!),
            onChanged: (parts) {
              if (parts == null || parts.isEmpty) {
                onChanged(null);
              } else if (parts.asDateTime != null) {
                onChanged(DateTime(parts.year!, parts.month!, parts.day!));
              }
            },
          ),
        ),
        Builder(
          builder: (context) => Tooltip(
            message: 'Choose $label',
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () async {
                final now = DateTime.now();
                final picked = await showAppAnchoredCalendar(
                  context: context,
                  initialDate: date ?? now,
                  firstDate: DateTime(1),
                  lastDate: DateTime(9999, 12, 31),
                );
                if (picked != null) onChanged(picked);
              },
              child: SizedBox(
                width: 22,
                height: 34,
                child: Icon(AppIcons.calendar,
                    size: 14, color: appPalette(context).textPrimary),
              ),
            ),
          ),
        ),
      ]);
}
