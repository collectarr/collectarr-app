import 'package:flutter/material.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/edit/draft/models.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_status_field.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';
import '../tracking/book_tracking_profile.dart';

final class BookReadingDraft {
  BookReadingDraft(this.original)
      : status = original?.statusStorageValue,
        rating =
            TextEditingController(text: original?.rating?.toString() ?? ''),
        notes = TextEditingController(text: original?.notes ?? ''),
        startedAt = original?.startedAt,
        finishedAt = original?.completedAt;
  final TrackingSummary? original;
  String? status;
  final TextEditingController rating;
  final TextEditingController notes;
  DateTime? startedAt;
  DateTime? finishedAt;
  bool get hasChanges =>
      status != original?.statusStorageValue ||
      rating.text != (original?.rating?.toString() ?? '') ||
      notes.text != (original?.notes ?? '') ||
      startedAt != original?.startedAt ||
      finishedAt != original?.completedAt;
  LibraryTrackingEditSelection get selection => LibraryTrackingEditSelection(
        rating: int.tryParse(rating.text),
        readStatus: status,
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
        startedAt: startedAt,
        finishedAt: finishedAt,
        progressCurrent: original?.progress.current,
        progressTotal: original?.progress.total,
        timesCompleted: original?.progress.timesCompleted,
      );
  void dispose() {
    rating.dispose();
    notes.dispose();
  }
}

final class BookReadHistoryTab extends StatefulWidget {
  const BookReadHistoryTab({super.key, required this.draft, this.onChanged});
  final BookReadingDraft draft;
  final VoidCallback? onChanged;
  @override
  State<BookReadHistoryTab> createState() => _BookReadHistoryTabState();
}

final class _BookReadHistoryTabState extends State<BookReadHistoryTab> {
  @override
  void initState() {
    super.initState();
    widget.draft.rating.addListener(_notify);
    widget.draft.notes.addListener(_notify);
  }

  void _notify() => widget.onChanged?.call();
  void _change(VoidCallback change) {
    setState(change);
    _notify();
  }

  @override
  void dispose() {
    widget.draft.rating.removeListener(_notify);
    widget.draft.notes.removeListener(_notify);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (draft.status != 'Read')
              TextButton(
                onPressed: () => _change(() {
                  draft.status = 'Read';
                  draft.finishedAt = DateTime.now();
                }),
                child: const Text('Mark as read'),
              ),
            MediaTrackingStatusField(
                label: 'Read Status',
                value: draft.status,
                profile: bookTrackingProfile,
                onChanged: (value) => _change(() => draft.status = value)),
            const SizedBox(height: 12),
            MediaRatingField(controller: draft.rating, label: 'My Rating'),
            const SizedBox(height: 12),
            LibraryPartialDateField.fullDate(
                label: 'Started Date',
                date: draft.startedAt,
                onDateChanged: (value) =>
                    setState(() => draft.startedAt = value)),
            const SizedBox(height: 12),
            LibraryPartialDateField.fullDate(
                label: 'Finished Date',
                date: draft.finishedAt,
                onDateChanged: (value) =>
                    setState(() => draft.finishedAt = value)),
            const SizedBox(height: 12),
            LibraryFormField(
                label: 'Notes',
                child: LibraryTextFormControl(
                    controller: draft.notes, maxLines: 4)),
          ],
        ));
  }
}
