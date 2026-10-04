import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_form_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Manual Add inputs for the two catalog cover images.
final class MusicAddManualCoversTab extends StatelessWidget {
  const MusicAddManualCoversTab({
    super.key,
    required this.draft,
  });

  final MusicAddManualDraft draft;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final covers = [
          _coverField(
            context,
            label: 'Front Cover',
            value: draft.coverImageUrl,
            onChanged: (value) => draft.coverImageUrl = value,
          ),
          _coverField(
            context,
            label: 'Back Cover',
            value: draft.backCoverImageUrl,
            onChanged: (value) => draft.backCoverImageUrl = value,
          ),
        ];
        final content = constraints.maxWidth < 720
            ? Column(
                children: [
                  for (var index = 0; index < covers.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    covers[index],
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < covers.length; index++) ...[
                    if (index > 0) const SizedBox(width: 14),
                    Expanded(child: covers[index]),
                  ],
                ],
              );
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border.all(color: palette.divider),
            borderRadius: BorderRadius.circular(3),
          ),
          child: content,
        );
      },
    );
  }

  Widget _coverField(
    BuildContext context, {
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: appPalette(context).panel,
                border: Border.all(color: appPalette(context).divider),
              ),
              child: _coverPreview(context, value),
            ),
          ),
          const SizedBox(height: 8),
          LibraryFormField(
            label: '$label URL',
            child: LibraryTextFormControl(
              key: ValueKey('music-add-cover-$label'),
              initialValue: value,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(isDense: true),
              onChanged: onChanged,
            ),
          ),
        ],
      );

  Widget _coverPreview(BuildContext context, String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return Center(
        child: Icon(
          Icons.album_outlined,
          size: 44,
          color: appPalette(context).textMuted,
        ),
      );
    }
    return Image.network(
      uri.toString(),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: appPalette(context).textMuted,
        ),
      ),
    );
  }
}
