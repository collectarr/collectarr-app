import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_local_edit_change.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_mutations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final class MusicListeningEditDraft extends ChangeNotifier
    implements LibraryLocalEditChange {
  MusicListeningEditDraft(
      this.libraryEntryRef, Iterable<MusicListenEvent> events)
      : _events = {for (final event in events) event.id: event};
  final LibraryEntryRef libraryEntryRef;
  final Map<String, MusicListenEvent> _events;
  final Set<String> _changed = {};
  List<MusicListenEvent> get history =>
      _events.values.where((event) => !event.isDeleted).toList()
        ..sort((a, b) => b.listenedAt.compareTo(a.listenedAt));
  void save(
      {MusicListenEvent? existing, required DateTime date, String? notes}) {
    final now = DateTime.now().toUtc();
    final event = MusicListenEvent(
      id: existing?.id ?? const Uuid().v4(),
      libraryEntryRef: libraryEntryRef,
      listenedAt: DateTime.utc(date.year, date.month, date.day),
      startedAt: existing?.startedAt,
      finishedAt: existing?.finishedAt,
      location: existing?.location,
      notes: notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    _events[event.id] = event;
    _changed.add(event.id);
    notifyListeners();
  }

  void remove(MusicListenEvent event) {
    final now = DateTime.now().toUtc();
    _events[event.id] = MusicListenEvent(
      id: event.id,
      libraryEntryRef: event.libraryEntryRef,
      listenedAt: event.listenedAt,
      startedAt: event.startedAt,
      finishedAt: event.finishedAt,
      location: event.location,
      notes: event.notes,
      createdAt: event.createdAt,
      updatedAt: now,
      deletedAt: now,
    );
    _changed.add(event.id);
    notifyListeners();
  }

  @override
  Future<void> persist(LocalDatabase database) async {
    final mutations = MusicListeningMutations(database);
    for (final id in _changed) {
      await mutations.upsert(_events[id]!);
    }
  }
}

class MusicListeningDraftSection extends StatefulWidget {
  const MusicListeningDraftSection({super.key, required this.draft});
  final MusicListeningEditDraft draft;
  @override
  State<MusicListeningDraftSection> createState() =>
      _MusicListeningDraftSectionState();
}

class _MusicListeningDraftSectionState
    extends State<MusicListeningDraftSection> {
  DateTime _selectedDate = DateTime.now();
  MusicListeningEditDraft get draft => widget.draft;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: draft,
      builder: (context, _) {
        final history = draft.history;
        return LibraryFormGroup(
            title: 'Played History (Total Plays: ${history.length})',
            child: Column(children: [
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                        onPressed: () => draft.save(date: _selectedDate),
                        icon: const Icon(Icons.headphones_outlined, size: 16),
                        label: const Text('Mark as listened')),
                    SizedBox(
                        width: 170,
                        child: LibraryDateFieldButton(
                            label: 'Listen Date',
                            showLabel: false,
                            value: _selectedDate,
                            onChanged: (date) {
                              if (date != null) {
                                setState(() => _selectedDate = date);
                              }
                            })),
                  ]),
              for (final event in history)
                Row(children: [
                  Expanded(
                      child: Text(
                          '${formatDate(event.listenedAt)}${event.notes?.isNotEmpty == true ? ' — ${event.notes}' : ''}')),
                  IconButton(
                      tooltip: 'Edit listen',
                      onPressed: () => _edit(context, event),
                      icon: const Icon(Icons.edit_outlined, size: 18)),
                  IconButton(
                      tooltip: 'Remove listen',
                      onPressed: () => draft.remove(event),
                      icon: const Icon(Icons.delete_outline, size: 18)),
                ]),
            ]));
      });
  Future<void> _edit(BuildContext context, [MusicListenEvent? existing]) async {
    final date = await showLibraryDateEntryDialog(context,
        label: 'Listen Date',
        initialDate: existing?.listenedAt ?? DateTime.now());
    if (date == null || !context.mounted) return;
    final notes = TextEditingController(text: existing?.notes ?? '');
    String? value;
    try {
      value = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
                title:
                    Text(existing == null ? 'Mark as listened' : 'Edit listen'),
                content: LibraryTextFormControl(
                    controller: notes,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, notes.text),
                      child: const Text('Save'))
                ],
              ));
    } finally {
      notes.dispose();
    }
    if (value != null) {
      draft.save(
          existing: existing,
          date: date,
          notes: value.trim().isEmpty ? null : value.trim());
    }
  }
}
