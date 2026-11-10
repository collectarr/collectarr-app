import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/tracking_draft.dart';
import '../edit/read_history.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';

final class BookManualReadHistory extends StatefulWidget {
  const BookManualReadHistory({super.key, required this.request});
  final LibraryAddManualPaneRequest request;
  @override
  State<BookManualReadHistory> createState() => _BookManualReadHistoryState();
}

final class _BookManualReadHistoryState extends State<BookManualReadHistory> {
  late final BookReadingDraft _draft;
  @override
  void initState() {
    super.initState();
    final initial = widget.request.trackingDraft;
    _draft = BookReadingDraft(null)
      ..status = initial.readStatus
      ..startedAt = initial.startedAt
      ..finishedAt = initial.finishedAt;
    _draft.rating.text = initial.rating?.toString() ?? '';
    _draft.notes.text = initial.notes ?? '';
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BookReadHistoryTab(
        draft: _draft,
        onChanged: () => widget.request.onTrackingDraftChanged?.call(
          LibraryAddTrackingDraft(
            readStatus: _draft.status,
            rating: int.tryParse(_draft.rating.text),
            notes: _draft.notes.text,
            startedAt: _draft.startedAt,
            finishedAt: _draft.finishedAt,
          ),
        ),
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
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.request.trackingDraft.rating?.toString() ?? '',
    )..addListener(_changed);
  }

  void _changed() => widget.request.onTrackingDraftChanged?.call(
        widget.request.trackingDraft
            .copyWith(rating: int.tryParse(_controller.text)),
      );
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
