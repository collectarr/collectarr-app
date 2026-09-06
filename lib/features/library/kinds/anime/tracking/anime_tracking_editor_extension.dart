import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'package:flutter/material.dart';

Widget buildAnimeTrackingEditorExtension(
  BuildContext context, {
  required TrackingEntry entry,
  required ValueChanged<TrackingEntryEditMutation> onChanged,
  required Color accent,
}) {
  return _AnimeTrackingEditorExtension(
    entry: entry,
    onChanged: onChanged,
    accent: accent,
  );
}

class _AnimeTrackingEditorExtension extends StatefulWidget {
  const _AnimeTrackingEditorExtension({
    required this.entry,
    required this.onChanged,
    required this.accent,
  });

  final TrackingEntry entry;
  final ValueChanged<TrackingEntryEditMutation> onChanged;
  final Color accent;

  @override
  State<_AnimeTrackingEditorExtension> createState() =>
      _AnimeTrackingEditorExtensionState();
}

class _AnimeTrackingEditorExtensionState
    extends State<_AnimeTrackingEditorExtension> {
  late final TextEditingController _seasonController;
  late final TextEditingController _episodeController;

  @override
  void initState() {
    super.initState();
    _seasonController = TextEditingController(
      text: widget.entry.seasonNumber?.toString() ?? '',
    );
    _episodeController = TextEditingController(
      text: widget.entry.episodeNumber?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _AnimeTrackingEditorExtension oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id ||
        oldWidget.entry.updatedAt != widget.entry.updatedAt) {
      _seasonController.text = widget.entry.seasonNumber?.toString() ?? '';
      _episodeController.text = widget.entry.episodeNumber?.toString() ?? '';
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
      (entry) => entry.copyWith(
        seasonNumber: season,
        episodeNumber: episode,
      ),
    );
  }
}
