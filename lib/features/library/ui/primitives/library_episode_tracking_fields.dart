import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:flutter/material.dart';

/// Shared season/episode number controls for kind-specific tracking drafts.
final class LibraryEpisodeTrackingFields extends StatelessWidget {
  const LibraryEpisodeTrackingFields({
    super.key,
    required this.accent,
    required this.seasonController,
    required this.episodeController,
    required this.onChanged,
  });

  final Color accent;
  final TextEditingController seasonController;
  final TextEditingController episodeController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Episode tracking',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  seasonController,
                  label: 'Season',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numberField(
                  episodeController,
                  label: 'Episode',
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _numberField(
    TextEditingController controller, {
    required String label,
    required VoidCallback onChanged,
  }) =>
      LibraryFormField(
        label: label,
        child: LibraryTextFormControl(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(isDense: true),
          onChanged: (_) => onChanged(),
        ),
      );
}
