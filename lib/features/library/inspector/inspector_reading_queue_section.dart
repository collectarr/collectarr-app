import 'dart:async';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InspectorReadingQueueSection extends StatefulWidget {
  const InspectorReadingQueueSection({
    super.key,
    required this.ownedItemId,
    required this.db,
    required this.accent,
  });

  final String ownedItemId;
  final LocalDatabase db;
  final Color accent;

  @override
  State<InspectorReadingQueueSection> createState() =>
      _InspectorReadingQueueSectionState();
}

class _InspectorReadingQueueSectionState
    extends State<InspectorReadingQueueSection> {
  bool _inQueue = false;
  int? _position;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final repo = ReadingQueueRepository(widget.db);
    final queue = await repo.getQueue();
    final idx = queue.indexOf(widget.ownedItemId);
    if (mounted) {
      setState(() {
        _inQueue = idx >= 0;
        _position = idx >= 0 ? idx + 1 : null;
        _loading = false;
      });
    }
  }

  Future<void> _toggle() async {
    final repo = ReadingQueueRepository(widget.db);
    if (_inQueue) {
      await repo.removeFromQueue(widget.ownedItemId);
    } else {
      await repo.addToQueue(widget.ownedItemId);
    }
    unawaited(_load());
  }

  Future<void> _moveToTop() async {
    final repo = ReadingQueueRepository(widget.db);
    await repo.moveToTop(widget.ownedItemId);
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (_loading) return const SizedBox.shrink();

    return LibraryInspectorSection(
      title: 'Reading Queue',
      accentColor: widget.accent,
      children: [
        Row(
          children: [
            Icon(
              _inQueue ? Icons.bookmark : Icons.bookmark_border,
              size: 16,
              color: _inQueue ? widget.accent : palette.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _inQueue
                    ? 'In queue (position #$_position)'
                    : 'Not in reading queue',
                style: TextStyle(
                  color: _inQueue
                      ? Theme.of(context).colorScheme.onSurface
                      : palette.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            if (_inQueue && _position != null && _position! > 1)
              IconButton(
                icon: const Icon(Icons.vertical_align_top, size: 16),
                tooltip: 'Move to top',
                onPressed: _moveToTop,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            IconButton(
              icon: Icon(
                _inQueue ? Icons.remove_circle_outline : Icons.add_circle_outline,
                size: 16,
              ),
              tooltip: _inQueue ? 'Remove from queue' : 'Add to queue',
              onPressed: _toggle,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                foregroundColor: _inQueue ? Colors.red[300] : widget.accent,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
