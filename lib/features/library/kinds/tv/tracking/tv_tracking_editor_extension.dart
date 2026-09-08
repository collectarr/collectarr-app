import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:flutter/material.dart';

import 'tv_tracking_entry.dart';

Widget buildTvTrackingEditorExtension(
  BuildContext context, {
  required TrackingEntry entry,
  required ValueChanged<TrackingEntryEditMutation> onChanged,
  required Color accent,
}) {
  return _TvTrackingEditorExtension(
    entry: entry,
    onChanged: onChanged,
    accent: accent,
  );
}

class _TvTrackingEditorExtension extends StatefulWidget {
  const _TvTrackingEditorExtension({
    required this.entry,
    required this.onChanged,
    required this.accent,
  });

  final TrackingEntry entry;
  final ValueChanged<TrackingEntryEditMutation> onChanged;
  final Color accent;

  @override
  State<_TvTrackingEditorExtension> createState() =>
      _TvTrackingEditorExtensionState();
}

class _TvTrackingEditorExtensionState
    extends State<_TvTrackingEditorExtension> {
  late final TextEditingController _seasonController;
  late final TextEditingController _episodeController;

  @override
  void initState() {
    super.initState();
    final coordinates = tvTrackingCoordinatesFor(widget.entry);
    _seasonController = TextEditingController(
      text: coordinates.seasonNumber?.toString() ?? '',
    );
    _episodeController = TextEditingController(
      text: coordinates.episodeNumber?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _TvTrackingEditorExtension oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id ||
        oldWidget.entry.updatedAt != widget.entry.updatedAt) {
      final coordinates = tvTrackingCoordinatesFor(widget.entry);
      _seasonController.text = coordinates.seasonNumber?.toString() ?? '';
      _episodeController.text = coordinates.episodeNumber?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _seasonController.dispose();
    _episodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Episode tracking',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: widget.accent,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _numberField(_seasonController, 'Season')),
            const SizedBox(width: 10),
            Expanded(child: _numberField(_episodeController, 'Episode')),
          ],
        ),
      ],
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) => _publishMutation(),
    );
  }

  void _publishMutation() {
    final season = int.tryParse(_seasonController.text.trim());
    final episode = int.tryParse(_episodeController.text.trim());
    widget.onChanged(
      (entry) => tvTrackingEntryFor(entry).copyWithCoordinates(
        seasonNumber: season,
        episodeNumber: episode,
      ),
    );
  }
}
