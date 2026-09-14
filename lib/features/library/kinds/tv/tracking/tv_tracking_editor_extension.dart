import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/config/library_tracking_editor_capability.dart';
import 'tv_tracking_lifecycle_provider.dart';
import 'tv_tracking_lifecycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildTvTrackingEditorExtension(
  BuildContext context, {
  required TrackingSummary summary,
  required ValueChanged<TrackingLifecycleEditMutation> onChanged,
  required Color accent,
}) {
  return _TvTrackingEditorExtension(
    summary: summary,
    onChanged: onChanged,
    accent: accent,
  );
}

class _TvTrackingEditorExtension extends ConsumerStatefulWidget {
  const _TvTrackingEditorExtension({
    required this.summary,
    required this.onChanged,
    required this.accent,
  });

  final TrackingSummary summary;
  final ValueChanged<TrackingLifecycleEditMutation> onChanged;
  final Color accent;

  @override
  ConsumerState<_TvTrackingEditorExtension> createState() =>
      _TvTrackingEditorExtensionState();
}

class _TvTrackingEditorExtensionState
    extends ConsumerState<_TvTrackingEditorExtension> {
  late final TextEditingController _seasonController;
  late final TextEditingController _episodeController;
  DateTime? _loadedAt;

  @override
  void initState() {
    super.initState();
    _seasonController = TextEditingController(
      text: '',
    );
    _episodeController = TextEditingController(
      text: '',
    );
  }

  @override
  void didUpdateWidget(covariant _TvTrackingEditorExtension oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.ref != widget.summary.ref ||
        oldWidget.summary.updatedAt != widget.summary.updatedAt) {
      _loadedAt = null;
      _seasonController.clear();
      _episodeController.clear();
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
    final lifecycle = ref
        .watch(
          tvTrackingLifecycleBySeriesIdProvider(
            widget.summary.catalogRef.rootScope.id,
          ),
        )
        .asData
        ?.value;
    if (lifecycle != null && _loadedAt != lifecycle.updatedAt) {
      _loadedAt = lifecycle.updatedAt;
      _seasonController.text =
          lifecycle.coordinates.seasonNumber?.toString() ?? '';
      _episodeController.text =
          lifecycle.coordinates.episodeNumber?.toString() ?? '';
    }
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
      TvTrackingCoordinatesPatch(
        seasonNumber: season,
        episodeNumber: episode,
        setSeasonNumber: true,
        setEpisodeNumber: true,
      ),
    );
  }
}
