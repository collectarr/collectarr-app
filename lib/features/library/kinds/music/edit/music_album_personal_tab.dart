import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:flutter/material.dart';

final class MusicAlbumPersonalTab extends StatelessWidget {
  const MusicAlbumPersonalTab({
    super.key,
    required this.draft,
    required this.accent,
  });

  final MusicAlbumEditDraft draft;
  final Color accent;

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          Text(
            'Listening',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: accent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 680;
              final fieldWidth =
                  wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String>(
                      key: const ValueKey('music-personal-status'),
                      initialValue: _statusValue(draft.trackingStatus),
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: [
                        for (final option in musicTrackingProfile.options)
                          DropdownMenuItem<String>(
                            value: option.storageValue,
                            child: Text(option.label),
                          ),
                      ],
                      onChanged: (value) => draft.trackingStatus = value,
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: TextFormField(
                      key: const ValueKey('music-personal-rating'),
                      initialValue: draft.trackingRating?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rating'),
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        draft.trackingRating = parsed?.clamp(0, 5).toInt();
                      },
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: TextFormField(
                      key: const ValueKey('music-personal-notes'),
                      initialValue: draft.trackingNotes ?? '',
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      onChanged: (value) => draft.trackingNotes = value,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );

  String _statusValue(String? value) => musicTrackingProfile.options.any(
        (option) => option.storageValue == value,
      )
          ? value!
          : '';
}
