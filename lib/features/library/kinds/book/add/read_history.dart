import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import '../domain/book_read_event.dart';
import '../edit/read_history.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';

/// Read History of a book being added: the events go with the copy and the
/// last one sets the reading status.
final class BookManualReadHistory extends StatefulWidget {
  const BookManualReadHistory({
    super.key,
    required this.request,
    required this.events,
    required this.pageCount,
    required this.onEventsChanged,
  });
  final LibraryAddManualPaneRequest request;
  final List<BookReadEvent> events;
  final int? pageCount;
  final ValueChanged<List<BookReadEvent>> onEventsChanged;
  @override
  State<BookManualReadHistory> createState() => _BookManualReadHistoryState();
}

final class _BookManualReadHistoryState extends State<BookManualReadHistory> {
  late final BookReadingDraft _draft =
      BookReadingDraft(null, events: widget.events);

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BookReadHistoryTab(
        draft: _draft..pageCount = widget.pageCount,
        onChanged: () {
          final last = _draft.events.lastOrNull;
          widget.onEventsChanged(_draft.events);
          widget.request.onTrackingDraftChanged?.call(
            widget.request.trackingDraft.copyWith(
              readStatus: last?.status,
              startedAt: last?.startDate,
              finishedAt: last?.endDate,
            ),
          );
        },
      );
}

final class BookManualRatingField extends StatefulWidget {
  const BookManualRatingField({super.key, required this.request});
  final LibraryAddManualPaneRequest request;
  @override
  State<BookManualRatingField> createState() => _BookManualRatingFieldState();
}

final class _BookManualRatingFieldState extends State<BookManualRatingField> {
  late final TextEditingController _controller;
  bool _syncing = false;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.request.trackingDraft.rating?.toString() ?? '',
    )..addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant BookManualRatingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rating = widget.request.trackingDraft.rating?.toString() ?? '';
    if (_controller.text != rating) {
      _syncing = true;
      _controller.text = rating;
      _syncing = false;
    }
  }

  void _changed() {
    if (_syncing) return;
    widget.request.onTrackingDraftChanged?.call(
      widget.request.trackingDraft
          .copyWith(rating: int.tryParse(_controller.text)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaRatingField(
        controller: _controller,
        label: 'My Rating',
      );
}
